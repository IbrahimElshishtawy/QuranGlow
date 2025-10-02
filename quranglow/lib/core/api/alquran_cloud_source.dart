import 'dart:convert';
import 'package:http/http.dart' as http;

typedef ProgressCallback = void Function(bool inProgress, String label);

class AlQuranCloudSource {
  final http.Client client;
  final ProgressCallback? onProgress;
  static const _host = 'api.alquran.cloud';
  static const _basePath = '/v1';

  AlQuranCloudSource([http.Client? c, this.onProgress])
    : client = c ?? http.Client();

  Future<List<dynamic>> listAudioEditions() async {
    onProgress?.call(true, 'جاري جلب قائمة القرّاء...');
    try {
      final uri = Uri.https(_host, '$_basePath/edition', {
        'format': 'audio',
        'type': 'versebyverse',
        'language': 'ar',
      });
      final r = await client.get(uri);
      if (r.statusCode != 200) {
        throw Exception('editions HTTP ${r.statusCode}');
      }
      final m = jsonDecode(r.body) as Map<String, dynamic>;
      if (m['code'] != 200) {
        throw Exception('editions API code ${m['code']}');
      }
      return (m['data'] as List).cast<dynamic>();
    } finally {
      onProgress?.call(false, '');
    }
  }

  Future<Map<String, dynamic>> getSurahAudio(
    String editionId,
    int surah,
  ) async {
    final id = editionId.trim();
    if (surah < 1 || surah > 114) {
      throw ArgumentError('surah must be 1..114');
    }
    onProgress?.call(true, 'تحميل سورة $surah ($id)...');
    try {
      final uri = Uri.https(_host, '$_basePath/surah/$surah/$id');
      final r = await client.get(uri);
      if (r.statusCode != 200) {
        // تشخيص سريع
        // ignore: avoid_print
        print('GET $uri -> ${r.statusCode}\n${r.body}');
        throw Exception('surah HTTP ${r.statusCode}');
      }
      final m = jsonDecode(r.body) as Map<String, dynamic>;
      if (m['code'] != 200) {
        throw Exception('surah API code ${m['code']}');
      }
      return m;
    } finally {
      onProgress?.call(false, '');
    }
  }

  Future<Map<String, dynamic>> getAyahAudio(
    String editionId,
    String ayahRef,
  ) async {
    final id = editionId.trim();
    final ref = ayahRef.trim(); // يجب أن تكون على شكل "2:255"
    if (!RegExp(r'^\d{1,3}:\d{1,3}$').hasMatch(ref)) {
      throw ArgumentError('ayahRef must be like "2:255"');
    }
    onProgress?.call(true, 'تحميل الآية $ref ($id)...');
    try {
      // Uri.https سيعالج النقطتين بالشكل الصحيح
      final uri = Uri.https(_host, '$_basePath/ayah/$ref/$id');
      final r = await client.get(uri);
      if (r.statusCode != 200) {
        // ignore: avoid_print
        print('GET $uri -> ${r.statusCode}\n${r.body}');
        throw Exception('ayah HTTP ${r.statusCode}');
      }
      final m = jsonDecode(r.body) as Map<String, dynamic>;
      if (m['code'] != 200) {
        throw Exception('ayah API code ${m['code']}');
      }
      return m;
    } finally {
      onProgress?.call(false, '');
    }
  }
}
