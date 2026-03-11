import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/aya/aya.dart';
import 'package:quranglow/core/model/book/surah.dart';
import 'package:quranglow/features/mushaf/presentation/pages/paged_mushaf.dart';
import 'package:quranglow/features/mushaf/presentation/widgets/mushaf_top_bar.dart';
import 'package:quranglow/features/mushaf/presentation/widgets/position_store.dart';
import 'package:quranglow/features/tafsir/presentation/widgets/tafsir_args.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

final surahProvider = FutureProvider.autoDispose
    .family<Surah, (int chapter, String editionId)>((ref, args) async {
      final service = ref.read(quranServiceProvider);
      return service.getSurahText(args.$2, args.$1);
    });

class MushafPage extends ConsumerStatefulWidget {
  const MushafPage({
    super.key,
    this.chapter = 1,
    this.editionId = 'quran-uthmani',
    this.initialAyah,
  });

  final int chapter;
  final String editionId;
  final int? initialAyah;

  @override
  ConsumerState<MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends ConsumerState<MushafPage> {
  bool _uiVisible = false;
  late int _chapter;
  int? _lastAyahNumber;

  final _pos = PositionStore();
  final _ayahPreviewPlayer = AudioPlayer();
  final GlobalKey<PagedMushafState> _pagedMushafKey = GlobalKey<PagedMushafState>();

  @override
  void initState() {
    super.initState();
    _chapter = widget.chapter.clamp(1, 114);
    _lastAyahNumber = widget.initialAyah;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      await WakelockPlus.enable();
    });
  }

  @override
  void dispose() {
    _ayahPreviewPlayer.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    WakelockPlus.disable();
    super.dispose();
  }

  String _audioEditionId() {
    final settings = ref.read(settingsProvider);
    return settings.maybeWhen(
      data: (s) => s.readerEditionId.trim().isEmpty ? 'ar.alafasy' : s.readerEditionId,
      orElse: () => 'ar.alafasy',
    );
  }

  void _goPrev() {
    if (_chapter <= 1) return;
    setState(() {
      _chapter--;
      _lastAyahNumber = null;
    });
    _pagedMushafKey.currentState?.animateToPage(0);
  }

  void _goNext() {
    if (_chapter >= 114) return;
    setState(() {
      _chapter++;
      _lastAyahNumber = null;
    });
    _pagedMushafKey.currentState?.animateToPage(0);
  }

  Future<void> _saveCurrentPosition() async {
    final ayahIndex0 = (_lastAyahNumber ?? 1) - 1;
    await _pos.save(_chapter, ayahIndex0);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('?? ??? ???? ???????')),
    );
  }

  void _openTafsirForAyah(int ayahNumber) {
    Navigator.pushNamed(
      context,
      AppRoutes.tafsirReader,
      arguments: TafsirArgs(chapter: _chapter, ayah: ayahNumber),
    );
  }

  void _copyAyahText(int ayahNumber, String ayahText) {
    final content = '$_chapter:$ayahNumber\n$ayahText';
    Clipboard.setData(ClipboardData(text: content));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('?? ??? ?????')),
    );
  }

  Future<void> _playAyahAudio(Aya aya, int ayahNumber) async {
    try {
      String? url = aya.audioUrl;
      if (url == null || url.trim().isEmpty) {
        final urls = await ref
            .read(quranServiceProvider)
            .getSurahAudioUrls(_audioEditionId(), _chapter);
        final idx = ayahNumber - 1;
        if (idx >= 0 && idx < urls.length) {
          url = urls[idx];
        }
      }

      if (url == null || url.trim().isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('?? ???? ???? ??? ???? ?????')),
        );
        return;
      }

      await _ayahPreviewPlayer.setUrl(url);
      await _ayahPreviewPlayer.play();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('???? ????? ????? $ayahNumber')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('???? ????? ?????: $e')),
      );
    }
  }

  Future<void> _openAyahActions({
    required int ayahNumber,
    required Aya aya,
  }) async {
    setState(() {
      _lastAyahNumber = ayahNumber;
      _uiVisible = true;
    });

    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '????? $ayahNumber',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  aya.text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _playAyahAudio(aya, ayahNumber);
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('????? ?????'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _openTafsirForAyah(ayahNumber);
                        },
                        icon: const Icon(Icons.menu_book_rounded),
                        label: const Text('???????'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _copyAyahText(ayahNumber, aya.text);
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('??? ?? ?????'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncSurah = ref.watch(surahProvider((_chapter, widget.editionId)));
    final selectedAyahText = asyncSurah.maybeWhen(
      data: (surah) {
        final selected = _lastAyahNumber;
        if (selected == null) return null;
        final idx = selected - 1;
        if (idx < 0 || idx >= surah.ayat.length) return null;
        return surah.ayat[idx].text;
      },
      orElse: () => null,
    );

    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cs.surface, cs.surfaceContainerLowest],
            ),
          ),
          child: Stack(
            children: [
              asyncSurah.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('???? ????? ??????'),
                        const SizedBox(height: 8),
                        Text(
                          '$e',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => ref.refresh(
                            surahProvider((_chapter, widget.editionId)),
                          ),
                          child: const Text('????? ????????'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (surah) => PagedMushaf(
                  key: _pagedMushafKey,
                  ayat: surah.ayat,
                  surahName: surah.name,
                  surahNumber: _chapter,
                  showBasmala: surah.name.trim() != '??????',
                  initialSelectedAyah: _lastAyahNumber,
                  onAyahTap: (int ayahNumber, Aya aya) {
                    setState(() {
                      _lastAyahNumber = ayahNumber;
                      _uiVisible = true;
                    });
                  },
                  onAyahLongPress: (int ayahNumber, Aya aya) {
                    _openAyahActions(ayahNumber: ayahNumber, aya: aya);
                  },
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => setState(() => _uiVisible = !_uiVisible),
                ),
              ),
              MushafTopBar(
                visible: _uiVisible,
                asyncSurah: asyncSurah,
                chapter: _chapter,
                onBack: () => Navigator.pop(context),
                onPrev: _chapter > 1 ? _goPrev : null,
                onNext: _chapter < 114 ? _goNext : null,
                onSave: _saveCurrentPosition,
                onTafsir: () => _openTafsirForAyah(_lastAyahNumber ?? 1),
              ),
              _SelectedAyahPanel(
                visible: _lastAyahNumber != null && selectedAyahText != null,
                ayahNumber: _lastAyahNumber,
                ayahText: selectedAyahText,
                onClear: () => setState(() => _lastAyahNumber = null),
                onOpenTafsir: () => _openTafsirForAyah(_lastAyahNumber ?? 1),
                onPlay: () {
                  final ayahNum = _lastAyahNumber;
                  final surah = asyncSurah.valueOrNull;
                  if (ayahNum == null || surah == null) return;
                  final idx = ayahNum - 1;
                  if (idx < 0 || idx >= surah.ayat.length) return;
                  _playAyahAudio(surah.ayat[idx], ayahNum);
                },
                onCopy: () {
                  final text = selectedAyahText;
                  final ayahNum = _lastAyahNumber;
                  if (text == null || ayahNum == null) return;
                  _copyAyahText(ayahNum, text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedAyahPanel extends StatelessWidget {
  const _SelectedAyahPanel({
    required this.visible,
    required this.ayahNumber,
    required this.ayahText,
    required this.onClear,
    required this.onOpenTafsir,
    required this.onPlay,
    required this.onCopy,
  });

  final bool visible;
  final int? ayahNumber;
  final String? ayahText;
  final VoidCallback onClear;
  final VoidCallback onOpenTafsir;
  final VoidCallback onPlay;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0, 1.1),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '????? ${ayahNumber ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        onPressed: onClear,
                        icon: const Icon(Icons.close_rounded),
                        tooltip: '????? ???????',
                      ),
                    ],
                  ),
                  if (ayahText != null && ayahText!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        ayahText!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onPlay,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('??????'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onOpenTafsir,
                          icon: const Icon(Icons.menu_book_rounded),
                          label: const Text('??? ???????'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('??? ?????'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
