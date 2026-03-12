import 'package:flutter/material.dart';

class DhikrQuickList extends StatelessWidget {
  const DhikrQuickList({
    super.key,
    this.selectedItem,
    this.onTapItem,
  });

  final String? selectedItem;
  final ValueChanged<String>? onTapItem;

  static const items = <String>[
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
    'لا حول ولا قوة إلا بالله',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => ChoiceChip(
              label: Text(item),
              avatar: const Icon(Icons.auto_awesome_rounded, size: 18),
              selected: selectedItem == item,
              selectedColor: cs.primaryContainer,
              labelStyle: TextStyle(
                color: selectedItem == item
                    ? cs.onPrimaryContainer
                    : cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
              onSelected: (_) => onTapItem?.call(item),
            ),
          )
          .toList(),
    );
  }
}
