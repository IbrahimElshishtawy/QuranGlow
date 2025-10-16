// ignore_for_file: depend_on_referenced_packages
import 'package:hive/hive.dart';
import 'package:quranglow/core/api/alquran_cloud_source.dart';

class TafsirRepo {
  TafsirRepo({required this.cloud});
  final AlQuranCloudSource cloud;

  static const _boxName = 'tafsir_cache';
  Future<Box> _box() => Hive.openBox(_boxName);

  String _key(String editionId, int surah, int ayah) =>
      '$editionId|$surah|$ayah';

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
    final data = await cloud.getSurahText('quran-uthmani', surah);
    final list = (data['data']?['ayahs'] as List?) ?? const [];
    final total = list.length;
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
