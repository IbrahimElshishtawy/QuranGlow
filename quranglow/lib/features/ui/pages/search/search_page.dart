// lib/features/ui/pages/search/search_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/features/ui/pages/mushaf/mushaf_page.dart';

class SearchHit {
  final int surah;
  final int ayah;
  final String surahName;
  final String text;
  const SearchHit({
    required this.surah,
    required this.ayah,
    required this.surahName,
    required this.text,
  });
  factory SearchHit.fromMap(Map<String, dynamic> m) => SearchHit(
    surah: (m['surahNumber'] as num).toInt(),
    ayah: (m['ayahNumber'] as num).toInt(),
    surahName: m['surahName'] as String,
    text: m['text'] as String,
  );
}

final _editionIdProvider = Provider<String>((_) => 'quran-uthmani');

final searchResultsProvider = FutureProvider.autoDispose
    .family<List<SearchHit>, String>((ref, query) async {
      if (query.trim().isEmpty) return const [];
      final service = ref.read(quranServiceProvider);
      final editionId = ref.read(_editionIdProvider);
      final raw = await service.searchAyat(query.trim(), editionId: editionId);
      return (raw as List)
          .cast<Map<String, dynamic>>()
          .map(SearchHit.fromMap)
          .toList(growable: false);
    });

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _c = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _submit([String? _]) {
    setState(() => _q = _c.text);
  }

  @override
  Widget build(BuildContext context) {
    final asyncResults = ref.watch(searchResultsProvider(_q));
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بحث'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _submit,
              tooltip: 'بحث',
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _c,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'ابحث في الآيات والسور...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: _submit,
                    icon: const Icon(Icons.search),
                    tooltip: 'بحث',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: _submit,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: asyncResults.when(
                data: (results) {
                  if (_q.isEmpty) return const _IdleState();
                  if (results.isEmpty) return const _EmptyState();
                  return ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final r = results[i];
                      return ListTile(
                        title: Text(r.text, textDirection: TextDirection.rtl),
                        subtitle: Text('${r.surahName} • ${r.surah}:${r.ayah}'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MushafPage(
                                chapter: r.surah,
                                editionId: ref.read(_editionIdProvider),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'حدث خطأ أثناء البحث: $e',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdleState extends StatelessWidget {
  const _IdleState();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('ابدأ الكتابة ثم اضغط بحث'));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('لا توجد نتائج مطابقة'));
  }
}
