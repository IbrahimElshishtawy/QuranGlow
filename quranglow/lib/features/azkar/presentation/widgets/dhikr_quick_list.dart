// lib/features/ui/pages/azkar/widgets/dhikr_quick_list.dart
import 'package:flutter/material.dart';

class DhikrQuickList extends StatelessWidget {
  const DhikrQuickList({super.key, this.onTapAny});
  final VoidCallback? onTapAny;

  @override
  Widget build(BuildContext context) {
    final items = const [
      'سبحان الله',
      'الحمد لله',
      'الله أكبر',
      'لا إله إلا الله',
      'لا حول ولا قوة إلا بالله',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map((e) => ActionChip(
        label: Text(e),
        avatar: const Icon(Icons.star, size: 18),
        onPressed: onTapAny,
      ))
          .toList(),
    );
  }
}
