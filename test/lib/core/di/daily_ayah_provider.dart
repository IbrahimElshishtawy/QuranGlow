// lib/core/di/daily_ayah_api.dart
// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/core/di/providers.dart';

class DailyAyah {
  final String text;
  final String ref;
  const DailyAyah({required this.text, required this.ref});
}

final dailyAyatApiProvider = FutureProvider.autoDispose<List<DailyAyah>>((
  ref,
) async {
  final dio = ref.read(dioProvider);

  const textEditionId = 'quran-uthmani';

  Future<Map<String, dynamic>> _fetchOne() async {
    final Response res = await dio.get(
      'https://api.alquran.cloud/v1/ayah/random/$textEditionId',
    );
    if (res.statusCode != 200 || res.data == null || res.data['data'] == null) {
      throw Exception('تعذر جلب آية عشوائية');
    }
    return res.data['data'] as Map<String, dynamic>;
  }

  final picked = <DailyAyah>[];
  final seen = <int>{};
  int attempts = 0;
  while (picked.length < 4 && attempts < 12) {
    attempts++;
    final d = await _fetchOne();

    final globalNumber = d['number'] as int?;
    if (globalNumber == null || !seen.add(globalNumber)) continue;

    final text = (d['text'] ?? d['ayahText'] ?? '').toString();
    final surah = (d['surah'] ?? {}) as Map<String, dynamic>;
    final surahName = (surah['name'] ?? surah['englishName'] ?? 'سورة')
        .toString();
    final nInSurah = (d['numberInSurah'] ?? '').toString();

    picked.add(DailyAyah(text: text, ref: '$surahName • $nInSurah'));
  }

  if (picked.isEmpty) {
    throw Exception('لم يتم العثور على آيات الآن، حاول لاحقًا.');
  }
  return picked;
});
