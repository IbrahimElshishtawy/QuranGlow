// lib/features/ui/pages/mushaf/widgets/saved_position_banner.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SavedPositionBanner extends StatelessWidget {
  const SavedPositionBanner({
    super.key,
    required this.visible,
    required this.text,
  });
  final bool visible;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: visible ? 1 : 0,
          child: IgnorePointer(
            ignoring: true,
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.28),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                text,
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
    );
  }
}
