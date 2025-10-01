import 'dart:convert';
import 'package:http/http.dart' as http;

class AlQuranCloudSource {
  final http.Client client;

  static const _base = 'https://api.alquran.cloud/v1';

  AlQuranCloudSource([http.Client? c]) : client = c ?? http.Client();

  Future<List<dynamic>> listAudioEditions() async {
    final uri = Uri.parse(
      '$_base/edition?format=audio&type=versebyverse&language=ar',
    );
    final resp = await client.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('Failed to list audio editions: ${resp.statusCode}');
    }

    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    return body['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> getSurahAudio(
    String editionId,
    int surah,
  ) async {
    final uri = Uri.parse('$_base/surah/$surah/$editionId');
    final resp = await client.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('Failed to load surah audio: ${resp.statusCode}');
    }

    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAyahAudio(
    String editionId,
    String ayahRef,
  ) async {
    final uri = Uri.parse('$_base/ayah/$ayahRef/$editionId');
    final resp = await client.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('Failed to load ayah audio: ${resp.statusCode}');
    }

    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
}
