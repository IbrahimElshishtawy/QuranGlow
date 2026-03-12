// lib/features/ui/pages/mushaf/span_builder.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quranglow/core/model/aya/aya.dart';

class AyahSpanBuilder {
  AyahSpanBuilder({
    required this.onAyahTap,
    required this.onAyahLongPress,
    required this.fontScale,
  });
  final void Function(int index) onAyahTap;
  final void Function(int index) onAyahLongPress;
  final double fontScale;

  final Map<int, List<InlineSpan>> _cache = {};

  TextStyle get _base => TextStyle(
    fontSize: 20 * fontScale,
    height: 1.9,
    fontFamilyFallback: const ['Noto Naskh Arabic', 'Scheherazade'],
  );

  List<InlineSpan> buildSpans({
    required List<Aya> ayat,
    required bool showBasmala,
    required String basmala,
    required int? currentAyahIndex,
    Color? ayahNumberColor,
    required List<GestureRecognizer> recognizersBucket,
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
          ? _base.copyWith(
              backgroundColor: Colors.amber.withValues(alpha: 0.18),
            )
          : _base;
      out.add(TextSpan(text: '${a.text.trim()} ', style: s, recognizer: r));
      out.add(_ayahMarker(
        ayahNumber: a.numberInSurah,
        selected: selected,
        ayahNumberColor: ayahNumberColor,
        onTap: () => onAyahTap(i),
        onLongPress: () => onAyahLongPress(i),
      ));
      out.add(TextSpan(text: '  ', style: _base));
    }
    _cache[cacheKey] = out;
    return out;
  }

  InlineSpan _ayahMarker({
    required int ayahNumber,
    required bool selected,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Color? ayahNumberColor,
  }) {
    final txt = _toArabicDigits(ayahNumber);
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Text(
            '۝$txt',
            style: TextStyle(
              fontSize: 14,
              height: 1.0,
              color: ayahNumberColor,
              backgroundColor: selected
                  ? Colors.amber.withValues(alpha: 0.18)
                  : null,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
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
