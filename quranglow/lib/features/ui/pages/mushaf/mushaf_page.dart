// lib/features/ui/pages/mushaf/mushaf_page.dart
// ignore_for_file: deprecated_member_use, unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/features/ui/pages/mushaf/widget/mushaf_reader_view.dart';
import 'package:quranglow/features/ui/pages/mushaf/widget/mushaf_top_bar.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/surah.dart';
import 'package:quranglow/core/model/aya.dart';
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
  });

  final int chapter;
  final String editionId;

  @override
  ConsumerState<MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends ConsumerState<MushafPage> {
  bool _uiVisible = false;
  late int _chapter;

  @override
  void initState() {
    super.initState();
    _chapter = widget.chapter.clamp(1, 114);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await WakelockPlus.enable();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    WakelockPlus.disable();
    super.dispose();
  }

  void _goPrev() {
    if (_chapter > 1) setState(() => _chapter--);
  }

  void _goNext() {
    if (_chapter < 114) setState(() => _chapter++);
  }

  @override
  Widget build(BuildContext context) {
    final asyncSurah = ref.watch(surahProvider((_chapter, widget.editionId)));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            MushafReaderView(
              asyncSurah: asyncSurah,
              chapter: _chapter,
              onRetry: () =>
                  ref.refresh(surahProvider((_chapter, widget.editionId))),
              onAyahTap: (int ayahNumber, Aya aya) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.tafsirReader,
                  arguments: TafsirArgs(surah: _chapter, ayah: ayahNumber),
                );
              },
            ),

            // طبقة تبديل ظهور الـ UI
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => _uiVisible = !_uiVisible),
              ),
            ),

            // الشريط العلوي
            MushafTopBar(
              visible: _uiVisible,
              asyncSurah: asyncSurah,
              chapter: _chapter,
              onBack: () => Navigator.pop(context),
              onPrev: _chapter > 1 ? _goPrev : null,
              onNext: _chapter < 114 ? _goNext : null,
            ),
          ],
        ),
      ),
    );
  }
}
