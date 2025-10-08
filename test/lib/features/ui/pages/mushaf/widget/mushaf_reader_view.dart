// lib/features/ui/pages/mushaf/widgets/mushaf_reader_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/core/model/aya/aya.dart';
import 'package:test/core/model/book/surah.dart';
import 'package:test/features/ui/pages/mushaf/paged_mushaf.dart';

class MushafReaderView extends StatelessWidget {
  const MushafReaderView({
    super.key,
    required this.asyncSurah,
    required this.chapter,
    required this.onRetry,
    required this.onAyahTap,
  });

  final AsyncValue<Surah> asyncSurah;
  final int chapter;
  final VoidCallback onRetry;
  final void Function(int ayahNumber, Aya aya) onAyahTap;

  @override
  Widget build(BuildContext context) {
    return asyncSurah.when(
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
                onPressed: onRetry,
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
          key: ValueKey('surah-$chapter-${surah.ayat.length}'),
          child: PagedMushaf(
            ayat: surah.ayat,
            surahName: surah.name,
            surahNumber: chapter,
            showBasmala: surah.name.trim() != 'التوبة',
            initialSelectedAyah: null,
            onAyahTap: onAyahTap,
          ),
        ),
      ),
    );
  }
}
