// lib/core/api/fawaz_cdn_source.dart  (Dio + مرايا للنص)
import 'package:dio/dio.dart';

class FawazCdnSource {
  FawazCdnSource({required this.dio});
  final Dio dio;

  static const _mirrors = <String>[
    'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1',
    'https://raw.githubusercontent.com/fawazahmed0/quran-api/1',
  ];

  String _editionPath(String editionId) {
    switch (editionId) {
      case 'quran-uthmani':
        return 'editions/ara-quranuthmani';
      case 'quran-simple':
        return 'editions/ara-quransimple';
      default:
        if (editionId.startsWith('ara-')) return 'editions/$editionId';
        return 'editions/ara-quransimple';
    }
  }

  Future<Map<String, dynamic>> getSurah(String editionId, int chapter) async {
    final path = _editionPath(editionId);
    DioException? last;

    for (final base in _mirrors) {
      final url = '$base/$path/$chapter.json';
      try {
        final res = await dio.get(url);
        if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
          return Map<String, dynamic>.from(res.data);
        }
      } on DioException catch (e) {
        last = e;
      }
    }

    // بديل نصي من AlQuranCloud في حالة فشل المرايا
    final fb = await dio.get(
      'https://api.alquran.cloud/v1/surah/$chapter/quran-uthmani',
    );
    if (fb.statusCode == 200 && fb.data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(fb.data);
    }

    throw last ?? Exception('فشل جلب السورة $chapter من كل المرايا والبديل.');
  }
}
