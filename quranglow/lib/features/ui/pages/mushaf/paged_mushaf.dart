// lib/features/ui/pages/mushaf/paged_mushaf.dart
// أهم تغيير: onAyahTap يُمرّر رقم الآية 1-based
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quranglow/core/model/aya.dart';

import 'package:quranglow/features/ui/pages/mushaf/widget/mushaf_header.dart';
import 'package:quranglow/features/ui/pages/mushaf/widget/page_indicator.dart';
import 'package:quranglow/features/ui/pages/mushaf/widget/page_rich_block.dart';
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
  final _store = _PosStore();
  final _controller = PageController(keepPage: true);

  /// المؤشر الحالي داخل السورة 0-based
  int? _currentAyah;

  /// التقسيم إلى صفحات
  late final List<PageRange> _pages;

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

  void _onAyahTap(int index) {
    setState(() => _currentAyah = index);
    _store.save(widget.surahNumber, index);
    if (index >= 0 && index < widget.ayat.length) {
      widget.onAyahTap(index + 1, widget.ayat[index]); // 1-based
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
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
                  visible: _currentAyah != null,
                  text: (_currentAyah == null)
                      ? ''
                      : 'موضعي: آية ${_toArabicDigits((_currentAyah! + 1))} من ${widget.surahName}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // تقسيم بسيط: كل صفحة ~ 12 آية. عدّل الرقم حسب تصميمك.
  List<PageRange> _buildPages(List<Aya> ayat) {
    const perPage = 12;
    final res = <PageRange>[];
    for (int i = 0; i < ayat.length; i += perPage) {
      final end = (i + perPage > ayat.length) ? ayat.length : i + perPage;
      res.add(PageRange(start: i, end: end));
    }
    if (res.isEmpty) {
      res.add(const PageRange(start: 0, end: 0));
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

/// تخزين موضع القراءة الحالي. استبدله بتخزينك الفعلي (Hive/SharedPrefs).
class _PosStore {
  void save(int surahNumber, int ayahIndex) {
    // حفظ الموضع (surahNumber, ayahIndex)
    // استبدل هذا بالتخزين الفعلي
    if (kDebugMode) {
      print('حفظ موضع السورة $surahNumber، الآية ${ayahIndex + 1}');
    }
  }
}
