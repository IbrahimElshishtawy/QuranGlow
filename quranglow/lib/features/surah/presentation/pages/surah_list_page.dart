import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quranglow/core/data/surah_names_ar.dart';
import 'package:quranglow/features/mushaf/presentation/pages/mushaf_page.dart';

class SurahListPage extends StatelessWidget {
  const SurahListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('قائمة السور'),
          centerTitle: true,
        ),
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
          itemCount: kSurahNamesAr.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final surahNumber = i + 1;
            final cs = Theme.of(context).colorScheme;

            return ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: cs.surfaceContainerHigh.withValues(alpha: 0.72),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.75),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        cs.primary.withValues(alpha: 0.14),
                        cs.surface.withValues(alpha: 0.25),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary.withValues(alpha: 0.16),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        _toArabicDigits(surahNumber),
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    title: Text(
                      kSurahNamesAr[i],
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      'سورة رقم ${_toArabicDigits(surahNumber)}',
                      style: TextStyle(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.90),
                        fontSize: 12,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: cs.primary,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MushafPage(chapter: surahNumber),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _toArabicDigits(int n) {
    const east = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final b = StringBuffer();
    for (final ch in n.toString().split('')) {
      final d = int.tryParse(ch);
      b.write(d == null ? ch : east[d]);
    }
    return b.toString();
  }
}
