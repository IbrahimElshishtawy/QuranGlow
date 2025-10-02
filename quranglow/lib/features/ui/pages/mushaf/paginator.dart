// lib/features/ui/pages/mushaf/paginator.dart

import 'package:flutter/material.dart';

class PageChunk {
  PageChunk(this.span);
  final TextSpan span;
}

List<PageChunk> paginate(BuildContext context, List<InlineSpan> spans) {
  final media = MediaQuery.of(context);
  final maxWidth = media.size.width - 32;
  final maxHeight =
      media.size.height -
      media.padding.top -
      media.padding.bottom -
      16 /*title*/ -
      6 -
      1 /*divider*/ -
      8 -
      8 /*bottom gap*/ -
      18 /*footer*/;

  final textScaler = MediaQuery.textScalerOf(context);

  final pages = <PageChunk>[];
  var start = 0;
  while (start < spans.length) {
    var low = start + 1, high = spans.length, fit = start + 1;
    while (low <= high) {
      final mid = (low + high) >> 1;
      final tp = TextPainter(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.justify,
        maxLines: null,
        textScaler: textScaler,
        strutStyle: const StrutStyle(fontSize: 20, height: 1.9),
        text: TextSpan(children: spans.sublist(start, mid)),
      )..layout(maxWidth: maxWidth);

      if (tp.height <= maxHeight) {
        fit = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    pages.add(PageChunk(TextSpan(children: spans.sublist(start, fit))));
    start = fit;
  }
  return pages;
}
