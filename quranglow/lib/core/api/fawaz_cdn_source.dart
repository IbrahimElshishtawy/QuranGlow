// lib/core/api/fawaz_cdn_source.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
      debugPrint('[FWZ] try $url');
      try {
        final res = await dio.get(url);
        debugPrint('[FWZ] status ${res.statusCode}');
        if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
          debugPrint('[FWZ] OK from $base');
          return Map<String, dynamic>.from(res.data);
        }
      } on DioException catch (e) {
        last = e;
        debugPrint('[FWZ] error ${e.message}');
      }
    }

    // fallback
    final fb = await dio.get(
      'https://api.alquran.cloud/v1/surah/$chapter/quran-uthmani',
    );
    debugPrint('[FWZ][FB] status ${fb.statusCode}');
    if (fb.statusCode == 200 && fb.data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(fb.data);
    }

    throw last ?? Exception('فشل جلب السورة $chapter من كل المرايا والبديل.');
  }
}
