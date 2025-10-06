import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({super.key, required this.current, required this.total});
  final int current, total;

  String _toArabicDigits(int n) {
    const map = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) => map[int.parse(c)]).join();
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
