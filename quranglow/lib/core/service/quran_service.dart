import 'package:flutter/foundation.dart';
import 'package:quranglow/core/api/fawaz_cdn_source.dart';
import 'package:quranglow/core/api/alquran_cloud_source.dart';
import 'package:quranglow/core/model/aya.dart';
import 'package:quranglow/core/model/surah.dart';

class QuranService {
  final FawazCdnSource fawaz;
  final AlQuranCloudSource cloud;
  QuranService({
    required this.fawaz,
    required this.cloud,
    required AlQuranCloudSource audio,
  });

  Future<Surah> getSurahText(String editionId, int chapter) async {
    debugPrint('[SRV] fetch surah=$chapter ed=$editionId');
    Map<String, dynamic> json;
    if (editionId == 'quran-uthmani') {
      json = await cloud.getSurahText(editionId, chapter);
    } else {
      json = await fawaz.getSurah(editionId, chapter);
    }
    final root = json['chapter'] ?? json['data'] ?? json;
    final name =
        (root['name_ar'] ??
                root['name_arabic'] ??
                root['name'] ??
                'سورة $chapter')
            as String;
    final dynamic versesAny =
        root['verses'] ?? root['ayahs'] ?? root['aya'] ?? root['list'] ?? [];
    final List list = versesAny is List ? versesAny : [];
    final ayat = list.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return Aya.fromMap({
        'global': m['global'] ?? m['globalId'] ?? m['id'] ?? m['number'],
        'surah': chapter,
        'number':
            m['number'] ??
            m['numberInSurah'] ??
            m['verse'] ??
            m['verse_number'] ??
            m['id'] ??
            0,
        'text': m['text'] ?? m['arabic'] ?? m['quran'] ?? '',
      });
    }).toList();
    if (ayat.isEmpty) {
      throw Exception('لم يتم استخراج آيات للسورة $chapter ($editionId).');
    }
    debugPrint('[SRV] loaded ${ayat.length} ayat for $name');
    return Surah(number: chapter, name: name, ayat: ayat.cast<Aya>());
  }

  Future<List<Surah>> getQuranAllText(String editionId) async {
    final out = <Surah>[];
    for (var i = 1; i <= 114; i++) {
      try {
        final s = await getSurahText(editionId, i);
        out.add(s);
      } catch (e) {
        debugPrint('[SRV][ALL] skip $i: $e');
      }
    }
    if (out.isEmpty) {
      throw Exception('تعذر جلب أي سورة للمصحف كاملًا ($editionId).');
    }
    return out;
  }

  Future<List> listAudioEditions() => cloud.listAudioEditions();
  Future<Map<String, dynamic>> getSurahAudio(String ed, int s) =>
      cloud.getSurahAudio(ed, s);

  final Map<String, Map<int, Surah>> _surahCacheByEdition = {};

  Future<List<Map<String, dynamic>>> searchAyat(
    String query, {
    required String editionId,
    int limit = 50,
  }) async {
    final q = _normalizeArabic(query);
    if (q.isEmpty) return const [];
    final cache = _surahCacheByEdition.putIfAbsent(editionId, () => {});
    final hits = <Map<String, dynamic>>[];
    for (var s = 1; s <= 114; s++) {
      final surah = cache[s] ??= await getSurahText(editionId, s);
      for (final aya in surah.ayat) {
        final textN = _normalizeArabic(aya.text);
        if (textN.contains(q)) {
          hits.add({
            'surahNumber': surah.number,
            'ayahNumber': aya.number,
            'surahName': surah.name,
            'text': aya.text,
          });
          if (hits.length >= limit) return hits;
        }
      }
    }
    return hits;
  }

  String _normalizeArabic(String input) {
    var s = input.trim();
    const diacritics = r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]';
    s = s.replaceAll(RegExp(diacritics), '');
    s = s.replaceAll('\u0640', '');
    s = s.replaceAll(RegExp(r'[^\u0600-\u06FF0-9\s]'), '');
    s = s.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
    s = s.replaceAll('ى', 'ي');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }
}
