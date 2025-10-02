// lib/features/ui/pages/mushaf/mushaf_page.dart
// ignore_for_file: deprecated_member_use, unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/features/ui/routes/app_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:quranglow/core/di/providers.dart'; // quranServiceProvider
import 'package:quranglow/core/model/surah.dart';
import 'package:quranglow/features/ui/pages/mushaf/paged_mushaf.dart';

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
    if (_chapter > 1) {
      setState(() => _chapter--);
      ref.invalidate(surahProvider((_chapter, widget.editionId)));
    }
  }

  void _goNext() {
    if (_chapter < 114) {
      setState(() => _chapter++);
      ref.invalidate(surahProvider((_chapter, widget.editionId)));
    }
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
                        onPressed: () => ref.invalidate(
                          surahProvider((_chapter, widget.editionId)),
                        ),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (surah) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: KeyedSubtree(
                  key: ValueKey('surah-${_chapter}-${surah.ayat.length}'),
                  child: PagedMushaf(
                    ayat: surah.ayat,
                    surahName: surah.name,
                    surahNumber: _chapter,
                    showBasmala: surah.name.trim() != 'التوبة',
                    initialSelectedAyah: null,
                    onAyahTap: (aya) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.ayah,
                        arguments: AyahArgs(
                          aya: aya,
                          surah: surah,
                          tafsir: null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // طبقة نقر لإظهار/إخفاء الشريط
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => _uiVisible = !_uiVisible),
              ),
            ),

            // شريط علوي + تنقل بين السور
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: IgnorePointer(
                  ignoring: !_uiVisible,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _uiVisible ? 1 : 0,
                    child: Container(
                      height: 56,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            color: Colors.white,
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: asyncSurah.maybeWhen(
                              data: (s) => Text(
                                s.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              orElse: () => Text(
                                'سورة $_chapter',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'السابق',
                            onPressed: _chapter > 1 ? _goPrev : null,
                            color: Colors.white,
                            icon: const Icon(Icons.skip_next), // RTL: للسابق
                          ),
                          IconButton(
                            tooltip: 'التالي',
                            onPressed: _chapter < 114 ? _goNext : null,
                            color: Colors.white,
                            icon: const Icon(
                              Icons.skip_previous,
                            ), // RTL: للتالي
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
