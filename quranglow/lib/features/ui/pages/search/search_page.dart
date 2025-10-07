import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/features/ui/pages/mushaf/mushaf_page.dart';
import 'package:quranglow/features/ui/pages/search/providers/search_providers.dart';
import 'widgets/highlighted.dart';

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

  void _submit([String? _]) => setState(() => _q = _c.text.trim());
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
                  if (_q.isEmpty) return const _Idle();
                  if (results.isEmpty) return const _Empty();
                  final editionId = ref.read(editionIdForSearchProvider);
                  return ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final r = results[i];
                      return ListTile(
                        title: Highlighted(text: r.text, query: _q),
                        subtitle: Text('${r.surahName} • ${r.surah}:${r.ayah}'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MushafPage(
                                chapter: r.surah,
                                editionId: editionId,

                                initialAyah: r.ayah,
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

class _Idle extends StatelessWidget {
  const _Idle();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('ابدأ الكتابة ثم اضغط بحث'));
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('لا توجد نتائج مطابقة'));
}
