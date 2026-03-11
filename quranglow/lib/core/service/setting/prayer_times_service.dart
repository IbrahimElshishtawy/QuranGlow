import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:quranglow/core/model/prayer/prayer_times_data.dart';
import 'package:quranglow/core/service/setting/location_service.dart';

class PrayerTimesService {
  PrayerTimesService({
    required this.client,
    required this.locationService,
  });

  final http.Client client;
  final LocationService locationService;

  static const _baseHost = 'api.aladhan.com';
  static const _prayerKeys = <String>[
    'Fajr',
    'Sunrise',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  Future<PrayerTimesData> fetchForToday() async {
    final position = await locationService.getCurrentOnce();
    if (position == null) {
      throw Exception('تعذر الوصول إلى الموقع. فعّل خدمة الموقع والأذونات.');
    }

    final now = DateTime.now();
    final todayRaw = await _fetchRawForDate(position, now);
    final tomorrowRaw = await _fetchRawForDate(
      position,
      now.add(const Duration(days: 1)),
    );

    final todayTimings = _parseTimings(todayRaw['timings'], now);
    final tomorrowTimings = _parseTimings(
      tomorrowRaw['timings'],
      now.add(const Duration(days: 1)),
    );

    final next = _findNextPrayer(todayTimings, tomorrowTimings, now);

    return PrayerTimesData(
      timezone: (todayRaw['meta']?['timezone'] ?? '') as String,
      methodName: (todayRaw['meta']?['method']?['name'] ?? 'المعيار الافتراضي')
          as String,
      prayers: todayTimings,
      nextPrayerName: next.$1,
      nextPrayerTime: next.$2,
    );
  }

  Future<Map<String, dynamic>> _fetchRawForDate(Position position, DateTime d) async {
    final uri = Uri.https(_baseHost, '/v1/timings/${d.day}-${d.month}-${d.year}', {
      'latitude': position.latitude.toStringAsFixed(6),
      'longitude': position.longitude.toStringAsFixed(6),
      'method': '5',
      'school': '0',
      'latitudeAdjustmentMethod': '3',
      'midnightMode': '1',
      'iso8601': 'true',
    });

    final res = await client.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('فشل جلب المواقيت (${res.statusCode}).');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('الاستجابة لا تحتوي بيانات مواقيت.');
    }
    return data;
  }

  Map<String, DateTime> _parseTimings(dynamic rawTimings, DateTime date) {
    if (rawTimings is! Map<String, dynamic>) {
      throw Exception('تنسيق مواقيت الصلاة غير صالح.');
    }

    final parsed = <String, DateTime>{};
    for (final key in _prayerKeys) {
      final raw = (rawTimings[key] ?? '').toString();
      final clean = _normalizeTime(raw);
      final parts = clean.split(':');
      if (parts.length != 2) continue;
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h == null || m == null) continue;
      parsed[key] = DateTime(date.year, date.month, date.day, h, m);
    }

    if (parsed.length < 5) {
      throw Exception('تعذر قراءة مواقيت اليوم بشكل صحيح.');
    }
    return parsed;
  }

  (String, DateTime) _findNextPrayer(
    Map<String, DateTime> today,
    Map<String, DateTime> tomorrow,
    DateTime now,
  ) {
    const order = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    for (final key in order) {
      final t = today[key];
      if (t != null && t.isAfter(now)) return (key, t);
    }
    final nextFajr = tomorrow['Fajr'];
    if (nextFajr == null) {
      throw Exception('تعذر تحديد الصلاة القادمة.');
    }
    return ('Fajr', nextFajr);
  }

  String _normalizeTime(String raw) {
    final m = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw);
    if (m == null) return raw;
    final hh = int.parse(m.group(1)!);
    final mm = int.parse(m.group(2)!);
    return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
  }
}
