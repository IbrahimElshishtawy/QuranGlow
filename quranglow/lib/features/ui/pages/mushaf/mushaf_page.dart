// ignore_for_file: deprecated_member_use, unnecessary_brace_in_string_interps
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/features/ui/pages/mushaf/widget/position_store.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/surah.dart';
import 'package:quranglow/core/model/aya.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';
import 'package:quranglow/features/ui/pages/mushaf/paged_mushaf.dart';
import 'package:quranglow/features/ui/pages/mushaf/widget/mushaf_top_bar.dart';

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
    int? initialAyah,
  });

  final int chapter;
  final String editionId;

  @override
  ConsumerState<MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends ConsumerState<MushafPage> {
  bool _uiVisible = false;
  late int _chapter;

  int? _lastAyahNumber;
  final _pos = PositionStore(); // ← NEW

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
    if (_chapter > 1) {
      setState(() {
        _chapter--;
        _lastAyahNumber = null;
      });
    }
  }

  void _goNext() {
    if (_chapter < 114) {
      setState(() {
        _chapter++;
        _lastAyahNumber = null;
      });
    }
  }

  Future<void> _saveCurrentPosition() async {
    final ayahIndex0 = (_lastAyahNumber ?? 1) - 1;
    await _pos.save(_chapter, ayahIndex0);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حفظ موضع القراءة')));
  }

  void _openTafsirForCurrent() {
    final ayahNum = _lastAyahNumber ?? 1;
    Navigator.pushNamed(
      context,
      AppRoutes.tafsirReader,
      arguments: TafsirArgs(surah: _chapter, ayah: ayahNum),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncSurah = ref.watch(surahProvider((_chapter, widget.editionId)));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            asyncSurah.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('تعذّر تحميل السورة'),
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
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (surah) => PagedMushaf(
                ayat: surah.ayat,
                surahName: surah.name,
                surahNumber: _chapter,
                showBasmala: surah.name.trim() != 'التوبة',
                initialSelectedAyah: null,
                onAyahTap: (int ayahNumber, Aya aya) {
                  _lastAyahNumber = ayahNumber;

                  Navigator.pushNamed(
                    context,
                    AppRoutes.tafsirReader,
                    arguments: TafsirArgs(surah: _chapter, ayah: ayahNumber),
                  );
                },
              ),
            ),

            // Toggle UI overlay
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
              onTafsir: _openTafsirForCurrent,
            ),
          ],
        ),
      ),
    );
  }
}
