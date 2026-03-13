import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quranglow/core/di/providers.dart';

class AyahAudioCard extends ConsumerStatefulWidget {
  const AyahAudioCard({
    super.key,
    required this.surah,
    required this.ayahInSurah,
    required this.reciterIdLabel,
    required this.effectiveReciterId,
    this.initialAudioUrl,
  });

  final int surah;
  final int ayahInSurah;
  final String reciterIdLabel;
  final String effectiveReciterId;
  final String? initialAudioUrl;

  @override
  ConsumerState<AyahAudioCard> createState() => _AyahAudioCardState();
}

class _AyahAudioCardState extends ConsumerState<AyahAudioCard> {
  late final AudioPlayer _player;
  StreamSubscription<PlayerState>? _playerStateSub;

  String? _targetUrl;
  bool _isPreparing = false;
  bool _isReady = false;
  bool _isPlaying = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _playerStateSub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
        }
      });
    });
    unawaited(_primeAudio());
  }

  @override
  void didUpdateWidget(covariant AyahAudioCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed =
        oldWidget.surah != widget.surah ||
        oldWidget.ayahInSurah != widget.ayahInSurah ||
        oldWidget.effectiveReciterId != widget.effectiveReciterId ||
        oldWidget.initialAudioUrl != widget.initialAudioUrl;
    if (changed) {
      _targetUrl = null;
      _isReady = false;
      _hasError = false;
      unawaited(_primeAudio(force: true));
    }
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _primeAudio({bool force = false, bool autoPlay = false}) async {
    if (_isPreparing) return;

    final resolvedUrl = await _resolveUrl();
    if (!mounted || resolvedUrl == null || resolvedUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isReady = false;
        });
      }
      return;
    }

    if (!force && _targetUrl == resolvedUrl && _isReady) {
      if (autoPlay) {
        await _player.play();
      }
      return;
    }

    setState(() {
      _isPreparing = true;
      _hasError = false;
    });

    try {
      _targetUrl = resolvedUrl;
      await _player.setUrl(resolvedUrl);
      if (!mounted) return;
      setState(() {
        _isReady = true;
      });
      if (autoPlay) {
        await _player.play();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isReady = false;
      });
    } finally {
      if (mounted) {
        setState(() => _isPreparing = false);
      }
    }
  }

  Future<String?> _resolveUrl() async {
    final inlineUrl = widget.initialAudioUrl?.trim();
    if (inlineUrl != null && inlineUrl.isNotEmpty) {
      return inlineUrl;
    }

    final urls = await ref.read(
      surahAudioUrlsProvider((
        surah: widget.surah,
        reciterId: widget.effectiveReciterId,
      )).future,
    );

    final idx = widget.ayahInSurah - 1;
    if (idx < 0 || idx >= urls.length) return null;
    return urls[idx];
  }

  Future<void> _handleMainTap() async {
    await HapticFeedback.selectionClick();

    if (_hasError || !_isReady) {
      await _primeAudio(force: _hasError, autoPlay: true);
      return;
    }

    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _handleStop() async {
    await _player.stop();
    if (!mounted) return;
    setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isActive = _isPlaying || _isPreparing;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isActive
              ? [
                  cs.primary.withValues(alpha: .20),
                  cs.secondary.withValues(alpha: .10),
                ]
              : [
                  cs.surface,
                  cs.surfaceContainerLowest,
                ],
        ),
        border: Border.all(
          color: isActive ? cs.primary.withValues(alpha: .55) : cs.outlineVariant,
          width: isActive ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? cs.primary.withValues(alpha: .16)
                : Colors.black.withValues(alpha: .04),
            blurRadius: isActive ? 18 : 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: _handleMainTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? cs.primary.withValues(alpha: .18)
                        : cs.surfaceContainerHigh,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _isPreparing
                          ? SizedBox(
                              key: const ValueKey('loading'),
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.3,
                                color: cs.primary,
                              ),
                            )
                          : Icon(
                              _hasError
                                  ? Icons.refresh_rounded
                                  : _isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              key: ValueKey(
                                _hasError
                                    ? 'retry'
                                    : _isPlaying
                                    ? 'pause'
                                    : 'play',
                              ),
                              color: cs.primary,
                              size: 28,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _hasError
                            ? 'تعذر تجهيز صوت الآية'
                            : _isPreparing
                            ? 'جارٍ تجهيز التلاوة'
                            : _isPlaying
                            ? 'يتم تشغيل الآية الآن'
                            : _isReady
                            ? 'اضغط للتشغيل السريع'
                            : 'جاري تحميل صوت الآية',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _hasError
                            ? 'اضغط لإعادة المحاولة'
                            : 'القارئ: ${widget.reciterIdLabel}',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _isReady ? 1 : .45,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionPill(
                        icon: _isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        active: isActive,
                        onTap: _handleMainTap,
                      ),
                      const SizedBox(width: 8),
                      _ActionPill(
                        icon: Icons.stop_circle_rounded,
                        active: false,
                        onTap: _isReady ? _handleStop : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      scale: active ? 1.04 : 1,
      child: Material(
        color: active
            ? cs.primary.withValues(alpha: .14)
            : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 20,
              color: active ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
