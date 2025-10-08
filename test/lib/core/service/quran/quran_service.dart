import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show NetworkAssetBundle;
import 'package:flutter/material.dart';
import 'package:test/core/api/alquran_cloud_source.dart';
import 'package:test/core/api/fawaz_cdn_source.dart';
import 'package:test/core/model/aya/aya.dart';
import 'package:test/core/model/book/surah.dart';

class QuranService {
  final FawazCdnSource fawaz;
  final AlQuranCloudSource cloud;
  QuranService({
    required this.fawaz,
    required this.cloud,
    required AlQuranCloudSource audio,
  });

  final Map<String, Map<int, Surah>> _surahCacheByEdition = {};
  final Map<String, Uint8List> _imageCache = {};
  final int _imageCacheMax = 32;

  Future<Surah> getSurahText(String editionId, int chapter) async {
    final cache = _surahCacheByEdition.putIfAbsent(editionId, () => {});
    final cached = cache[chapter];
    if (cached != null) return cached;

    debugPrint('[SRV] fetch surah=$chapter ed=$editionId');
    Map<String, dynamic> json;
    if (editionId == 'quran-uthmani') {
      json = await cloud.getSurahText(editionId, chapter);
    } else {
      json = await fawaz.getSurah(editionId, chapter);
    }
    final root = json['chapter'] ?? json['data'] ?? json;
    final name =
        (root['name_ar'] ??
                root['name_arabic'] ??
                root['name'] ??
                'سورة $chapter')
            as String;
    final dynamic versesAny =
        root['verses'] ?? root['ayahs'] ?? root['aya'] ?? root['list'] ?? [];
    final List list = versesAny is List ? versesAny : [];
    final ayat = list.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return Aya.fromMap({
        'global': m['global'] ?? m['globalId'] ?? m['id'] ?? m['number'],
        'surah': chapter,
        'number':
            m['number'] ??
            m['numberInSurah'] ??
            m['verse'] ??
            m['verse_number'] ??
            m['id'] ??
            0,
        'text': m['text'] ?? m['arabic'] ?? m['quran'] ?? '',
      });
    }).toList();
    if (ayat.isEmpty) {
      throw Exception('لم يتم استخراج آيات للسورة $chapter ($editionId).');
    }
    final s = Surah(number: chapter, name: name, ayat: ayat.cast<Aya>());
    cache[chapter] = s;
    debugPrint('[SRV] loaded ${ayat.length} ayat for $name');
    return s;
  }

  Future<List<Surah>> getQuranAllText(String editionId) async {
    final out = <Surah>[];
    for (var i = 1; i <= 114; i++) {
      try {
        final s = await getSurahText(editionId, i);
        out.add(s);
      } catch (e) {
        debugPrint('[SRV][ALL] skip $i: $e');
      }
    }
    if (out.isEmpty) {
      throw Exception('تعذر جلب أي سورة للمصحف كاملًا ($editionId).');
    }
    return out;
  }

  Future<List> listAudioEditions() => cloud.listAudioEditions();
  Future<Map<String, dynamic>> getSurahAudio(String ed, int s) =>
      cloud.getSurahAudio(ed, s);

  Future<List<Map<String, dynamic>>> searchAyat(
    String query, {
    required String editionId,
    int limit = 50,
  }) async {
    final q = _normalizeArabic(query);
    if (q.isEmpty) return const [];
    final cache = _surahCacheByEdition.putIfAbsent(editionId, () => {});
    final hits = <Map<String, dynamic>>[];
    for (var s = 1; s <= 114; s++) {
      final surah = cache[s] ??= await getSurahText(editionId, s);
      for (final aya in surah.ayat) {
        final textN = _normalizeArabic(aya.text);
        if (textN.contains(q)) {
          hits.add({
            'surahNumber': surah.number,
            'ayahNumber': aya.number,
            'surahName': surah.name,
            'text': aya.text,
          });
          if (hits.length >= limit) return hits;
        }
      }
    }
    return hits;
  }

  Future<Uint8List> getImageBytes(String url) async {
    final u = url.trim();
    if (u.isEmpty) {
      throw ArgumentError('empty url');
    }
    final cached = _imageCache[u];
    if (cached != null) return cached;
    final uri = Uri.parse(u);
    final byteData = await NetworkAssetBundle(uri).load(uri.toString());
    final bytes = byteData.buffer.asUint8List();
    if (bytes.isEmpty) {
      throw Exception('failed to load image: $u');
    }
    if (_imageCache.length >= _imageCacheMax) {
      _imageCache.remove(_imageCache.keys.first);
    }
    _imageCache[u] = bytes;
    return bytes;
  }

  ImageProvider getImageProvider(String url) {
    final cached = _imageCache[url];
    if (cached != null) return MemoryImage(cached);
    return NetworkImage(url);
  }

  void clearImageCache() => _imageCache.clear();

  String _normalizeArabic(String input) {
    var s = input.trim();
    const diacritics = r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]';
    s = s.replaceAll(RegExp(diacritics), '');
    s = s.replaceAll('\u0640', '');
    s = s.replaceAll(RegExp(r'[^\u0600-\u06FF0-9\s]'), '');
    s = s.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
    s = s.replaceAll('ى', 'ي');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  Future<List<Map<String, String>>> listTafsirEditions() async {
    final raw = await cloud.listTafsirEditions();
    return raw.map((m) {
      final id = (m['identifier'] ?? m['id'] ?? '').toString();
      final name = (m['name'] ?? m['englishName'] ?? id).toString();
      return {'id': id, 'name': name};
    }).toList();
  }

  Future<String> getAyahTafsir(int surah, int ayah, String editionId) {
    return cloud.getAyahTafsir(surah: surah, ayah: ayah, editionId: editionId);
  }

  Future<List<String>> getSurahAudioUrls(String editionId, int surah) async {
    final map = await cloud.getSurahAudio(editionId, surah);
    final data = map['data'];
    if (data is Map && data['ayahs'] is List) {
      final ayahs = data['ayahs'] as List;
      return ayahs
          .map((e) => (e as Map)['audio'] as String?)
          .whereType<String>()
          .toList();
    }
    return <String>[];
  }
}
