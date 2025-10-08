// lib/features/ui/pages/player/player_page.dart
// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/features/ui/pages/player/controller/player_controller_provider.dart';
import 'package:quranglow/features/ui/pages/player/widgets/header_controls.dart';
import 'package:quranglow/features/ui/pages/player/widgets/reader_row.dart';
import 'package:quranglow/features/ui/pages/player/widgets/transport_controls.dart';
import 'package:quranglow/features/ui/pages/downloads/controller/download_controller.dart';
import 'package:quranglow/features/ui/pages/downloads/downloads_library_page.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

class PlayerPage extends ConsumerWidget {
  const PlayerPage({super.key});

  Future<void> _downloadCurrent(BuildContext context, WidgetRef ref) async {
    final cs = Theme.of(context).colorScheme;
    final editionId = ref.read(editionIdProvider);
    final chapter = ref.read(chapterProvider);
    final service = ref.read(quranServiceProvider);

    // مؤشّر تحميل صغير أثناء تجهيز الروابط
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final urls = await service.getSurahAudioUrls(editionId, chapter);
      Navigator.of(context).pop(); // أغلق المؤشر

      if (urls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('لا توجد روابط صوت'),
            backgroundColor: cs.error,
          ),
        );
        return;
      }

      await ref
          .read(downloadControllerProvider.notifier)
          .downloadSurah(surah: chapter, reciterId: editionId, ayahUrls: urls);

      if (context.mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.downloadDetail,
          arguments: {'surah': chapter, 'reciterId': editionId},
        );
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // أغلق المؤشر لو مفتوح
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذّر بدء التنزيل: $e'),
          backgroundColor: cs.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ctrl = ref.watch(playerControllerProvider);

    final editions = ref.watch(audioEditionsProvider);
    final surahs = ref.watch(quranAllProvider('quran-uthmani'));

    final ed = ref.watch(editionIdProvider);
    final chapter = ref.watch(chapterProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cs.primary.withOpacity(.06), cs.surface],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, cons) {
                final kb = MediaQuery.of(context).viewInsets.bottom;

                return ListView(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + kb),
                  children: [
                    // بطاقة اختيار القارئ والسورة
                    Card(
                      elevation: 0,
                      color: cs.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: cs.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: ReaderRow(
                          editions: editions,
                          surahs: surahs,
                          selectedEditionId: ed,
                          selectedSurah: chapter,
                          onEditionChanged: (v) => ref
                              .read(playerControllerProvider.notifier)
                              .changeEdition(v),
                          onChapterSubmitted: (v) {
                            final n = int.tryParse(v) ?? chapter;
                            ref
                                .read(playerControllerProvider.notifier)
                                .changeChapter(n);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // بطاقة العنوان
                    Card(
                      elevation: 0,
                      color: cs.surfaceContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: cs.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                        child: HeaderCard(editionId: ed, chapter: chapter),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // أزرار الإجراءات
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _downloadCurrent(context, ref),
                            icon: const Icon(Icons.download),
                            label: const Text('تنزيل السورة'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const DownloadsLibraryPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.library_music),
                            label: const Text('المكتبة'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: BorderSide(color: cs.primary),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: cons.maxHeight * .08),

                    // عناصر التحكم
                    Center(
                      child: ctrl.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('تعذّر التحميل'),
                              const SizedBox(height: 8),
                              Text(
                                '$e',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        data: (s) => Card(
                          elevation: 0,
                          color: cs.surfaceContainerHigh,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: cs.outlineVariant),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: TransportControls(state: s),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: cons.maxHeight * .06),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
