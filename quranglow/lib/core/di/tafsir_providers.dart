import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/api/alquran_cloud_source.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/book/surah.dart';
import 'package:quranglow/core/repo/tafsir_repo.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final quranAllProvider = FutureProvider.autoDispose.family<List<Surah>, String>(
  (ref, editionId) async {
    final service = ref.read(quranServiceProvider);
    return service.getQuranAllText(editionId);
  },
);

final tafsirCloudProvider = Provider<AlQuranCloudSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AlQuranCloudSource(dio: dio);
});

final tafsirRepoProvider = Provider<TafsirRepo>((ref) {
  final cloud = ref.watch(tafsirCloudProvider);
  return TafsirRepo(cloud: cloud);
});

final tafsirForAyahProvider = FutureProvider.autoDispose
    .family<String, (int surah, int ayah, String editionId)>((ref, args) async {
      final repo = ref.read(tafsirRepoProvider);
      return repo.getTafsir(editionId: args.$3, surah: args.$1, ayah: args.$2);
    });

final prefetchTafsirSurahProvider = FutureProvider.autoDispose
    .family<void, (String editionId, int surah)>((ref, args) async {
      final repo = ref.read(tafsirRepoProvider);
      await repo.prefetchSurah(args.$1, args.$2);
    });
