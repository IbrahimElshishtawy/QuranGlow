// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'error_card.dart';

class TafsirCard extends StatelessWidget {
  const TafsirCard({
    super.key,
    required this.tafsir,
    required this.editionName,
  });

  final AsyncValue<String> tafsir;
  final String? editionName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return tafsir.when(
      loading: () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const LinearProgressIndicator(),
      ),
      error: (e, _) => ErrorCard(msg: 'خطأ في جلب التفسير: $e'),
      data: (text) => Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التفسير',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          editionName?.isNotEmpty == true
                              ? editionName!
                              : 'مصدر التفسير الحالي',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'نسخ',
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('تم النسخ')));
                    },
                    icon: const Icon(Icons.copy_outlined, size: 20),
                  ),
                  IconButton(
                    tooltip: 'مشاركة',
                    onPressed: () => Share.share(text),
                    icon: const Icon(Icons.share_outlined, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                text.isEmpty ? 'لا يوجد نص تفسير متاح.' : text,
                textAlign: TextAlign.justify,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.95,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
