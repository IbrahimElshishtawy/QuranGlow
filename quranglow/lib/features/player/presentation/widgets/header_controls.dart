// lib/features/ui/pages/player/widgets/header_card.dart
// ignore_for_file: deprecated_member_use, unused_element

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/data/surah_names_ar.dart';
import 'package:quranglow/core/di/providers.dart';

class HeaderCard extends ConsumerWidget {
  const HeaderCard({
    super.key,
    required this.editionId,
    required this.chapter,
    this.surahName,
    this.readerName,
  });

  final String editionId;
  final int chapter;
  final String? surahName;
  final String? readerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    // اسم السورة الآمن
    final String safeSurahName = (surahName?.trim().isNotEmpty == true)
        ? surahName!.trim()
        : (chapter >= 1 && chapter < kSurahNamesAr.length
              ? kSurahNamesAr[chapter]
              : 'سورة $chapter');

    // سطر القارئ
    Widget readerLine;
    if (readerName != null && readerName!.trim().isNotEmpty) {
      readerLine = Text('القارئ: $readerName', style: t.bodyMedium);
    } else {
      final editions = ref.watch(audioEditionsProvider);
      readerLine = editions.when(
        loading: () => Text('القارئ: …', style: t.bodyMedium),
        error: (e, _) => Text('القارئ: $editionId', style: t.bodyMedium),
        data: (list) {
          String name = editionId;
          try {
            final m = list.cast<Map>().firstWhere(
              (e) => (e['identifier'] ?? e['id'] ?? '').toString() == editionId,
              orElse: () => const {},
            );
            if (m.isNotEmpty) {
              name = (m['name'] ?? m['englishName'] ?? editionId).toString();
            }
          } catch (_) {}
          return Text('القارئ: $name', style: t.bodyMedium);
        },
      );
    }

    // سطر اسم السورة (المطلوب تحت القارئ)
    final Widget surahLine = Opacity(
      opacity: .85,
      child: Text('السورة: $safeSurahName', style: t.bodyMedium),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh.withOpacity(.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outlineVariant.withOpacity(.4)),
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 6),
                    readerLine,
                    const SizedBox(height: 6),
                    surahLine, // ← هنا يظهر اسم السورة تحت القارئ
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: -6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
