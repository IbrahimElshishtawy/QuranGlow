// lib/core/di/daily_ayah_provider.dart
// ignore_for_file: depend_on_referenced_packages, no_leading_underscores_for_local_identifiers

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Ù…ÙˆØ¯ÙŠÙ„ Ø¢ÙŠØ© Ø§Ù„ÙŠÙˆÙ… Ù…Ù† Ø§Ù„ØªØ®Ø²ÙŠÙ† Ø§Ù„Ù…Ø­Ù„ÙŠ
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

/// Ù…Ø²ÙˆÙ‘Ø¯ ÙŠØ³Ø­Ø¨ Ø¢ÙŠØ§Øª Ø¹Ø´ÙˆØ§Ø¦ÙŠØ© Ù…Ù† Ø§Ù„Ø³ÙˆØ± Ø§Ù„Ù…Ø­ÙÙˆØ¸Ø© Ø¹Ù„Ù‰ Ø§Ù„Ø¬Ù‡Ø§Ø² (Hive)
final dailyAyatLocalProvider = FutureProvider.autoDispose<List<DailyAyah>>((
  ref,
) async {
  const editionId = 'quran-uthmani';
  const count = 3; // Ø¹Ø¯Ø¯ Ø§Ù„Ø¢ÙŠØ§Øª Ø§Ù„Ù…Ø¹Ø±ÙˆØ¶Ø©
  final rnd = Random();

  final box = await Hive.openBox('quran_cache');

  // Ù…ÙØ§ØªÙŠØ­ Ø§Ù„Ø³ÙˆØ± Ø§Ù„Ù…Ø®Ø²Ù‘Ù†Ø©: Ø¨ØµÙŠØºØ© editionId-chapter
  List<String> _surahKeys() => box.keys
      .where((k) => k.toString().startsWith('$editionId-'))
      .map((e) => e.toString())
      .toList();

  final keys = _surahKeys();

  // Ø¨Ø·Ø§Ù‚Ø© Ø¢ÙŠØ§Øª Ø§Ù„ÙŠÙˆÙ… Ù„Ø§Ø²Ù… ØªØ´ØªØºÙ„ Ù…Ù† Ø§Ù„ÙƒØ§Ø´ Ø§Ù„Ù…Ø­Ù„ÙŠ ÙÙ‚Ø·.
  if (keys.isEmpty) {
    throw Exception(
      'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø¢ÙŠØ§Øª Ù…Ø­ÙÙˆØ¸Ø© Ù…Ø­Ù„ÙŠÙ‹Ø§ Ø¨Ø¹Ø¯. Ø§ÙØªØ­ Ø³ÙˆØ±Ø© Ù…Ø±Ø© ÙˆØ§Ø­Ø¯Ø© Ø£Ø«Ù†Ø§Ø¡ Ø§Ù„Ø§ØªØµØ§Ù„ Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª Ù„ÙŠØªÙ… Ø­ÙØ¸Ù‡Ø§ Ù„Ù„Ø£ÙˆÙÙ„Ø§ÙŠÙ†.',
    );
  }

  // Ø£Ø¯ÙˆØ§Øª parsing Ø¢Ù…Ù†Ø© Ù„Ø£ÙŠ Ø´ÙƒÙ„ JSON Ù…Ø­ØªÙ…Ù„
  Map<String, dynamic> _asStringKeyMap(Object? raw) {
    if (raw is Map) {
      return Map<String, dynamic>.from(
        raw.map((k, v) => MapEntry(k.toString(), v)),
      );
    }
    throw Exception('ØµÙŠØºØ© ØºÙŠØ± Ù…ØªÙˆÙ‚Ø¹Ø© Ù„Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ø³ÙˆØ±Ø©.');
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

    final ref = name.isEmpty ? 'Ø¢ÙŠØ© $ayahNum' : 'Ø³ÙˆØ±Ø© $name â€¢ Ø¢ÙŠØ© $ayahNum';

    out.add(DailyAyah(text: text, ref: ref, surah: surahNum, ayah: ayahNum));
  }

  if (out.isEmpty) {
    throw Exception('ØªØ¹Ø°Ø± Ø§Ø®ØªÙŠØ§Ø± Ø¢ÙŠØ§Øª Ø¹Ø´ÙˆØ§Ø¦ÙŠØ© Ù…Ù† Ø§Ù„ØªØ®Ø²ÙŠÙ† Ø§Ù„Ù…Ø­Ù„ÙŠ.');
  }
  return out;
});
