// lib/features/ui/pages/player/player_page.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/features/ui/pages/player/controller/player_controller_provider.dart';
import 'package:quranglow/features/ui/pages/player/widgets/header_controls.dart';
import 'package:quranglow/features/ui/pages/player/widgets/reader_row.dart';
import 'package:quranglow/features/ui/pages/player/widgets/transport_controls.dart';

class PlayerPage extends ConsumerWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ctrl = ref.watch(playerControllerProvider);

    // الإصدارات الصوتية + السور (بالاسم) من الـ API
    final editions = ref.watch(audioEditionsProvider);
    final surahs = ref.watch(quranAllProvider('quran-uthmani'));

    // الحالة المختارة حاليًا من الكنترولر
    final ed = ref.watch(editionIdProvider);
    final chapter = ref.watch(chapterProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [cs.primary.withOpacity(.10), cs.surface],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, cons) {
                final kb = MediaQuery.of(context).viewInsets.bottom;

                return ListView(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + kb),
                  children: [
                    // اختيار القارئ + السورة بالاسم
                    ReaderRow(
                      editions: editions,
                      surahs: surahs, // ← AsyncValue<List<Surah>>
                      selectedEditionId: ed,
                      selectedSurah: chapter, // ← رقم السورة الحالي
                      onEditionChanged: (v) => ref
                          .read(playerControllerProvider.notifier)
                          .changeEdition(v),
                      onChapterSubmitted: (v) {
                        final n = int.tryParse(v) ?? chapter;
                        ref
                            .read(playerControllerProvider.notifier)
                            .changeChapter(n);
                      },
                    ),

                    const SizedBox(height: 16),

                    // كرت الهيدر (اسم السورة/القارئ)
                    HeaderCard(editionId: ed, chapter: chapter),

                    SizedBox(height: cons.maxHeight * .10),

                    // عناصر التحكم في التشغيل
                    Center(
                      child: ctrl.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('تعذّر التحميل'),
                              const SizedBox(height: 8),
                              Text(
                                '$e',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        data: (s) => TransportControls(state: s),
                      ),
                    ),

                    SizedBox(height: cons.maxHeight * .10),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
