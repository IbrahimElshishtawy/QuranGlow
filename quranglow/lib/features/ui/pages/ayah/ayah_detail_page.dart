// lib/features/ui/pages/ayah/ayah_detail_page.dart
// ignore_for_file: deprecated_member_use, implementation_imports, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/aya/aya.dart';
import 'package:quranglow/core/model/book/surah.dart';
import 'package:quranglow/features/ui/pages/ayah/widgets/ayah_audio_card.dart';
import 'package:quranglow/features/ui/pages/player/controller/player_controller_provider.dart';
import 'package:riverpod/src/framework.dart';

class AyahDetailPage extends ConsumerWidget {
  const AyahDetailPage({
    super.key,
    required this.aya,
    required this.surah,
    this.tafsir,
    this.tafsirEditionId = 'ar-tafsir-muyassar',
    this.reciterId,
  });

  final Aya aya;
  final Surah surah;
  final String? tafsir;
  final String tafsirEditionId;
  final String? reciterId;

  int _ayahNumInSurah(Aya a) {
    final nIn = (a as dynamic).numberInSurah;
    final n = (nIn is int && nIn > 0) ? nIn : a.number;
    return n;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ayahNo = _ayahNumInSurah(aya);

    // ثبّت قيمة القارئ كسلسلة غير null
    final String effectiveReciterId =
        reciterId ?? (ref.watch(editionIdProvider) as String?) ?? 'ar.alafasy';

    // وحّد النوع: AsyncValue<String>
    final AsyncValue<String> tafsirAsync =
        (tafsir != null && tafsir!.trim().isNotEmpty)
        ? AsyncValue<String>.data(tafsir!)
        : ref.watch(
            tafsirFutureProvider((
                  surah: surah.number,
                  ayah: ayahNo,
                  editionId: tafsirEditionId,
                ))
                as ProviderListenable<AsyncValue<String>>,
          );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الآية'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // النص
              Text(
                '﴿${aya.text}﴾',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 22, height: 1.8),
              ),
              const SizedBox(height: 12),
              Text(
                '${surah.name} • آية $ayahNo',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),

              // الصوت
              AyahAudioCard(
                surah: surah.number,
                ayahInSurah: ayahNo,
                reciterIdLabel: effectiveReciterId, // String غير nullable
                effectiveReciterId: effectiveReciterId, // String غير nullable
              ),

              const SizedBox(height: 16),

              // التفسير
              const Text(
                'تفسير مختصر:',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: tafsirAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('لا يوجد تفسير متاح.'),
                    data: (t) => SingleChildScrollView(
                      child: Text(
                        t.trim().isNotEmpty ? t : 'لا يوجد تفسير متاح.',
                        textAlign: TextAlign.right,
                      ),
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
