// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/book/bookmark.dart';
import 'package:quranglow/core/model/book/surah.dart';
import 'package:quranglow/core/model/aya/aya.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';
import 'package:quranglow/features/ui/routes/app_router.dart';

class BookmarkListTile extends StatelessWidget {
  final Bookmark bookmark;
  final int index;
  final WidgetRef ref;
  final ColorScheme colorScheme;

  const BookmarkListTile({
    super.key,
    required this.bookmark,
    required this.index,
    required this.ref,
    required this.colorScheme,
  });

  Future<void> _openAyah(BuildContext context) async {
    final uc = ref.read(bookmarksUseCaseProvider);
    final (Surah surah, Aya? aya) = await uc.resolveAyah(
      bookmark.surah,
      bookmark.ayah,
    );
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

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.read(bookmarksProvider.notifier);
    final nameAsync = ref.watch(surahNameProvider(bookmark.surah));

    return Dismissible(
      key: ValueKey(
        '${bookmark.surah}-${bookmark.ayah}-${bookmark.createdAt.millisecondsSinceEpoch}',
      ),
      direction: DismissDirection.endToStart,
      background: Container(
        color: colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => ctrl.removeAt(index),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary.withOpacity(.12),
          child: Text(
            '${bookmark.ayah}',
            style: TextStyle(color: colorScheme.primary),
          ),
        ),
        title: nameAsync.when(
          data: (n) => Text(
            'سورة $n',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          loading: () => const Text('جاري جلب اسم السورة...'),
          error: (_, __) => Text('سورة ${bookmark.surah}'),
        ),
        subtitle: Text(
          '${bookmark.note?.isNotEmpty == true ? '${bookmark.note} • ' : ''}آية ${bookmark.ayah}',
        ),
        trailing: IconButton(
          tooltip: 'حذف',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => ctrl.removeAt(index),
        ),
        onTap: () => _openAyah(context),
      ),
    );
  }
}
