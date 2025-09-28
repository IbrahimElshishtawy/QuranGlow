import 'package:http/http.dart' as http;
import 'dart:convert';

class FawazCdnSource {
  final http.Client client;
  static const _base = 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1';

  FawazCdnSource([http.Client? c]) : client = c ?? http.Client();

  Future<List<dynamic>> listEditions() async {
    final resp = await client.get(Uri.parse('$_base/editions.json'));
    if (resp.statusCode != 200) throw Exception('Failed to load editions');
    return jsonDecode(resp.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getSurah(String editionId, int chapter) async {
    final paths = [
      'editions/$editionId/$chapter.min.json',
      'editions/$editionId/$chapter.json',
    ];
    for (final p in paths) {
      final uri = Uri.parse('$_base/$p');
      final resp = await client.get(uri);
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
    }
    throw Exception('Surah not found');
  }

  Future<Map<String, dynamic>> getPage(String editionId, int page) async {
    final paths = [
      'editions/$editionId/pages/$page.min.json',
      'editions/$editionId/pages/$page.json',
    ];
    for (final p in paths) {
      final uri = Uri.parse('$_base/$p');
      final resp = await client.get(uri);
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
    }
    throw Exception('Page not found');
  }
}
