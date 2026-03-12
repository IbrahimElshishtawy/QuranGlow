// lib/features/ui/pages/player/player_page.dart
// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/data/surah_names_ar.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/aya/aya.dart';
import 'package:quranglow/core/model/book/surah.dart';
import 'package:quranglow/core/service/audio/audio_locator.dart';
import 'package:quranglow/features/player/presentation/widgets/reader_row.dart';
import 'package:quranglow/features/player/presentation/widgets/track_card.dart';
import 'package:quranglow/features/player/presentation/widgets/transport_controls.dart';
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
      if (!isAudioHandlerReady) return;
      await next.when(
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
        loading: () async {},
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
    final surahs = AsyncValue.data(
      List<Surah>.generate(
        kSurahNamesAr.length,
        (i) => Surah(
          number: i + 1,
          name: kSurahNamesAr[i],
          ayat: const <Aya>[],
        ),
        growable: false,
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: _PlayerAppBar(
          surahName: kSurahNamesAr[ch - 1],
          onOpenLibrary: () =>
              Navigator.pushNamed(context, AppRoutes.downloadsLibrary),
          onDownload: () => _downloadCurrent(context, ref),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cs.primary.withValues(alpha: 0.06), cs.surface],
            ),
          ),
          child: SafeArea(
            top: false,
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
                      onChapterChanged: (v) => ref
                          .read(playerControllerProvider.notifier)
                          .changeChapter(v),
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
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
                    child: TrackCard(),
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

class _PlayerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _PlayerAppBar({
    required this.surahName,
    required this.onOpenLibrary,
    required this.onDownload,
  });

  final String surahName;
  final VoidCallback onOpenLibrary;
  final VoidCallback onDownload;

  @override
  Size get preferredSize => const Size.fromHeight(112);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppBar(
      toolbarHeight: 112,
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
            bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.55)),
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
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(Icons.graphic_eq_rounded, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'التشغيل',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'سورة $surahName • استماع وتنزيل سريع',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: Row(
            children: [
              _PlayerAppBarAction(
                tooltip: 'المكتبة الصوتية',
                icon: Icons.library_music_rounded,
                onPressed: onOpenLibrary,
              ),
              const SizedBox(width: 8),
              _PlayerAppBarAction(
                tooltip: 'تنزيل السورة',
                icon: Icons.download_rounded,
                onPressed: onDownload,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayerAppBarAction extends StatelessWidget {
  const _PlayerAppBarAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: cs.surface.withValues(alpha: 0.82),
        foregroundColor: cs.primary,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
      ),
      icon: Icon(icon),
    );
  }
}
