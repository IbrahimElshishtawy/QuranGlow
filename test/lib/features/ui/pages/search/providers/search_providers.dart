import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/core/di/providers.dart';
import 'package:test/core/model/setting/search_hit.dart';

final editionIdForSearchProvider = Provider<String>((_) => 'quran-uthmani');

final searchResultsProvider = FutureProvider.autoDispose
    .family<List<SearchHit>, String>((ref, query) async {
      final q = query.trim();
      if (q.length < 2) return const [];
      final service = ref.read(quranServiceProvider);
      final editionId = ref.read(editionIdForSearchProvider);
      final raw = await service.searchAyat(q, editionId: editionId, limit: 100);
      return (raw as List)
          .cast<Map<String, dynamic>>()
          .map(SearchHit.fromMap)
          .toList();
    });
