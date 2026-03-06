import 'package:flutter/material.dart';

class Highlighted extends StatelessWidget {
  final String text;
  final String query;
  const Highlighted({super.key, required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    final q = query.trim();
    if (q.isEmpty) return Text(text, textDirection: TextDirection.rtl);
    final idx = text.indexOf(q);
    if (idx < 0) return Text(text, textDirection: TextDirection.rtl);

    final pre = text.substring(0, idx);
    final mid = text.substring(idx, idx + q.length);
    final post = text.substring(idx + q.length);
    const hiStyle = TextStyle(fontWeight: FontWeight.w700);

    return RichText(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(text: pre),
          TextSpan(text: mid, style: hiStyle),
          TextSpan(text: post),
        ],
      ),
    );
  }
}
