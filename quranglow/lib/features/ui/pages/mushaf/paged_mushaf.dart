// أهم شيء: التقسيم حسب صفحات مصحف المدينة + تلوين رقم الآية + حفظ الموضع
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

import 'package:quranglow/core/model/aya.dart';
import 'package:quranglow/features/ui/pages/mushaf/page_rich_block.dart';
import 'package:quranglow/features/ui/pages/mushaf/widget/mushaf_header.dart';
import 'package:quranglow/features/ui/pages/mushaf/widget/page_indicator.dart';
import 'package:quranglow/features/ui/pages/mushaf/widget/position_store.dart';
import 'package:quranglow/features/ui/pages/mushaf/widget/saved_position_banner.dart';

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
  final int? initialSelectedAyah;
  final void Function(int ayahNumber, Aya aya) onAyahTap;

  @override
  State<PagedMushaf> createState() => _PagedMushafState();
}

class _PagedMushafState extends State<PagedMushaf> with WidgetsBindingObserver {
  final _pos = PositionStore();
  final _controller = PageController(keepPage: true);

  int? _currentAyah;
  late final List<PageRange> _pages;
  bool _justSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _currentAyah = widget.initialSelectedAyah == null
        ? null
        : (widget.initialSelectedAyah! - 1).clamp(0, widget.ayat.length - 1);

    _pages = _buildPages(widget.ayat);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _onAyahTap(int index) async {
    setState(() => _currentAyah = index);
    await _pos.save(widget.surahNumber, index);

    // رسالة حفظ
    setState(() => _justSaved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _justSaved = false);
    });

    // فتح التفسير
    if (index >= 0 && index < widget.ayat.length) {
      widget.onAyahTap(index + 1, widget.ayat[index]); // 1-based
    }

    if (kDebugMode) {
      // ignore: avoid_print
      print('حفظ موضع السورة ${widget.surahNumber}، الآية ${index + 1}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      reverse: true,
      physics: const BouncingScrollPhysics(),
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
                      MushafHeader(surahName: widget.surahName),
                      const SizedBox(height: 6),
                      Divider(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: PageRichBlock(
                          ayat: widget.ayat,
                          range: r,
                          showBasmala: widget.showBasmala && pageIndex == 0,
                          basmalaText: widget.basmalaText,
                          currentAyahIndex: _currentAyah,
                          onTapIndex: _onAyahTap,
                        ),
                      ),
                      const SizedBox(height: 8),
                      PageIndicator(
                        current: pageIndex + 1,
                        total: _pages.length,
                      ),
                    ],
                  ),
                ),
                SavedPositionBanner(
                  visible: _justSaved,
                  text: _currentAyah == null
                      ? ''
                      : 'تم حفظ موضعك: آية ${_toArabicDigits((_currentAyah! + 1))} من ${widget.surahName}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // تقسيم يعتمد على رقم صفحة مصحف المدينة لكل آية
  List<PageRange> _buildPages(List<Aya> ayat) {
    if (ayat.isEmpty) return [const PageRange(start: 0, end: 0)];

    final res = <PageRange>[];
    int start = 0;
    int currentPage = quran.getPageNumber(widget.surahNumber, 1);

    for (int i = 0; i < ayat.length; i++) {
      final page = quran.getPageNumber(widget.surahNumber, i + 1);
      if (page != currentPage) {
        res.add(PageRange(start: start, end: i));
        start = i;
        currentPage = page;
      }
    }
    if (res.isEmpty || res.last.end != ayat.length) {
      res.add(PageRange(start: start, end: ayat.length));
    }
    return res;
  }

  String _toArabicDigits(int number) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final s = number.toString();
    final buf = StringBuffer();
    for (final ch in s.split('')) {
      final idx = western.indexOf(ch);
      buf.write(idx >= 0 ? eastern[idx] : ch);
    }
    return buf.toString();
  }
}
