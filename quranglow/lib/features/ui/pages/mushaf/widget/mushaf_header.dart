// lib/features/ui/pages/mushaf/widgets/mushaf_header.dart
import 'package:flutter/material.dart';

class MushafHeader extends StatelessWidget {
  const MushafHeader({super.key, required this.surahName});
  final String surahName;
  @override
  Widget build(BuildContext context) {
    return Text(
      surahName,
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
    );
  }
}
