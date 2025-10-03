// lib/features/ui/pages/player/widgets/speed_menu.dart
import 'package:flutter/material.dart';

class SpeedMenu extends StatefulWidget {
  const SpeedMenu({super.key, required this.onSelect});
  final void Function(double) onSelect;

  @override
  State<SpeedMenu> createState() => _SpeedMenuState();
}

class _SpeedMenuState extends State<SpeedMenu> {
  double _speed = 1.0;
  final _options = const [0.5, 0.75, 1.0, 1.25, 1.5];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      tooltip: 'السرعة',
      onSelected: (v) {
        setState(() => _speed = v);
        widget.onSelect(v);
      },
      itemBuilder: (context) => _options
          .map((v) => PopupMenuItem<double>(value: v, child: Text('${v}x')))
          .toList(),
      child: Chip(
        label: Text('السرعة ${_speed}x'),
        avatar: const Icon(Icons.speed_rounded, size: 18),
      ),
    );
  }
}
