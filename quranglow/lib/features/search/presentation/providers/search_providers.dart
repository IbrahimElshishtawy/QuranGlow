import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/setting/search_hit.dart';

final editionIdForSearchProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.maybeWhen(
    data: (s) {
      final editionId = s.readerEditionId.trim();
      if (editionId.isEmpty) return 'quran-uthmani';
      final lower = editionId.toLowerCase();
      final looksLikeAudioEdition =
          lower.startsWith('ar.') ||
          lower.contains('audio') ||
          lower.contains('alafasy') ||
          lower.contains('ajamy') ||
          lower.contains('hudhaify') ||
          lower.contains('minshawi') ||
          lower.contains('sudais');
      return looksLikeAudioEdition ? 'quran-uthmani' : editionId;
    },
    orElse: () => 'quran-uthmani',
  );
});

final searchResultsProvider =
    FutureProvider.autoDispose.family<List<SearchHit>, String>((ref, query) async {
      final q = query.trim();
      if (q.length < 2) return const <SearchHit>[];

      final editionId = ref.watch(editionIdForSearchProvider);
      final service = ref.read(quranServiceProvider);
      final raw = await service.searchAyat(
        q,
        editionId: editionId,
        limit: 100,
      );
      return raw.map(SearchHit.fromMap).toList(growable: false);
    });
