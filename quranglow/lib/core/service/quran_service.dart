import 'package:quranglow/core/api/alquran_cloud_source.dart';
import 'package:quranglow/core/api/fawaz_cdn_source.dart';
import 'package:quranglow/core/model/aya.dart';
import 'package:quranglow/core/model/surah.dart';

class QuranService {
  final FawazCdnSource fawaz;
  final AlQuranCloudSource audio;

  QuranService({required this.fawaz, required this.audio});

  Future<Surah> getSurahText(String editionId, int chapter) async {
    final json = await fawaz.getSurah(editionId, chapter);
    // parsing: repo's JSON format may contain 'chapter' with 'verses'
    final chapterMap = json['chapter'] ?? json;
    final name = chapterMap['name'] ?? 'سورة $chapter';
    final verses =
        (chapterMap['verses'] ?? chapterMap['ayahs'] ?? []) as List<dynamic>;
    final ayat = verses.map((v) {
      final m = v as Map<String, dynamic>;
      return Aya.fromMap({
        'global': m['global'] ?? m['globalId'],
        'surah': chapter,
        'number': m['number'] ?? m['verse'] ?? m['verse_number'],
        'text': m['text'] ?? m['arabic'],
      });
    }).toList();
    return Surah(number: chapter, name: name, ayat: ayat);
  }

  Future<List> listAudioEditions() => audio.listAudioEditions();
  Future<Map<String, dynamic>> getSurahAudio(String editionId, int s) =>
      audio.getSurahAudio(editionId, s);
}
