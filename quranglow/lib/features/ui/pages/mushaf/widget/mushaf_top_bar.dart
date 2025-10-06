// ignore_for_file: deprecated_member_use
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/model/surah.dart';

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
    this.onTafsir, // NEW
  });

  final bool visible;
  final AsyncValue<Surah> asyncSurah;
  final int chapter;
  final VoidCallback onBack;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onSave;
  final VoidCallback? onTafsir; // NEW

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                      color: Colors.black.withOpacity(0.35),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.06),
                          Colors.black.withOpacity(0.20),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        _roundButton(
                          icon: Icons.arrow_back,
                          onTap: onBack,
                          tooltip: 'عودة',
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
                                style: const TextStyle(
                                  color: Colors.white,
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // NEW: زر التفسير
                        _roundButton(
                          icon: Icons.menu_book_outlined,
                          onTap: onTafsir,
                          tooltip: 'التفسير',
                          disabledColor: cs.onSurface.withOpacity(.28),
                        ),

                        // زر الحفظ
                        _roundButton(
                          icon: Icons.bookmark_add_outlined,
                          onTap: onSave,
                          tooltip: 'حفظ الموضع',
                          disabledColor: cs.onSurface.withOpacity(.28),
                        ),

                        _roundButton(
                          icon: Icons.skip_previous,
                          onTap: onPrev,
                          tooltip: 'السابق',
                          disabledColor: cs.onSurface.withOpacity(.28),
                        ),
                        _roundButton(
                          icon: Icons.skip_next,
                          onTap: onNext,
                          tooltip: 'التالي',
                          disabledColor: cs.onSurface.withOpacity(.28),
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
    Color? disabledColor,
  }) {
    final enabled = onTap != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon),
        color: enabled ? Colors.white : (disabledColor ?? Colors.white24),
        splashRadius: 22,
        style: IconButton.styleFrom(
          backgroundColor: enabled
              ? Colors.white.withOpacity(.08)
              : Colors.white.withOpacity(.02),
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}
