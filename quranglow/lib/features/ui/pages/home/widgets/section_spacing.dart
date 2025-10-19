// lib/features/ui/pages/home/widgets/section_spacing.dart
import 'package:flutter/material.dart';

class SectionSpacing extends StatelessWidget {
  final Widget child;
  const SectionSpacing({super.key, required this.child});
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), child: child);
}
