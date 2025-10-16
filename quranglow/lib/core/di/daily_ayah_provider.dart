// ignore_for_file: depend_on_referenced_packages, no_leading_underscores_for_local_identifiers
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:quranglow/core/di/providers.dart';

class DailyAyah {
  final String text;
  final String ref;
  final int surah; // ← جديد
  final int ayah; // ← جديد
  const DailyAyah({
    required this.text,
    required this.ref,
    required this.surah,
    required this.ayah,
  });
}

final dailyAyatLocalProvider = FutureProvider.autoDispose<List<DailyAyah>>((
  ref,
) async {
  const editionId = 'quran-uthmani';
  const count = 3;
  final rnd = Random();

  final service = ref.read(quranServiceProvider);
  final box = await Hive.openBox('quran_cache');

  var keys = box.keys
      .where((k) => k.toString().startsWith('$editionId-'))
      .map((e) => e.toString())
      .toList();

  if (keys.isEmpty) {
    await service.getQuranAllText(editionId);
    keys = box.keys
        .where((k) => k.toString().startsWith('$editionId-'))
        .map((e) => e.toString())
        .toList();
    if (keys.isEmpty) throw Exception('لا توجد بيانات محلية للقرآن.');
  }

  final out = <DailyAyah>[];

  Map<String, dynamic> _root(Map<String, dynamic> j) =>
      (j['chapter'] ?? j['data'] ?? j) as Map<String, dynamic>;
  List _verses(Map<String, dynamic> r) =>
      (r['verses'] ?? r['ayahs'] ?? r['aya'] ?? r['list'] ?? []) as List;

  for (int i = 0; i < count; i++) {
    final k = keys[rnd.nextInt(keys.length)];
    final j = Map<String, dynamic>.from(box.get(k));
    final r = _root(j);

    // استنتاج رقم السورة من المفتاح: editionId-chapter
    final parts = k.split('-');
    final surahNum = int.tryParse(parts.last) ?? 1;

    final name = (r['name_ar'] ?? r['name_arabic'] ?? r['name'] ?? '')
        .toString();
    final verses = _verses(r);
    if (verses.isEmpty) continue;

    final v = Map<String, dynamic>.from(
      verses[rnd.nextInt(verses.length)] as Map,
    );

    final text = (v['text'] ?? v['arabic'] ?? v['quran'] ?? '').toString();
    final numInSurahStr =
        (v['number'] ??
                v['numberInSurah'] ??
                v['verse'] ??
                v['verse_number'] ??
                v['id'] ??
                '')
            .toString();
    final ayahNum =
        int.tryParse(numInSurahStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;

    if (text.trim().isEmpty) continue;

    final ref = name.isEmpty ? 'آية $ayahNum' : 'سورة $name • آية $ayahNum';
    out.add(DailyAyah(text: text, ref: ref, surah: surahNum, ayah: ayahNum));
  }

  if (out.isEmpty)
    throw Exception('تعذر اختيار آيات عشوائية من التخزين المحلي.');
  return out;
});
