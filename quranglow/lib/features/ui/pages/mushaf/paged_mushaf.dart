// lib/features/ui/pages/mushaf/paged_mushaf.dart
// ignore_for_file: prefer_interpolation_to_compose_strings, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'paginator.dart';
import 'span_builder.dart';
import 'position_store.dart';
import 'package:quranglow/core/model/aya.dart';

class PagedMushaf extends StatefulWidget {
  const PagedMushaf({
    required this.ayat,
    required this.surahName,
    required this.surahNumber,
    this.showBasmala = false,
    this.basmalaText = '﷽',
    this.initialSelectedAyah,
    super.key,
    required Null Function(dynamic aya) onAyahTap,
  });

  final List<Aya> ayat;
  final String surahName;
  final int surahNumber;
  final bool showBasmala;
  final String basmalaText;
  final int? initialSelectedAyah; // index صفرّي

  @override
  State<PagedMushaf> createState() => _PagedMushafState();
}

class _PagedMushafState extends State<PagedMushaf> with WidgetsBindingObserver {
  final List<PageChunk> _pages = [];
  List<InlineSpan>? _cachedSpans;
  bool _built = false;
  Size? _lastSize;
  double? _lastTextScale;

  int? _currentAyah; // index صفرّي
  final _recognizers = <TapGestureRecognizer>[];
  late final AyahSpanBuilder _builder;
  final _store = PositionStore();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentAyah = widget.initialSelectedAyah;
    _builder = AyahSpanBuilder(onAyahTap: _onAyahTap);
    if (_currentAyah == null) _restoreLast();
  }

  Future<void> _restoreLast() async {
    final pos = await _store.load();
    if (!mounted) return;
    if (pos != null && pos.surah == widget.surahNumber) {
      setState(() => _currentAyah = pos.ayahIndex);
    }
  }

  void _onAyahTap(int index) {
    setState(() => _currentAyah = index);
    _store.save(widget.surahNumber, index);
  }

  @override
  void didUpdateWidget(covariant PagedMushaf oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.ayat, widget.ayat) ||
        oldWidget.surahName != widget.surahName ||
        oldWidget.showBasmala != widget.showBasmala ||
        oldWidget.basmalaText != widget.basmalaText ||
        oldWidget.surahNumber != widget.surahNumber) {
      _invalidate();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scale = MediaQuery.textScalerOf(context).textScaleFactor;
    if (_lastTextScale != scale) {
      _lastTextScale = scale;
      _invalidate();
    }
    _ensureBuilt();
  }

  @override
  void didChangeMetrics() {
    final size =
        WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
    if (_lastSize != size) {
      _lastSize = size;
      _rebalancePages();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  void _invalidate() {
    _cachedSpans = null;
    _built = false;
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _rebalancePages());
  }

  void _ensureBuilt() {
    if (_built) return;
    _pages.clear();
    _cachedSpans ??= _builder.buildSpans(
      ayat: widget.ayat,
      showBasmala: widget.showBasmala,
      basmala: widget.basmalaText,
      currentAyahIndex: _currentAyah,
      recognizersBucket: _recognizers,
    );
    _pages.addAll(paginate(context, _cachedSpans!));
    _built = true;
  }

  void _rebalancePages() {
    if (!mounted) return;
    setState(() {
      _pages.clear();
      _cachedSpans ??= _builder.buildSpans(
        ayat: widget.ayat,
        showBasmala: widget.showBasmala,
        basmala: widget.basmalaText,
        currentAyahIndex: _currentAyah,
        recognizersBucket: _recognizers,
      );
      _pages.addAll(paginate(context, _cachedSpans!));
      _built = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (widget.ayat.isEmpty) {
      return const Center(child: Text('لا يوجد نص للعرض'));
    }
    if (_pages.isEmpty) {
      _ensureBuilt();
      if (_pages.isEmpty) return const Center(child: Text('جاري التجهيز...'));
    }

    return PageView.builder(
      reverse: true,
      itemCount: _pages.length,
      itemBuilder: (context, index) {
        final p = _pages[index];
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
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: RichText(
                            textAlign: TextAlign.justify,
                            textDirection: TextDirection.rtl,
                            strutStyle: const StrutStyle(
                              fontSize: 20,
                              height: 1.9,
                            ),
                            text: p.span,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_toArabicDigits(index + 1)} / ${_toArabicDigits(_pages.length)}',
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

String _toArabicDigits(int n) {
  const map = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return n.toString().split('').map((c) => map[int.parse(c)]).join();
}
