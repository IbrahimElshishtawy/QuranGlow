// lib/core/di/daily_ayah_provider.dart
// ignore_for_file: depend_on_referenced_packages, no_leading_underscores_for_local_identifiers

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:quranglow/core/di/providers.dart'; // فيه quranServiceProvider

/// موديل آية اليوم من التخزين المحلي
class DailyAyah {
  final String text;
  final String ref;
  final int surah;
  final int ayah;
  const DailyAyah({
    required this.text,
    required this.ref,
    required this.surah,
    required this.ayah,
  });
}

/// مزوّد يسحب آيات عشوائية من السور المحفوظة على الجهاز (Hive)
final dailyAyatLocalProvider = FutureProvider.autoDispose<List<DailyAyah>>((
  ref,
) async {
  const editionId = 'quran-uthmani';
  const count = 3; // عدد الآيات المعروضة
  final rnd = Random();

  final service = ref.read(quranServiceProvider);
  final box = await Hive.openBox('quran_cache');

  // مفاتيح السور المخزّنة: بصيغة editionId-chapter
  List<String> _surahKeys() => box.keys
      .where((k) => k.toString().startsWith('$editionId-'))
      .map((e) => e.toString())
      .toList();

  var keys = _surahKeys();

  // لو ما فيش بيانات محليًا، نزّل مرة واحدة ثم أعد المحاولة
  if (keys.isEmpty) {
    await service.getQuranAllText(editionId);
    keys = _surahKeys();
    if (keys.isEmpty) {
      throw Exception('لا توجد بيانات محلية للقرآن.');
    }
  }

  // أدوات parsing آمنة لأي شكل JSON محتمل
  Map<String, dynamic> _asStringKeyMap(Object? raw) {
    if (raw is Map) {
      return Map<String, dynamic>.from(
        raw.map((k, v) => MapEntry(k.toString(), v)),
      );
    }
    throw Exception('صيغة غير متوقعة لبيانات السورة.');
  }

  Map<String, dynamic> _root(Map<String, dynamic> j) =>
      _asStringKeyMap(j['chapter'] ?? j['data'] ?? j);

  List _verses(Map<String, dynamic> r) {
    final v = r['verses'] ?? r['ayahs'] ?? r['aya'] ?? r['list'] ?? [];
    return v is List ? v : <dynamic>[];
  }

  int _parseInt(Object? o, {int orElse = 1}) {
    if (o is int) return o;
    final s = o?.toString() ?? '';
    final n = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), ''));
    return n ?? orElse;
  }

  String _verseText(Map<String, dynamic> m) =>
      (m['text'] ?? m['arabic'] ?? m['quran'] ?? '').toString();

  final chosen = <String>{};
  final out = <DailyAyah>[];

  for (int i = 0; i < count * 3 && out.length < count; i++) {
    final k = keys[rnd.nextInt(keys.length)];
    final raw = box.get(k);
    final j = _asStringKeyMap(raw);
    final r = _root(j);

    final parts = k.split('-');
    final surahNum = _parseInt(parts.isNotEmpty ? parts.last : null, orElse: 1);

    final name = (r['name_ar'] ?? r['name_arabic'] ?? r['name'] ?? '')
        .toString();
    final verses = _verses(r);
    if (verses.isEmpty) continue;

    final vMap = _asStringKeyMap(verses[rnd.nextInt(verses.length)]);
    final ayahNum = _parseInt(
      vMap['number'] ??
          vMap['numberInSurah'] ??
          vMap['verse'] ??
          vMap['verse_number'] ??
          vMap['id'],
      orElse: 1,
    );

    final text = _verseText(vMap).trim();
    if (text.isEmpty) continue;

    final keyUniq = '$surahNum:$ayahNum';
    if (chosen.contains(keyUniq)) continue;
    chosen.add(keyUniq);

    final ref = name.isEmpty ? 'آية $ayahNum' : 'سورة $name • آية $ayahNum';

    out.add(DailyAyah(text: text, ref: ref, surah: surahNum, ayah: ayahNum));
  }

  if (out.isEmpty) {
    throw Exception('تعذر اختيار آيات عشوائية من التخزين المحلي.');
  }
  return out;
});
