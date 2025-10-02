import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/aya.dart';
import 'package:quranglow/core/model/surah.dart';
import 'package:quranglow/core/widget/error_widget.dart';
import 'package:quranglow/core/widget/loading_widget.dart';

final surahProvider =
    FutureProvider.family<Surah, (int chapter, String editionId)>((ref, args) {
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
  bool _uiVisible = false; // إظهار/إخفاء شريط علوي عند النقر

  @override
  void initState() {
    super.initState();
    _enterReadingMode();
  }

  Future<void> _enterReadingMode() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await WakelockPlus.enable(); // الشاشة تظل مفتوحة
  }

  Future<void> _exitReadingMode() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    await WakelockPlus.disable();
  }

  @override
  void dispose() {
    _exitReadingMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncSurah = ref.watch(
      surahProvider((widget.chapter, widget.editionId)),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface, // هادئ
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _uiVisible = !_uiVisible),
          child: Stack(
            children: [
              // المحتوى
              asyncSurah.when(
                loading: () => const Center(
                  child: LoadingWidget(message: 'جاري التحميل...'),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ErrorWidgetSimple(
                      message: 'تعذّر تحميل السورة',
                      onRetry: () => ref.invalidate(
                        surahProvider((widget.chapter, widget.editionId)),
                      ),
                    ),
                  ),
                ),
                data: (surah) => _SurahView(surah: surah),
              ),

              // شريط علوي عائم يظهر/يختفي بالنقر
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                top: _uiVisible ? 0 : -72,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
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
                          child: Text(
                            'سورة ${widget.chapter}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------------- عرض السورة والآيات ------------------------- */

class _SurahView extends StatelessWidget {
  const _SurahView({required this.surah});
  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        // ترويسة بسيطة
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Column(
              children: [
                Text(
                  surah.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Divider(color: cs.outlineVariant),
              ],
            ),
          ),
        ),

        // قائمة الآيات مع فواصل
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index.isOdd) return const Divider(height: 1);
            final i = index ~/ 2;
            if (i >= surah.ayat.length) return const SizedBox.shrink();
            return _AyaTile(aya: surah.ayat[i]);
          }, childCount: surah.ayat.isEmpty ? 0 : (surah.ayat.length * 2 - 1)),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
        ),
      ],
    );
  }
}

class _AyaTile extends StatelessWidget {
  const _AyaTile({required this.aya});
  final Aya aya;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${aya.number}',
            style: TextStyle(fontWeight: FontWeight.w700, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              aya.text,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 20, height: 1.9),
            ),
          ),
        ],
      ),
    );
  }
}
