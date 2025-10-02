import 'package:quranglow/core/api/fawaz_cdn_source.dart';
import 'package:quranglow/core/api/alquran_cloud_source.dart';
import 'package:quranglow/core/model/aya.dart';
import 'package:quranglow/core/model/surah.dart';

class QuranService {
  final FawazCdnSource fawaz;
  final AlQuranCloudSource audio;
  QuranService({required this.fawaz, required this.audio});

  Future<Surah> getSurahText(String editionId, int chapter) async {
    final json = await fawaz.getSurah(editionId, chapter);

    final root = json['chapter'] ?? json['data'] ?? json;

    final name =
        (root['name_ar'] ??
                root['name_arabic'] ??
                root['name'] ??
                'سورة $chapter')
            as String;

    final dynamic versesAny =
        root['verses'] ?? root['ayahs'] ?? root['aya'] ?? root['list'] ?? [];

    final List ayatList = versesAny is List ? versesAny : [];

    final ayat = ayatList.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return Aya.fromMap({
        'global': m['global'] ?? m['globalId'] ?? m['id'] ?? m['number'],
        'surah': chapter,
        'number':
            m['number'] ??
            m['verse'] ??
            m['verse_number'] ??
            m['id'] ??
            m['numberInSurah'] ??
            0,
        'text': m['text'] ?? m['arabic'] ?? m['quran'] ?? '',
      });
    }).toList();

    if (ayat.isEmpty) {
      throw Exception(
        'لا توجد آيات مستخرجة. جرّب quran-simple أو quran-uthmani.',
      );
    }

    return Surah(number: chapter, name: name, ayat: ayat.cast<Aya>());
  }

  Future<List> listAudioEditions() => audio.listAudioEditions();
  Future<Map<String, dynamic>> getSurahAudio(String ed, int s) =>
      audio.getSurahAudio(ed, s);
}
