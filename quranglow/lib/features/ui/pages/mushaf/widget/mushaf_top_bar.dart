// ignore_for_file: deprecated_member_use
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
  });

  final bool visible;
  final AsyncValue<Surah> asyncSurah;
  final int chapter;
  final VoidCallback onBack;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: visible ? 1 : 0,
            child: Container(
              height: 56,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: asyncSurah.maybeWhen(
                      data: (s) => Text(
                        s.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      orElse: () => Text(
                        'سورة $chapter',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'السابق',
                    onPressed: onPrev,
                    color: Colors.white,
                    icon: const Icon(Icons.skip_previous),
                  ),
                  IconButton(
                    tooltip: 'التالي',
                    onPressed: onNext,
                    color: Colors.white,
                    icon: const Icon(Icons.skip_next),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
