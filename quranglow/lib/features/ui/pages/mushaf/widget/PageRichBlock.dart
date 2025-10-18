import 'package:flutter/material.dart';
import 'package:quranglow/core/model/aya/aya.dart';
import 'package:quranglow/features/ui/pages/mushaf/paged_mushaf.dart';

class PageRichBlock extends StatelessWidget {
  const PageRichBlock({
    super.key,
    required this.ayat,
    required this.range,
    required this.onTapIndex,
    this.currentAyahIndex,
    this.showBasmala = false,
    this.basmalaText = '﷽',
    this.ayahNumberColor,
  });

  final List<Aya> ayat;
  final PageRange range;
  final void Function(int index0) onTapIndex;
  final int? currentAyahIndex;
  final bool showBasmala;
  final String basmalaText;
  final Color? ayahNumberColor;

  @override
  Widget build(BuildContext context) {}
}
