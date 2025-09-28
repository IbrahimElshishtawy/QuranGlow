import 'package:flutter/material.dart';
import 'package:quranglow/core/model/aya.dart';

class AyaText extends StatelessWidget {
  final Aya aya;
  final double fontSize;
  const AyaText({super.key, required this.aya, this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Text(
        aya.text,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: TextStyle(fontSize: fontSize, height: 2),
      ),
    );
  }
}
