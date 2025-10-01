import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/aya.dart';
import 'package:quranglow/core/model/surah.dart';
import 'package:quranglow/core/widget/error_widget.dart';
import 'package:quranglow/core/widget/loading_widget.dart';

final surahProvider =
    FutureProvider.family<Surah, (int chapter, String editionId)>((
      ref,
      args,
    ) async {
      final service = ref.read(quranServiceProvider);
      return service.getSurahText(args.$2, args.$1);
    });

class MushafPage extends ConsumerWidget {
  const MushafPage({
    super.key,
    this.chapter = 1,
    this.editionId = 'quran-uthmani',
  });

  final int chapter;
  final String editionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSurah = ref.watch(surahProvider((chapter, editionId)));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('المصحف • سورة $chapter'),
          centerTitle: true,
        ),
        body: asyncSurah.when(
          loading: () => const LoadingWidget(message: 'جاري تحميل السورة...'),
          error: (e, _) => ErrorWidgetSimple(
            message: 'تعذّر تحميل السورة',
            onRetry: () => ref.refresh(surahProvider((chapter, editionId))),
          ),
          data: (surah) => _SurahView(surah: surah),
        ),
      ),
    );
  }
}

class _SurahView extends StatelessWidget {
  const _SurahView({required this.surah});
  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
        SliverList.separated(
          itemCount: surah.ayat.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) => _AyaTile(aya: surah.ayat[i]),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
