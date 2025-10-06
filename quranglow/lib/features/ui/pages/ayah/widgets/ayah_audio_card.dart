// lib/features/ayah/widgets/ayah_audio_card.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quranglow/core/di/providers.dart';

class AyahAudioCard extends ConsumerStatefulWidget {
  const AyahAudioCard({
    super.key,
    required this.surah,
    required this.ayahInSurah, // 1-based
    required this.reciterIdLabel, // للعرض
    required this.effectiveReciterId, // للاستخدام الفعلي في الجلب
  });

  final int surah;
  final int ayahInSurah;
  final String reciterIdLabel;
  final String effectiveReciterId;

  @override
  ConsumerState<AyahAudioCard> createState() => _AyahAudioCardState();
}

class _AyahAudioCardState extends ConsumerState<AyahAudioCard> {
  final _player = AudioPlayer();
  String? _pickedUrl;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final urlsAsync = ref.watch(
      surahAudioUrlsProvider((
        surah: widget.surah,
        reciterId: widget.effectiveReciterId,
      )),
    );

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            urlsAsync.when(
              loading: () => const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => Text(
                'تعذّر تحميل الصوت',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              data: (urls) {
                final idx = widget.ayahInSurah - 1;
                if (idx < 0 || idx >= urls.length) {
                  return Text(
                    'لا تتوفر تلاوة لهذه الآية',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  );
                }
                _pickedUrl ??= urls[idx];
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      tooltip: 'تشغيل',
                      onPressed: () async {
                        if (_pickedUrl != null) {
                          await _player.setUrl(_pickedUrl!);
                          _player.play();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.pause),
                      tooltip: 'إيقاف مؤقت',
                      onPressed: () => _player.pause(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop),
                      tooltip: 'إيقاف',
                      onPressed: () => _player.stop(),
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            Text(
              widget.reciterIdLabel,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
