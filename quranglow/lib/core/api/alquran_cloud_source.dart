// ignore_for_file: implementation_imports

import 'package:dio/dio.dart';
import 'package:http/src/client.dart';

class AlQuranCloudSource {
  AlQuranCloudSource(Client watch, {this.dio});
  final Dio? dio;

  static const _base = 'https://api.alquran.cloud/v1';
  Future<Map<String, dynamic>> getSurahText(String edition, int s) async {
    final url = '$_base/surah/$s/$edition';
    final res = await dio!.get(
      url,
      options: Options(
        sendTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode} عند جلب نص السورة $s ($edition)');
    }
    return Map<String, dynamic>.from(res.data);
  }

  Future<List> listAudioEditions() async {
    final res = await dio!.get('$_base/edition/format/audio');
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode} عند جلب إصدارات الصوت');
    }
    final data = res.data['data'];
    return data is List ? data : <dynamic>[];
  }

  Future<Map<String, dynamic>> getSurahAudio(String edition, int s) async {
    final res = await dio!.get('$_base/surah/$s/$edition');
    if (res.statusCode != 200) {
      throw Exception(
        'HTTP ${res.statusCode} عند جلب صوت السورة $s ($edition)',
      );
    }
    return Map<String, dynamic>.from(res.data);
  }
}
