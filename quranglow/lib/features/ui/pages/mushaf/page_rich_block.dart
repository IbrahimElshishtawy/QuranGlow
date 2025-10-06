// ignore_for_file: dead_code, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:quranglow/core/model/aya.dart';
import 'package:quranglow/features/ui/pages/mushaf/widget/span_builder.dart';

class PageRange {
  const PageRange({required this.start, required this.end});
  final int start;
  final int end;
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
  });

  final List<Aya> ayat;
  final PageRange range;
  final bool showBasmala;
  final String basmalaText;
  final int? currentAyahIndex;
  final void Function(int index) onTapIndex;

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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: RichText(
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        strutStyle: const StrutStyle(fontSize: 22, height: 2.0),
        text: TextSpan(
          style: TextStyle(
            color: textColor,
            fontFamilyFallback: [
              'KFGQPC Uthmanic Script',
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
    );
  }

  int? _mapToLocal(int global, int start, int end) {
    if (global < start || global >= end) return null;
    return global - start;
  }
}
