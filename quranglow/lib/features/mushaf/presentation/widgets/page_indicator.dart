// lib/features/ui/pages/mushaf/widgets/page_indicator.dart
import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({super.key, required this.current, required this.total});
  final int current, total;

  String _toArabicDigits(int n) {
    const east = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final s = n.toString();
    final b = StringBuffer();
    for (final ch in s.runes) {
      final c = String.fromCharCode(ch);
      final d = int.tryParse(c);
      b.write(d == null ? c : east[d]);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${_toArabicDigits(current)} / ${_toArabicDigits(total)}',
          style: TextStyle(color: cs.outline),
        ),
      ],
    );
  }
}
