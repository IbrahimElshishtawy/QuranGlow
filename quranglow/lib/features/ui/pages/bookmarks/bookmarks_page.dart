// ignore_for_file: deprecated_member_use, use_build_context_synchronously, no_leading_underscores_for_local_identifiers
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';

import 'package:quranglow/core/model/aya.dart';
import 'package:quranglow/core/model/bookmark.dart';
import 'package:quranglow/core/model/surah.dart';
import 'package:quranglow/features/ui/routes/app_router.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});

  Future<void> _openAyah(
    BuildContext context,
    WidgetRef ref,
    Bookmark b,
  ) async {
    final uc = ref.read(bookmarksUseCaseProvider);
    final (Surah surah, Aya? aya) = await uc.resolveAyah(b.surah, b.ayah);
    if (aya == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذّر إيجاد الآية')));
      return;
    }
    if (!context.mounted) return;
    Navigator.pushNamed(
      context,
      AppRoutes.ayah,
      arguments: AyahArgs(aya: aya, surah: surah, tafsir: null),
    );
  }

  Future<void> _addBookmarkDialog(BuildContext context, WidgetRef ref) async {
    final cs = Theme.of(context).colorScheme;
    final uc = ref.read(bookmarksUseCaseProvider);

    int surah = 1;
    int ayah = 1;
    String? note;
    int ayatCount = 7;

    try {
      ayatCount = await uc.getAyatCount(surah);
    } catch (_) {}

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSt) {
            Future<void> _onSurahChanged(int v) async {
              setSt(() {
                surah = v;
                ayah = 1;
              });
              try {
                final c = await uc.getAyatCount(surah);
                if (context.mounted) {
                  setSt(() {
                    ayatCount = c;
                    if (ayah > ayatCount) ayah = ayatCount;
                  });
                }
              } catch (_) {
                if (context.mounted) {
                  setSt(() {
                    ayatCount = 1;
                    ayah = 1;
                  });
                }
              }
            }

            return AlertDialog(
              title: const Text('إضافة إشارة مرجعية'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: surah,
                    items: List.generate(
                      114,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('سورة رقم ${i + 1}'),
                      ),
                    ),
                    onChanged: (v) {
                      if (v != null) _onSurahChanged(v);
                    },
                    decoration: const InputDecoration(
                      labelText: 'السورة',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: ayah,
                    items: List.generate(
                      ayatCount,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('آية ${i + 1}'),
                      ),
                    ),
                    onChanged: (v) => setSt(() => ayah = v ?? 1),
                    decoration: InputDecoration(
                      labelText: 'الآية (1–$ayatCount)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    onChanged: (v) => note = v.trim().isNotEmpty ? v : null,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظة (اختياري)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () {
                    ref
                        .read(bookmarksProvider.notifier)
                        .add(
                          Bookmark(
                            surah: surah,
                            ayah: ayah,
                            note: note,
                            createdAt: DateTime.now(),
                          ),
                        );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تمت إضافة: سورة $surah • آية $ayah'),
                        backgroundColor: cs.primary,
                      ),
                    );
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(bookmarksProvider);
    final ctrl = ref.read(bookmarksProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المحفوظات'),
          centerTitle: true,
          actions: [
            if (items.isNotEmpty)
              IconButton(
                tooltip: 'حذف الكل',
                icon: const Icon(Icons.delete_sweep),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('حذف كل الإشارات؟'),
                      content: const Text('لا يمكن التراجع عن هذه العملية.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('إلغاء'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('حذف'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) ctrl.clearAll();
                },
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addBookmarkDialog(context, ref),
          icon: const Icon(Icons.bookmark_add),
          label: const Text('إضافة'),
        ),
        body: items.isEmpty
            ? Center(
                child: Text(
                  'لا توجد إشارات مرجعية بعد',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              )
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final b = items[i];
                  final nameAsync = ref.watch(surahNameProvider(b.surah));

                  return Dismissible(
                    key: ValueKey(
                      '${b.surah}-${b.ayah}-${b.createdAt.millisecondsSinceEpoch}',
                    ),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: cs.error,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => ctrl.removeAt(i),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cs.primary.withOpacity(.12),
                        child: Text(
                          '${b.ayah}',
                          style: TextStyle(color: cs.primary),
                        ),
                      ),
                      title: nameAsync.when(
                        data: (n) => Text(
                          'سورة $n',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        loading: () => const Text('جاري جلب اسم السورة...'),
                        error: (_, __) => Text('سورة ${b.surah}'),
                      ),
                      subtitle: Text(
                        '${b.note?.isNotEmpty == true ? '${b.note} • ' : ''}آية ${b.ayah}',
                      ),
                      trailing: IconButton(
                        tooltip: 'حذف',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ctrl.removeAt(i),
                      ),
                      onTap: () => _openAyah(context, ref, b),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
