// lib/features/ui/pages/ayah/ayah_detail_page.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/aya.dart';
import 'package:quranglow/core/model/surah.dart';
import 'package:quranglow/features/ui/pages/player/controller/player_controller_provider.dart';

class AyahDetailPage extends ConsumerStatefulWidget {
  const AyahDetailPage({
    super.key,
    required this.aya,
    required this.surah,
    this.tafsir,
    this.tafsirEditionId = 'ar-tafsir-muyassar', // يمكنك تغييره
    this.reciterId, // إن لم يُمرّر نستخدم المختار من المشغّل
  });

  final Aya aya;
  final Surah surah;
  final String? tafsir;
  final String tafsirEditionId;
  final String? reciterId;

  @override
  ConsumerState<AyahDetailPage> createState() => _AyahDetailPageState();
}

class _AyahDetailPageState extends ConsumerState<AyahDetailPage> {
  final _player = AudioPlayer();
  String? _audioUrl;
  String? _tafsirText;
  bool _loadingTafsir = false;
  bool _loadingAudio = false;

  int get _ayahNumInSurah {
    // يفضّل numberInSurah إن وُجد وإلا استخدم number
    final nIn = (widget.aya as dynamic).numberInSurah;
    final n = (nIn is int && nIn > 0) ? nIn : widget.aya.number;
    return n;
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // tafsir
    if (widget.tafsir != null && widget.tafsir!.trim().isNotEmpty) {
      _tafsirText = widget.tafsir!;
    } else {
      _loadingTafsir = true;
      setState(() {});
      try {
        final service = ref.read(quranServiceProvider);
        _tafsirText = await service.getAyahTafsir(
          widget.surah.number,
          _ayahNumInSurah,
          widget.tafsirEditionId,
        );
      } catch (_) {
        _tafsirText = null;
      } finally {
        _loadingTafsir = false;
        if (mounted) setState(() {});
      }
    }

    // audio
    _loadingAudio = true;
    setState(() {});
    try {
      final effectiveReciterId =
          widget.reciterId ?? ref.read(editionIdProvider);
      final service = ref.read(quranServiceProvider);
      final urls = await service.getSurahAudioUrls(
        effectiveReciterId!,
        widget.surah.number,
      );
      final idx = _ayahNumInSurah - 1;
      if (idx >= 0 && idx < urls.length) {
        _audioUrl = urls[idx];
        await _player.setUrl(_audioUrl!);
      } else {
        _audioUrl = null;
      }
    } catch (_) {
      _audioUrl = null;
    } finally {
      _loadingAudio = false;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                '﴿${widget.aya.text}﴾',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 22, height: 1.8),
              ),
              const SizedBox(height: 12),
              Text(
                '${widget.surah.name} • آية $_ayahNumInSurah',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),

              // الصوت
              Card(
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
                      if (_loadingAudio)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (_audioUrl != null)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () => _player.play(),
                              tooltip: 'تشغيل',
                            ),
                            IconButton(
                              icon: const Icon(Icons.pause),
                              onPressed: () => _player.pause(),
                              tooltip: 'إيقاف مؤقت',
                            ),
                            IconButton(
                              icon: const Icon(Icons.stop),
                              onPressed: () => _player.stop(),
                              tooltip: 'إيقاف',
                            ),
                          ],
                        )
                      else
                        Text(
                          'لا تتوفر تلاوة لهذه الآية لهذا القارئ',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      const Spacer(),
                      Text(
                        widget.reciterId ?? ref.watch(editionIdProvider),
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
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
                  child: _loadingTafsir
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Text(
                            (_tafsirText != null &&
                                    _tafsirText!.trim().isNotEmpty)
                                ? _tafsirText!
                                : 'لا يوجد تفسير متاح.',
                            textAlign: TextAlign.right,
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
