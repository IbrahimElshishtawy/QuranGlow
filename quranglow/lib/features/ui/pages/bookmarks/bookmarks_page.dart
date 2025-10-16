// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/book/bookmark.dart';
import 'package:quranglow/features/ui/pages/bookmarks/widgets/add_bookmark_dialog.dart';
import 'package:quranglow/features/ui/pages/bookmarks/widgets/bookmark_list_tile.dart';
import 'package:quranglow/features/ui/pages/bookmarks/widgets/empty_bookmarks_view.dart';

class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});

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
          onPressed: () => showAddBookmarkDialog(context, ref),
          icon: const Icon(Icons.bookmark_add),
          label: const Text('إضافة'),
        ),
        body: items.isEmpty
            ? const EmptyBookmarksView()
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final b = items[i];
                  return BookmarkListTile(
                    bookmark: b,
                    index: i,
                    ref: ref,
                    colorScheme: cs,
                  );
                },
              ),
      ),
    );
  }
}
