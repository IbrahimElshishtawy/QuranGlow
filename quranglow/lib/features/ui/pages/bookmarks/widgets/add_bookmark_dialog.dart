// ignore_for_file: use_build_context_synchronously, deprecated_member_use, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/book/bookmark.dart';

Future<void> showAddBookmarkDialog(BuildContext context, WidgetRef ref) async {
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
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      isDense: true,
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
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      isDense: true,
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
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      minLines: 1,
                      maxLines: 3,
                      onChanged: (v) => note = v.trim().isNotEmpty ? v : null,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظة (اختياري)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
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
