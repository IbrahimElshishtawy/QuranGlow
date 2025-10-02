// ignore_for_file: implementation_imports

import 'package:dio/dio.dart';
import 'package:http/src/client.dart';

class FawazCdnSource {
  FawazCdnSource(Client watch, this.dio);

  final Dio? dio;
  // jsDelivr يوصي بـ @1
  static const _base = 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1';
  static const _rawGithack =
      'https://rawcdn.githack.com/fawazahmed0/quran-api/1';

  String _editionPath(String editionId) {
    switch (editionId) {
      case 'quran-uthmani': // هذا أصلاً من cloud؛ نحطه هنا احتياط
        return 'editions/ara-quranuthmani';
      case 'quran-simple':
        return 'editions/ara-quransimple';
      default:
        if (editionId.startsWith('ara-')) return 'editions/$editionId';
        return 'editions/ara-quransimple';
    }
  }

  Future<Map<String, dynamic>> _tryGet(String url) async {
    final res = await dio!.get(
      url,
      options: Options(
        headers: {'User-Agent': 'QuranGlow/1.0'},
        sendTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(res.data);
    }
    throw Exception('HTTP ${res.statusCode} @ $url');
  }

  Future<Map<String, dynamic>> getSurah(String editionId, int chapter) async {
    final path = _editionPath(editionId);
    final urls = <String>[
      '$_base/$path/$chapter.min.json', // أسرع
      '$_base/$path/$chapter.json', // بديل
      '$_rawGithack/$path/$chapter.min.json', // بدائل للـ403/404
      '$_rawGithack/$path/$chapter.json',
    ];

    Object? lastErr;
    for (final u in urls) {
      try {
        return await _tryGet(u);
      } catch (e) {
        lastErr = e;
      }
    }
    throw Exception('تعذر جلب السورة $chapter من fawaz CDN: $lastErr');
  }
}
