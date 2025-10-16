// lib/core/repo/tafsir_repo.dart
// ignore_for_file: depend_on_referenced_packages, unused_local_variable

import 'package:hive/hive.dart';
import 'package:quranglow/core/api/alquran_cloud_source.dart';

class TafsirRepo {
  TafsirRepo({required this.cloud});
  final AlQuranCloudSource cloud;

  static const _boxName = 'tafsir_cache';
  Future<Box> _box() => Hive.openBox(_boxName);

  String _key(String editionId, int surah, int ayah) =>
      '$editionId|$surah|$ayah';

  Map<String, dynamic> _normalize(Object? raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _root(Map<String, dynamic> j) {
    final a = j['chapter'];
    final b = j['data'];
    if (a is Map) return _normalize(a);
    if (b is Map) return _normalize(b);
    return j;
  }

  int _ayahCount(Map<String, dynamic> root) {
    final v = root['ayahs'] ?? root['verses'] ?? root['aya'] ?? root['list'];
    if (v is List) return v.length;

    final meta = root['surah'] ?? root['meta'];
    if (meta is Map) {
      final c = meta['numberOfAyahs'] ?? meta['ayahsCount'];
      if (c is int) return c;
      if (c is String) return int.tryParse(c) ?? 0;
    }
    return 0;
  }

  Future<String> getTafsir({
    required String editionId,
    required int surah,
    required int ayah,
  }) async {
    final box = await _box();
    final k = _key(editionId, surah, ayah);

    final cached = box.get(k);
    if (cached is String && cached.trim().isNotEmpty) return cached;

    final text = await cloud.getAyahTafsir(
      surah: surah,
      ayah: ayah,
      editionId: editionId,
    );
    await box.put(k, text);
    return text;
  }

  Future<void> prefetchSurah(
    String editionId,
    int surah, {
    void Function(int done, int total)? onProgress,
  }) async {
    final raw = await cloud.getSurahText('quran-uthmani', surah);
    final normalized = _normalize(raw);
    final root = _root(normalized);
    final total = _ayahCount(root);

    if (total <= 0) {
      const hardMax = 286;
      int done = 0;
      for (var i = 1; i <= hardMax; i++) {
        try {
          await getTafsir(editionId: editionId, surah: surah, ayah: i);
          done = i;
          onProgress?.call(i, hardMax);
        } catch (_) {
          break;
        }
      }
      return;
    }

    for (var i = 1; i <= total; i++) {
      await getTafsir(editionId: editionId, surah: surah, ayah: i);
      onProgress?.call(i, total);
    }
  }

  Future<void> prefetchAll(
    String editionId, {
    void Function(int s, int total)? onProgress,
  }) async {
    const total = 114;
    for (var s = 1; s <= total; s++) {
      await prefetchSurah(editionId, s);
      onProgress?.call(s, total);
    }
  }

  Future<void> clear() async {
    final box = await _box();
    await box.clear();
  }
}
