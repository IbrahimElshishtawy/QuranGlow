// lib/features/ui/pages/mushaf/paged_mushaf.dart
// ignore_for_file: prefer_interpolation_to_compose_strings, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'span_builder.dart';
import 'position_store.dart';
import 'package:quranglow/core/model/aya.dart';

class PagedMushaf extends StatefulWidget {
  const PagedMushaf({
    super.key,
    required this.ayat,
    required this.surahName,
    required this.surahNumber,
    this.showBasmala = false,
    this.basmalaText = '﷽',
    this.initialSelectedAyah,
    required this.onAyahTap,
  });

  final List<Aya> ayat;
  final String surahName;
  final int surahNumber;
  final bool showBasmala;
  final String basmalaText;
  final int? initialSelectedAyah; // index صفرّي
  final void Function(Aya aya) onAyahTap;

  @override
  State<PagedMushaf> createState() => _PagedMushafState();
}

class _PageRange {
  final int start; // شامل
  final int end; // غير شامل
  const _PageRange(this.start, this.end);
}

class _PagedMushafState extends State<PagedMushaf> with WidgetsBindingObserver {
  final _store = PositionStore();
  int? _currentAyah; // index صفرّي

  // كل عنصر يمثل (بداية..نهاية) آيات صفحة واحدة—14 آية ثابتًا
  List<_PageRange> _pages = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentAyah = widget.initialSelectedAyah;
    _recomputePages(); // أول تقسيم
    if (_currentAyah == null) _restoreLast();
  }

  Future<void> _restoreLast() async {
    final pos = await _store.load();
    if (!mounted) return;
    if (pos != null && pos.surah == widget.surahNumber) {
      setState(() => _currentAyah = pos.ayahIndex);
    }
  }

  @override
  void didUpdateWidget(covariant PagedMushaf oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.ayat, widget.ayat) ||
        oldWidget.surahName != widget.surahName ||
        oldWidget.showBasmala != widget.showBasmala ||
        oldWidget.basmalaText != widget.basmalaText ||
        oldWidget.surahNumber != widget.surahNumber) {
      _recomputePages();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pages.isEmpty) _recomputePages();
  }

  @override
  void didChangeMetrics() {
    // لا حاجة لإعادة التقسيم حسب الحجم لأننا نستخدم 14 آية ثابتًا
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onAyahTap(int index) {
    setState(() => _currentAyah = index);
    _store.save(widget.surahNumber, index);
    if (index >= 0 && index < widget.ayat.length) {
      widget.onAyahTap(widget.ayat[index]);
    }
  }

  /// تقسيم بسيط: كل صفحة = 14 آية، والصفحة الأخيرة قد تكون أقل (الباقي)
  void _recomputePages() {
    final ranges = <_PageRange>[];
    const perPage = 14;
    final n = widget.ayat.length;

    for (int i = 0; i < n; i += perPage) {
      final end = (i + perPage <= n) ? i + perPage : n;
      ranges.add(_PageRange(i, end));
    }
    if (ranges.isEmpty) ranges.add(const _PageRange(0, 0));

    setState(() => _pages = ranges);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (widget.ayat.isEmpty) {
      return const Center(child: Text('لا يوجد نص للعرض'));
    }
    if (_pages.isEmpty) {
      return const Center(child: Text('جاري التجهيز...'));
    }

    return PageView.builder(
      reverse: true,
      itemCount: _pages.length,
      itemBuilder: (context, pageIndex) {
        final r = _pages[pageIndex];
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.surahName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Divider(color: cs.outlineVariant),
                      const SizedBox(height: 8),

                      // محتوى الصفحة — نُوَلِّده عند الطلب فقط
                      Expanded(
                        child: _PageRichBlock(
                          ayat: widget.ayat,
                          range: r,
                          showBasmala: widget.showBasmala && pageIndex == 0,
                          basmalaText: widget.basmalaText,
                          currentAyahIndex: _currentAyah,
                          onTapIndex: _onAyahTap,
                        ),
                      ),

                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_toArabicDigits(pageIndex + 1)} / ${_toArabicDigits(_pages.length)}',
                            style: TextStyle(color: cs.outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // شريط موضع الحفظ
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 220),
                      opacity: (_currentAyah != null) ? 1 : 0,
                      child: IgnorePointer(
                        ignoring: true,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.28),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            (_currentAyah == null)
                                ? ''
                                : 'موضعي: آية ${_toArabicDigits(_currentAyah! + 1)} من ${widget.surahName}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PageRichBlock extends StatefulWidget {
  const _PageRichBlock({
    required this.ayat,
    required this.range,
    required this.showBasmala,
    required this.basmalaText,
    required this.currentAyahIndex,
    required this.onTapIndex,
  });

  final List<Aya> ayat;
  final _PageRange range;
  final bool showBasmala;
  final String basmalaText;
  final int? currentAyahIndex;
  final void Function(int index) onTapIndex;

  @override
  State<_PageRichBlock> createState() => _PageRichBlockState();
}

class _PageRichBlockState extends State<_PageRichBlock> {
  final _recognizers = <TapGestureRecognizer>[];
  late final AyahSpanBuilder _builder;

  @override
  void initState() {
    super.initState();
    _builder = AyahSpanBuilder(onAyahTap: widget.onTapIndex);
  }

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subAyat = widget.ayat.sublist(widget.range.start, widget.range.end);

    final localCurrentIndex = widget.currentAyahIndex == null
        ? null
        : _mapToLocal(
            widget.currentAyahIndex!,
            widget.range.start,
            widget.range.end,
          );

    final spans = _builder.buildSpans(
      ayat: subAyat,
      showBasmala: widget.showBasmala,
      basmala: widget.basmalaText,
      currentAyahIndex: localCurrentIndex,
      recognizersBucket: _recognizers,
    );

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: RichText(
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        strutStyle: const StrutStyle(fontSize: 20, height: 1.9),
        text: TextSpan(children: spans),
      ),
    );
  }

  int? _mapToLocal(int global, int start, int end) {
    if (global < start || global >= end) return null;
    return global - start;
  }
}

String _toArabicDigits(int n) {
  const map = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return n.toString().split('').map((c) => map[int.parse(c)]).join();
}
