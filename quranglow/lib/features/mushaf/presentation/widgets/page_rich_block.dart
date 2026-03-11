// lib/features/ui/pages/mushaf/page_rich_block.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:quranglow/core/model/aya/aya.dart';
import 'package:quranglow/core/model/book/topic.dart';
import 'package:quranglow/features/mushaf/presentation/widgets/span_builder.dart';

class PageRange {
  final int start;
  final int end;
  const PageRange({required this.start, required this.end});
  bool contains(int idx) => idx >= start && idx < end;
}

class PageRichBlock extends StatefulWidget {
  const PageRichBlock({
    super.key,
    required this.ayat,
    required this.range,
    required this.showBasmala,
    required this.basmalaText,
    required this.currentAyahIndex,
    required this.onTapIndex,
    this.ayahNumberColor,
  });

  final List<Aya> ayat;
  final PageRange range;
  final bool showBasmala;
  final String basmalaText;
  final int? currentAyahIndex;
  final void Function(int index) onTapIndex;
  final Color? ayahNumberColor;

  @override
  State<PageRichBlock> createState() => _PageRichBlockState();
}

class _PageRichBlockState extends State<PageRichBlock> {
  final _recognizers = <TapGestureRecognizer>[];
  late final AyahSpanBuilder _builder;

  @override
  void initState() {
    super.initState();
    _builder = AyahSpanBuilder(onAyahTap: widget.onTapIndex);
  }

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subAyat = widget.ayat.sublist(widget.range.start, widget.range.end);
    final localCurrentIndex = widget.currentAyahIndex == null
        ? null
        : _mapToLocal(
            widget.currentAyahIndex!,
            widget.range.start,
            widget.range.end,
          );

    final spans = _builder.buildSpans(
      ayat: subAyat,
      showBasmala: widget.showBasmala,
      basmala: widget.basmalaText,
      currentAyahIndex: localCurrentIndex,
      recognizersBucket: _recognizers,
    );

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    final currentTopics = mockTopics
        .where(
          (t) =>
              t.surah == widget.ayat.first.surah &&
              subAyat.any(
                (a) =>
                    a.numberInSurah >= t.startAyah &&
                    a.numberInSurah <= t.endAyah,
              ),
        )
        .toList(growable: false);

    return LayoutBuilder(
      builder: (context, c) {
        return ScrollConfiguration(
          behavior: const _NoGlowBehavior(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 2),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RichText(
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                    strutStyle: const StrutStyle(fontSize: 22, height: 2.0),
                    text: TextSpan(
                      style: TextStyle(
                        color: textColor,
                        fontFamily: 'KFGQPC Uthmanic Script',
                        fontFamilyFallback: const [
                          'Hafs',
                          'Noto Naskh Arabic',
                          'Scheherazade',
                        ],
                        height: 2.0,
                        fontSize: 22,
                      ),
                      children: spans,
                    ),
                  ),
                  if (currentTopics.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
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
