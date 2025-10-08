// lib/features/ui/pages/mushaf/span_builder.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:test/core/model/aya/aya.dart';

class AyahSpanBuilder {
  AyahSpanBuilder({required this.onAyahTap});

  final void Function(int index) onAyahTap;

  static const _base = TextStyle(
    fontSize: 20,
    height: 1.9,
    fontFamilyFallback: ['Noto Naskh Arabic', 'Scheherazade'],
  );

  List<InlineSpan> buildSpans({
    required List<Aya> ayat,
    required bool showBasmala,
    required String basmala,
    required int? currentAyahIndex,
    required List<TapGestureRecognizer> recognizersBucket,
  }) {
    final out = <InlineSpan>[];

    if (showBasmala) {
      out.add(TextSpan(text: '$basmala  ', style: _base));
    }

    // نظّف recognizers القديمة (المستلم يتولّى التخلص منها عند dispose)
    for (final r in recognizersBucket) {
      r.dispose();
    }
    recognizersBucket.clear();

    for (var i = 0; i < ayat.length; i++) {
      final a = ayat[i];

      final r = TapGestureRecognizer()..onTap = () => onAyahTap(i);
      recognizersBucket.add(r);

      final selected = currentAyahIndex == i;
      final s = selected
          ? _base.copyWith(backgroundColor: Colors.amber.withOpacity(.18))
          : _base;

      out.add(TextSpan(text: '${a.text.trim()} ', style: s, recognizer: r));
      out.add(_ayahMarker(i, selected, onTap: () => onAyahTap(i)));
      out.add(const TextSpan(text: '  ', style: _base));
    }
    return out;
  }

  InlineSpan _ayahMarker(int ayahIndex, bool selected, {VoidCallback? onTap}) {
    final txt = _toArabicDigits(ayahIndex + 1);
    return TextSpan(
      text: ' \u06DD$txt ',
      style: TextStyle(
        fontSize: 14,
        height: 1.0,
        backgroundColor: selected ? Colors.amber.withOpacity(.18) : null,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
      ),
      recognizer: (TapGestureRecognizer()..onTap = onTap),
    );
  }

  String _toArabicDigits(int n) {
    const map = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) => map[int.parse(c)]).join();
  }
}
