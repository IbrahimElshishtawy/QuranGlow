import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/setting/search_hit.dart';

final editionIdForSearchProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.maybeWhen(
    data: (s) =>
        s.readerEditionId.trim().isEmpty ? 'quran-uthmani' : s.readerEditionId,
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
