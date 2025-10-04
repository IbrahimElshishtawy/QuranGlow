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
    surahName: (m['surahName'] ?? '').toString(),
    text: (m['text'] ?? '').toString(),
  );
}

final _editionIdProvider = Provider<String>((_) => 'quran-uthmani');

final searchResultsProvider = FutureProvider.autoDispose
    .family<List<SearchHit>, String>((ref, query) async {
      final q = query.trim();
      if (q.length < 2) return const [];
      final service = ref.read(quranServiceProvider);
      final editionId = ref.read(_editionIdProvider);
      final raw = await service.searchAyat(q, editionId: editionId, limit: 100);
      return (raw as List)
          .cast<Map<String, dynamic>>()
          .map(SearchHit.fromMap)
          .toList();
    });

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _c = TextEditingController(text: '');
  String _q = '';

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _submit([String? _]) {
    setState(() => _q = _c.text.trim());
  }

  void _clear() {
    _c.clear();
    setState(() => _q = '');
  }

  @override
  Widget build(BuildContext context) {
    final asyncResults = ref.watch(searchResultsProvider(_q));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _c,
                textInputAction: TextInputAction.search,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'ابحث في الآيات والسور…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_c.text.isNotEmpty)
                        IconButton(
                          onPressed: _clear,
                          icon: const Icon(Icons.clear),
                          tooltip: 'مسح',
                        ),
                      IconButton(
                        onPressed: _submit,
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'بحث',
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (t) {
                  // بحث حي بسيط بعد 2 حرف
                  if (t.trim().length >= 2) _submit();
                  setState(() {}); // لتحديث زر المسح
                },
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
                        title: _Highlighted(text: r.text, query: _q),
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

class _Highlighted extends StatelessWidget {
  final String text;
  final String query;
  const _Highlighted({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    final q = query.trim();
    if (q.isEmpty) return Text(text, textDirection: TextDirection.rtl);
    final idx = text.indexOf(q);
    if (idx < 0) return Text(text, textDirection: TextDirection.rtl);

    final pre = text.substring(0, idx);
    final mid = text.substring(idx, idx + q.length);
    final post = text.substring(idx + q.length);
    final hiStyle = const TextStyle(fontWeight: FontWeight.w700);

    return RichText(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(text: pre),
          TextSpan(text: mid, style: hiStyle),
          TextSpan(text: post),
        ],
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
