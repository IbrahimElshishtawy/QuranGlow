// ignore_for_file: implementation_imports, avoid_print, unnecessary_import

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show NetworkAssetBundle;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:quranglow/core/api/fawaz_cdn_source.dart';
import 'package:quranglow/core/api/alquran_cloud_source.dart';
import 'package:quranglow/core/model/aya/aya.dart';
import 'package:quranglow/core/model/book/surah.dart';

class QuranService {
  final FawazCdnSource fawaz;
  final AlQuranCloudSource cloud;
  QuranService({
    required this.fawaz,
    required this.cloud,
    required AlQuranCloudSource audio, // kept for ctor compatibility
  });

  final Map<String, Map<int, Surah>> _surahCacheByEdition = {};
  final Map<String, Uint8List> _imageCache = {};
  final int _imageCacheMax = 32;

  // de-dupe in-flight requests
  final Map<String, Future<Surah>> _inflight = {};

  // open Hive box once
  final Future<Box> _boxFuture = Hive.openBox('quran_cache');

  Duration _backoff(int attempt) =>
      Duration(milliseconds: (400 * (1 << attempt)).clamp(400, 8000));

  Future<Surah> getSurahText(String editionId, int chapter) async {
    final editionCache = _surahCacheByEdition.putIfAbsent(editionId, () => {});
    final cached = editionCache[chapter];
    if (cached != null) return cached;

    final key = '$editionId-$chapter';
    if (_inflight.containsKey(key)) return _inflight[key]!;

    final completer = Completer<Surah>();
    _inflight[key] = completer.future;

    try {
      final box = await _boxFuture;

      if (box.containsKey(key)) {
        final localJson = Map<String, dynamic>.from(box.get(key));
        final localSurah = await compute(_parseSurahJsonIsolate, {
          'json': localJson,
          'editionId': editionId,
          'chapter': chapter,
        });
        editionCache[chapter] = localSurah;
        debugPrint('[SRV][OFFLINE] loaded surah $chapter from local Hive');
        completer.complete(localSurah);
        return localSurah;
      }

      debugPrint('[SRV][ONLINE] fetch surah=$chapter ed=$editionId');

      // retry/backoff for 429/5xx/timeouts
      int attempt = 0;
      late Map<String, dynamic> json;
      while (true) {
        try {
          json = editionId == 'quran-uthmani'
              ? await cloud.getSurahText(editionId, chapter)
              : await fawaz.getSurah(editionId, chapter);
          break;
        } catch (e) {
          final msg = e.toString();
          final retryable =
              msg.contains('429') ||
              msg.contains(' 5') ||
              msg.contains('Timeout');
          if (!retryable || attempt >= 5) rethrow;
          await Future.delayed(_backoff(attempt++));
        }
      }

      await (await _boxFuture).put(key, json);
      final surah = await compute(_parseSurahJsonIsolate, {
        'json': json,
        'editionId': editionId,
        'chapter': chapter,
      });
      editionCache[chapter] = surah;
      completer.complete(surah);
      return surah;
    } finally {
      _inflight.remove(key);
    }
  }

  // parse on background isolate
  static Surah _parseSurahJsonIsolate(Map args) {
    return _parseSurahJson(
      Map<String, dynamic>.from(args['json']),
      args['editionId'] as String,
      args['chapter'] as int,
    );
  }

  static Surah _parseSurahJson(
    Map<String, dynamic> json,
    String editionId,
    int chapter,
  ) {
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

    return Surah(number: chapter, name: name, ayat: ayat.cast<Aya>());
  }

  /// Avoid calling this at startup. Prefer on-demand loading.
  Future<List<Surah>> getQuranAllText(String editionId) async {
    final out = <Surah>[];
    for (var i = 1; i <= 114; i++) {
      try {
        final s = await getSurahText(editionId, i);
        out.add(s);
        await Future.delayed(const Duration(milliseconds: 50)); // throttle
      } catch (e) {
        debugPrint('[SRV][ALL] skip $i: $e');
      }
    }
    return out;
  }

  Future<List> listAudioEditions() => cloud.listAudioEditions();
  Future<Map<String, dynamic>> getSurahAudio(String ed, int s) =>
      cloud.getSurahAudio(ed, s);

  // search without hitting network; only cache/Hive
  Future<List<Map<String, dynamic>>> searchAyat(
    String query, {
    required String editionId,
    int limit = 50,
  }) async {
    final q = _normalizeArabic(query);
    if (q.isEmpty) return const [];
    final cache = _surahCacheByEdition.putIfAbsent(editionId, () => {});
    final box = await _boxFuture;

    final hits = <Map<String, dynamic>>[];
    for (var s = 1; s <= 114; s++) {
      Surah? surah = cache[s];
      if (surah == null) {
        final key = '$editionId-$s';
        if (!box.containsKey(key)) continue;
        final json = Map<String, dynamic>.from(box.get(key));
        surah = await compute(_parseSurahJsonIsolate, {
          'json': json,
          'editionId': editionId,
          'chapter': s,
        });
        cache[s] = surah!;
      }
      for (final aya in surah.ayat) {
        if (_normalizeArabic(aya.text).contains(q)) {
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
    if (u.isEmpty) throw ArgumentError('empty url');
    final cached = _imageCache[u];
    if (cached != null) return cached;
    final uri = Uri.parse(u);
    final byteData = await NetworkAssetBundle(uri).load(uri.toString());
    final bytes = byteData.buffer.asUint8List();
    if (bytes.isEmpty) throw Exception('failed to load image: $u');
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
