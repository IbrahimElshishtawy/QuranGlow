// lib/features/ui/pages/home/sections/last_read_card.dart
import 'package:flutter/material.dart';
import 'package:quranglow/features/ui/pages/home/widgets/section_title.dart';
import 'package:quranglow/features/ui/pages/mushaf/widget/position_store.dart';
import 'package:quranglow/features/ui/routes/app_router.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';
import 'package:quran/quran.dart' as quran;

class LastReadCard extends StatefulWidget {
  const LastReadCard({super.key});

  @override
  State<LastReadCard> createState() => _LastReadCardState();
}

class _LastReadCardState extends State<LastReadCard> {
  String _toArabicDigits(int n) {
    const map = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final s = n.toString();
    final b = StringBuffer();
    for (final ch in s.split('')) {
      final i = int.tryParse(ch);
      b.write(i == null ? ch : map[i]);
    }
    return b.toString();
  }

  Future<void> _openMushaf(BuildContext context, int surah, int ayah) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.mushaf,
      arguments: MushafArgs(chapter: surah, initialAyah: ayah),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<LastPosition?>(
      key: ValueKey(DateTime.now().millisecondsSinceEpoch ~/ 3000),
      future: PositionStore().loadLast(),
      builder: (context, snap) {
        final pos = snap.data;
        final hasPos = pos != null;

        final surahNum = hasPos ? pos.surah : 2;
        final ayahIdx0 = hasPos ? pos.ayahIndex : 254;
        final ayahNum = ayahIdx0 + 1;
        final surahName = quran.getSurahNameArabic(surahNum);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              'متابعة القراءة',
              actionText: 'فتح',
              onAction: () => _openMushaf(context, surahNum, ayahNum),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.menu_book, color: cs.primary, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasPos
                          ? 'آخر موضع: $surahName • آية ${_toArabicDigits(ayahNum)}'
                          : 'لا يوجد موضع محفوظ. ابدأ القراءة الآن.',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () => _openMushaf(context, surahNum, ayahNum),
                    child: Text(hasPos ? 'تابِع' : 'ابدأ'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
