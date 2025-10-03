// lib/core/api/alquran_cloud_source.dart
import 'package:dio/dio.dart';

class AlQuranCloudSource {
  AlQuranCloudSource({required this.dio});
  final Dio dio;

  static const _base = 'https://api.alquran.cloud/v1';

  Future<Map<String, dynamic>> getSurahText(String edition, int s) async {
    final res = await dio.get('$_base/surah/$s/$edition');
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode} عند جلب نص السورة $s ($edition)');
    }
    return Map<String, dynamic>.from(res.data);
  }

  Future<List> listAudioEditions() async {
    final res = await dio.get('$_base/edition/format/audio');
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode} عند جلب إصدارات الصوت');
    }
    final data = res.data['data'];
    return data is List ? data : <dynamic>[];
  }

  Future<Map<String, dynamic>> getSurahAudio(String edition, int s) async {
    final res = await dio.get('$_base/surah/$s/$edition');
    if (res.statusCode != 200) {
      throw Exception(
        'HTTP ${res.statusCode} عند جلب صوت السورة $s ($edition)',
      );
    }
    return Map<String, dynamic>.from(res.data);
  }

  Future<List<Map<String, dynamic>>> searchAyat(
    String query, {
    required String editionId,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final res = await dio.get('$_base/search/$q/$editionId');
    if (res.statusCode != 200) return const [];
    final data = res.data['data'];
    final matches = (data?['matches'] as List?) ?? const [];
    return matches
        .map<Map<String, dynamic>>((e) {
          final m = Map<String, dynamic>.from(e as Map);
          final s = m['surah'] as Map?;
          return {
            'surahNumber': (s?['number'] as num?)?.toInt() ?? 0,
            'ayahNumber': (m['numberInSurah'] as num?)?.toInt() ?? 0,
            'surahName': (s?['englishName'] ?? s?['name'] ?? '').toString(),
            'text': (m['text'] ?? '').toString(),
          };
        })
        .toList(growable: false);
  }
}
