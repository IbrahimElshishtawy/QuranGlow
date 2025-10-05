// lib/features/ui/pages/mushaf/paged_mushaf.dart
// أهم تغيير: onAyahTap يُمرّر رقم الآية 1-based
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
  void _onAyahTap(int index) {
    setState(() => _currentAyah = index);
    _store.save(widget.surahNumber, index);
    if (index >= 0 && index < widget.ayat.length) {
      widget.onAyahTap(index + 1, widget.ayat[index]); // 1-based
    }
  }

  @override
  Widget build(BuildContext context) {
    // استبدل Stack الداخلي باستخدام ويدجتات منفصلة:
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
                      : 'موضعي: آية ${_toArabicDigits(_currentAyah! + 1)} من ${widget.surahName}',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
