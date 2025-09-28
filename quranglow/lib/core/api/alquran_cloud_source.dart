import 'dart:convert';
import 'package:http/http.dart' as http;

class AlQuranCloudSource {
  final http.Client client;
  static const _base = 'http://api.alquran.cloud/v1';

  AlQuranCloudSource([http.Client? c]) : client = c ?? http.Client();

  Future<List<dynamic>> listAudioEditions() async {
    final uri = Uri.parse('$_base/edition?format=audio&type=versebyverse');
    final resp = await client.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Failed to list audio editions');
    }
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    return (body['data'] as List<dynamic>);
  }

  Future<Map<String, dynamic>> getSurahAudio(
    String editionId,
    int surah,
  ) async {
    final uri = Uri.parse('$_base/surah/$surah/$editionId');
    final resp = await client.get(uri);
    if (resp.statusCode != 200) throw Exception('Failed to load surah audio');
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAyahAudio(
    String editionId,
    String ayahRef,
  ) async {
    final uri = Uri.parse(
      '$_base/ayah/$ayahRef/$editionId',
    ); // ayahRef like "2:255"
    final resp = await client.get(uri);
    if (resp.statusCode != 200) throw Exception('Failed to load ayah audio');
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
}
