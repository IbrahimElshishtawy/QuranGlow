// ignore_for_file: deprecated_member_use
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/core/model/book/surah.dart';

class MushafTopBar extends StatelessWidget {
  const MushafTopBar({
    super.key,
    required this.visible,
    required this.asyncSurah,
    required this.chapter,
    required this.onBack,
    this.onPrev,
    this.onNext,
    this.onSave,
    this.onTafsir,
  });

  final bool visible;
  final AsyncValue<Surah> asyncSurah;
  final int chapter;
  final VoidCallback onBack;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onSave;
  final VoidCallback? onTafsir;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ألوان متكيفة مع الثيم
    final fg = isDark
        ? cs.onSurface
        : cs.onSurface; // نفس المصدر، لكن هنقلل/نزود الشفافية تحت
    final titleColor = fg.withOpacity(isDark ? 0.95 : 0.90);
    final iconEnabled = fg.withOpacity(isDark ? 0.95 : 0.90);
    final iconDisabled = fg.withOpacity(0.30);

    final bg = isDark
        ? Colors.black.withOpacity(0.35)
        : cs.surface.withOpacity(0.75);

    final border = isDark
        ? Colors.white.withOpacity(0.06)
        : cs.outlineVariant.withOpacity(0.5);

    final gradStart = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.20);
    final gradEnd = isDark
        ? Colors.black.withOpacity(0.20)
        : Colors.black.withOpacity(0.05);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: visible ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: bg,
                      border: Border.all(color: border),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [gradStart, gradEnd],
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        _roundButton(
                          icon: Icons.arrow_back,
                          onTap: onBack,
                          tooltip: 'عودة',
                          enabledColor: iconEnabled,
                          disabledColor: iconDisabled,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: asyncSurah.maybeWhen(
                              data: (s) => Text(
                                s.name,
                                key: ValueKey('title-${s.name}'),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: titleColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              orElse: () => Text(
                                'سورة $chapter',
                                key: ValueKey('title-$chapter'),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: titleColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // التفسير
                        _roundButton(
                          icon: Icons.menu_book_outlined,
                          onTap: onTafsir,
                          tooltip: 'التفسير',
                          enabledColor: iconEnabled,
                          disabledColor: iconDisabled,
                          isDark: isDark,
                        ),

                        // الحفظ
                        _roundButton(
                          icon: Icons.bookmark_add_outlined,
                          onTap: onSave,
                          tooltip: 'حفظ الموضع',
                          enabledColor: iconEnabled,
                          disabledColor: iconDisabled,
                          isDark: isDark,
                        ),

                        _roundButton(
                          icon: Icons.skip_previous,
                          onTap: onPrev,
                          tooltip: 'السابق',
                          enabledColor: iconEnabled,
                          disabledColor: iconDisabled,
                          isDark: isDark,
                        ),
                        _roundButton(
                          icon: Icons.skip_next,
                          onTap: onNext,
                          tooltip: 'التالي',
                          enabledColor: iconEnabled,
                          disabledColor: iconDisabled,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    String? tooltip,
    required VoidCallback? onTap,
    required Color enabledColor,
    required Color disabledColor,
    required bool isDark,
  }) {
    final enabled = onTap != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon),
        color: enabled ? enabledColor : disabledColor,
        splashRadius: 22,
        style: IconButton.styleFrom(
          backgroundColor: (enabled
              ? enabledColor.withOpacity(isDark ? .12 : .10)
              : disabledColor.withOpacity(isDark ? .06 : .04)),
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}
