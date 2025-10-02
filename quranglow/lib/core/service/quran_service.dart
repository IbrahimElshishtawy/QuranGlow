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
      json = await cloud.getSurahText(editionId, chapter); // ثابتة وتنجح
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

  /// يجلب المصحف كاملًا 1..114 بنفس الـ edition
  Future<List<Surah>> getQuranAllText(String editionId) async {
    final out = <Surah>[];
    for (var i = 1; i <= 114; i++) {
      try {
        final s = await getSurahText(editionId, i);
        out.add(s);
      } catch (e) {
        debugPrint('[SRV][ALL] skip $i: $e'); // لا توقف الباقي
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
}
