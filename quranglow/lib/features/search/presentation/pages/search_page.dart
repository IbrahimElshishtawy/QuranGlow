import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/features/mushaf/presentation/pages/mushaf_page.dart';
import 'package:quranglow/features/search/presentation/providers/search_providers.dart';
import 'package:quranglow/features/search/presentation/widgets/highlighted.dart';

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

  void _submit([String? _]) => setState(() => _q = _c.text.trim());

  void _clear() {
    _c.clear();
    setState(() => _q = '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final asyncResults = ref.watch(searchResultsProvider(_q));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: _SearchAppBar(
          controller: _c,
          onChanged: (text) {
            if (text.trim().length >= 2) _submit();
            setState(() {});
          },
          onSubmitted: _submit,
          onClear: _clear,
          onSearch: _submit,
        ),
        body: Column(
          children: [
            const Divider(height: 1),
            Expanded(
              child: asyncResults.when(
                data: (results) {
                  if (_q.isEmpty) return const _Idle();
                  if (results.isEmpty) return const _Empty();
                  final editionId = ref.read(editionIdForSearchProvider);

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final r = results[i];
                      return Card(
                        elevation: 0,
                        color: cs.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.7),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Highlighted(text: r.text, query: _q),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${r.surahName} • ${r.surah}:${r.ayah}',
                            ),
                          ),
                          trailing: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.chevron_left_rounded,
                              color: cs.primary,
                            ),
                          ),
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
                        ),
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
                      style: theme.textTheme.bodyMedium,
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

class _SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SearchAppBar({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onSearch,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onSearch;

  @override
  Size get preferredSize => const Size.fromHeight(138);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppBar(
      toolbarHeight: 138,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              cs.primary.withValues(alpha: 0.18),
              cs.tertiary.withValues(alpha: 0.10),
              cs.surface,
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
                ),
                child: Icon(Icons.manage_search_rounded, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'البحث',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ابحث في الآيات والسور بسرعة',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'ابحث في الآيات والسور...',
              prefixIcon: Icon(Icons.search_rounded, color: cs.primary),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.text.isNotEmpty)
                    IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'مسح',
                    ),
                  IconButton.filledTonal(
                    onPressed: onSearch,
                    tooltip: 'بحث',
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              filled: true,
              fillColor: cs.surface.withValues(alpha: 0.84),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: cs.primary, width: 1.4),
              ),
            ),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ],
      ),
    );
  }
}

class _Idle extends StatelessWidget {
  const _Idle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.travel_explore_rounded,
                size: 34,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ابدأ بكتابة كلمة أو آية',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر النتائج فورًا عند كتابة حرفين أو أكثر.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 42,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد نتائج مطابقة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
