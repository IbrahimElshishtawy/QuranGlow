// lib/features/ui/pages/mushaf/span_builder.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quranglow/core/model/aya/aya.dart';

class AyahSpanBuilder {
  AyahSpanBuilder({required this.onAyahTap});
  final void Function(int index) onAyahTap;

  final Map<int, List<InlineSpan>> _cache = {};

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
    Color? ayahNumberColor,
    required List<TapGestureRecognizer> recognizersBucket,
  }) {
    final cacheKey = Object.hash(
      ayat.first.number,
      ayat.last.number,
      showBasmala,
      currentAyahIndex,
    );
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final out = <InlineSpan>[];
    if (showBasmala) {
      out.add(TextSpan(text: '$basmala  ', style: _base));
    }
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
      out.add(
        _ayahMarker(
          i,
          selected,
          ayahNumberColor: ayahNumberColor,
          recognizersBucket: recognizersBucket,
          onTap: () => onAyahTap(i),
        ),
      );
      out.add(const TextSpan(text: '  ', style: _base));
    }
    _cache[cacheKey] = out;
    return out;
  }

  InlineSpan _ayahMarker(
    int ayahIndex,
    bool selected, {
    VoidCallback? onTap,
    Color? ayahNumberColor,
    required List<TapGestureRecognizer> recognizersBucket,
  }) {
    final txt = _toArabicDigits(ayahIndex + 1);
    final markerTap = TapGestureRecognizer()..onTap = onTap;
    recognizersBucket.add(markerTap);
    return TextSpan(
      text: ' \u06DD$txt ',
      style: TextStyle(
        fontSize: 14,
        height: 1.0,
        color: ayahNumberColor,
        backgroundColor: selected ? Colors.amber.withOpacity(.18) : null,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
      ),
      recognizer: markerTap,
    );
  }

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
}
