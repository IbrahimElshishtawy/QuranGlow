// lib/features/ui/pages/player/player_page.dart
// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/service/audio/audio_locator.dart';
import 'package:quranglow/features/ui/pages/player/controller/player_controller_provider.dart';
import 'package:quranglow/features/ui/pages/player/widgets/header_controls.dart';
import 'package:quranglow/features/ui/pages/player/widgets/reader_row.dart';
import 'package:quranglow/features/ui/pages/player/widgets/transport_controls.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key});

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  ProviderSubscription? _playbackSub;

  @override
  void initState() {
    super.initState();

    _playbackSub = ref.listenManual(playerControllerProvider, (
      prev,
      next,
    ) async {
      next.whenOrNull(
        data: (s) async {
          final bool isPlaying = (s.isPlaying ?? false);
          final String? url = s.currentUrl;
          final String title =
              (s.surahName ?? 'سورة') +
              (s.reciterName != null ? ' - ${s.reciterName}' : '');

          if (isPlaying && url != null && url.isNotEmpty) {
            await audioHandler.playUri(Uri.parse(url), title: title);
          } else if (!isPlaying) {
            await audioHandler.pause();
          }
        },
        error: (e, st) async {
          await audioHandler.stop();
        },
      );
    }, fireImmediately: false);
  }

  @override
  void dispose() {
    _playbackSub?.close();
    super.dispose();
  }

  Future<void> _downloadCurrent(BuildContext context, WidgetRef ref) async {
    final cs = Theme.of(context).colorScheme;
    final editionId = ref.read(editionIdProvider);
    final chapter = ref.read(chapterProvider).clamp(1, 114);
    final service = ref.read(quranServiceProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final urls = await service.getSurahAudioUrls(editionId, chapter);
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      if (urls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('لا توجد روابط صوت'),
            backgroundColor: cs.error,
          ),
        );
        return;
      }

      if (!context.mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.downloadDetail,
        arguments: {'surah': chapter, 'reciterId': editionId},
      );
    } catch (e) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذّر بدء التنزيل: $e'),
          backgroundColor: cs.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ctrl = ref.watch(playerControllerProvider);
    final ed = ref.watch(editionIdProvider);
    final ch = ref.watch(chapterProvider).clamp(1, 114);

    final editions = ref.watch(audioEditionsProvider);
    final surahs = ref.watch(quranAllProvider('quran-uthmani'));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cs.primary.withOpacity(.06), cs.surface],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
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
                      selectedSurah: ch,
                      onEditionChanged: (v) => ref
                          .read(playerControllerProvider.notifier)
                          .changeEdition(v),
                      onChapterSubmitted: (v) {
                        final n = (int.tryParse(v) ?? ch).clamp(1, 114);
                        ref
                            .read(playerControllerProvider.notifier)
                            .changeChapter(n);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  elevation: 0,
                  color: cs.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                    child: HeaderCard(editionId: ed, chapter: ch),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _downloadCurrent(context, ref),
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('تنزيل السورة'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.downloadsLibrary,
                        ),
                        icon: const Icon(Icons.library_music),
                        label: const Text('المكتبة'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                ctrl.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, st) => Card(
                    color: cs.errorContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'تعذّر التحميل: $e',
                        style: TextStyle(color: cs.onErrorContainer),
                      ),
                    ),
                  ),
                  data: (s) => Card(
                    elevation: 0,
                    color: cs.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TransportControls(state: s),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
