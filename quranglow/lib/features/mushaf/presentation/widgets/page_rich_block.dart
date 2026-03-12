import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/aya/aya.dart';
import 'package:quranglow/core/model/book/topic.dart';
import 'package:quranglow/features/mushaf/presentation/widgets/span_builder.dart';

class PageRange {
  final int start;
  final int end;

  const PageRange({required this.start, required this.end});

  bool contains(int idx) => idx >= start && idx < end;
}

class PageRichBlock extends ConsumerStatefulWidget {
  const PageRichBlock({
    super.key,
    required this.ayat,
    required this.range,
    required this.showBasmala,
    required this.basmalaText,
    required this.currentAyahIndex,
    required this.onTapIndex,
    required this.onLongPressIndex,
    this.ayahNumberColor,
  });

  final List<Aya> ayat;
  final PageRange range;
  final bool showBasmala;
  final String basmalaText;
  final int? currentAyahIndex;
  final void Function(int index) onTapIndex;
  final void Function(int index) onLongPressIndex;
  final Color? ayahNumberColor;

  @override
  ConsumerState<PageRichBlock> createState() => _PageRichBlockState();
}

class _PageRichBlockState extends ConsumerState<PageRichBlock> {
  final List<GestureRecognizer> _recognizers = [];

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.range.start < 0 ||
        widget.range.end > widget.ayat.length ||
        widget.range.start >= widget.range.end) {
      return const SizedBox.shrink();
    }

    final subAyat = widget.ayat.sublist(widget.range.start, widget.range.end);
    if (subAyat.isEmpty) {
      return const SizedBox.shrink();
    }

    final fontScale = ref.watch(
      settingsProvider.select(
        (value) => value.maybeWhen(data: (s) => s.fontScale, orElse: () => 1.0),
      ),
    );

    final localCurrentIndex = widget.currentAyahIndex == null
        ? null
        : _mapToLocal(
            widget.currentAyahIndex!,
            widget.range.start,
            widget.range.end,
          );

    _disposeRecognizers();

    final builder = AyahSpanBuilder(
      fontScale: fontScale,
      onAyahTap: (localIndex) => widget.onTapIndex(widget.range.start + localIndex),
      onAyahLongPress: (localIndex) =>
          widget.onLongPressIndex(widget.range.start + localIndex),
    );

    final spans = builder.buildSpans(
      ayat: subAyat,
      currentAyahIndex: localCurrentIndex,
      ayahNumberColor: widget.ayahNumberColor,
      recognizersBucket: _recognizers,
    );

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? cs.onSurface : const Color(0xFF2E2212);
    final paperBase = isDark
        ? const Color(0xFF18140E)
        : const Color(0xFFF8F1DF);
    final paperEdge = isDark
        ? const Color(0xFF30291D)
        : const Color(0xFFE3D4B4);
    final paperOverlay = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : const Color(0xFFFFFBF2).withValues(alpha: 0.70);

    final currentTopics = mockTopics
        .where(
          (t) =>
              t.surah == subAyat.first.surah &&
              subAyat.any(
                (a) =>
                    a.numberInSurah >= t.startAyah &&
                    a.numberInSurah <= t.endAyah,
              ),
        )
        .toList(growable: false);

    return LayoutBuilder(
      builder: (context, c) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [paperOverlay, paperBase],
            ),
            border: Border.all(color: paperEdge, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 10,
                right: 12,
                child: Opacity(
                  opacity: 0.20,
                  child: Icon(Icons.auto_awesome, size: 16, color: cs.primary),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 12,
                child: Opacity(
                  opacity: 0.20,
                  child: Icon(Icons.auto_awesome, size: 16, color: cs.primary),
                ),
              ),
              ScrollConfiguration(
                behavior: const _NoGlowBehavior(),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (c.maxHeight - 10).clamp(0, double.infinity),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.showBasmala) ...[
                          Text(
                            widget.basmalaText,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: textColor,
                              fontFamily: 'KFGQPC Uthmanic Script',
                              fontFamilyFallback: const [
                                'Hafs',
                                'Noto Naskh Arabic',
                                'Scheherazade',
                              ],
                              height: 1.9,
                              fontSize: 28 * fontScale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        RichText(
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                          strutStyle: StrutStyle(
                            fontSize: 24 * fontScale,
                            height: 2.15,
                          ),
                          text: TextSpan(
                            style: TextStyle(
                              color: textColor,
                              fontFamily: 'KFGQPC Uthmanic Script',
                              fontFamilyFallback: const [
                                'Hafs',
                                'Noto Naskh Arabic',
                                'Scheherazade',
                              ],
                              height: 2.15,
                              fontSize: 24 * fontScale,
                              letterSpacing: 0.15,
                            ),
                            children: spans,
                          ),
                        ),
                        if (currentTopics.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: currentTopics
                                .map(
                                  (topic) => Chip(
                                    label: Text(
                                      topic.title,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: cs.secondaryContainer,
                                    labelStyle: TextStyle(
                                      color: cs.onSecondaryContainer,
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int? _mapToLocal(int global, int start, int end) {
    if (global < start || global >= end) return null;
    return global - start;
  }
}

class _NoGlowBehavior extends ScrollBehavior {
  const _NoGlowBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
