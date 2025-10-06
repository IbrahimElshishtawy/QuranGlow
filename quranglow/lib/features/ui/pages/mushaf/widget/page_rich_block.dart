// lib/features/ui/pages/mushaf/widget/page_rich_block.dart
// ignore_for_file: dead_code, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:quranglow/core/model/aya.dart';

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
        strutStyle: const StrutStyle(fontSize: 20, height: 1.9),
        text: TextSpan(
          style: TextStyle(color: textColor),
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

// ملاحظة: وفّر هذا الـ Builder في ملفك المناسب.
// هنا تعريف توقيعه فقط لتجنب أخطاء التجميع إن لم يكن مستورداً.
typedef AyahTap = void Function(int index);

class AyahSpanBuilder {
  AyahSpanBuilder({required this.onAyahTap});
  final AyahTap onAyahTap;

  List<InlineSpan> buildSpans({
    required List<Aya> ayat,
    required bool showBasmala,
    required String basmala,
    required int? currentAyahIndex,
    required List<TapGestureRecognizer> recognizersBucket,
  }) {
    final spans = <InlineSpan>[];

    if (showBasmala) {
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              basmala,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
      spans.add(const TextSpan(text: '  '));
    }

    for (var i = 0; i < ayat.length; i++) {
      final rec = TapGestureRecognizer()..onTap = () => onAyahTap(i);
      recognizersBucket.add(rec);

      final isSel = currentAyahIndex == i;
      spans.add(
        TextSpan(
          text: ayat[i].text, // عدّل حسب نموذج Aya عندك
          recognizer: rec,
          style: TextStyle(
            fontSize: 20,
            backgroundColor: isSel ? Colors.amber.withOpacity(.25) : null,
          ),
        ),
      );
      // رقم الآية الصغير
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ),
      );
      spans.add(const TextSpan(text: '  '));
    }

    return spans;
  }
}
