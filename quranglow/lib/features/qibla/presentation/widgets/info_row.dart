// lib/features/ui/pages/qibla/widgets/info_row.dart
import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final double? heading, bearing, delta;
  const InfoRow({super.key, this.heading, this.bearing, this.delta});

  String _fmt(double? v) => v == null ? '—' : '${v.toStringAsFixed(0)}°';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodyMedium;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Metric(
              icon: Icons.explore,
              label: 'البوصلة',
              value: _fmt(heading),
              cs: cs,
              style: style,
            ),
            _Metric(
              icon: Icons.place,
              label: 'زاوية القبلة',
              value: _fmt(bearing),
              cs: cs,
              style: style,
            ),
            _Metric(
              icon: Icons.navigation,
              label: 'اتّجه',
              value: _fmt(delta),
              cs: cs,
              style: style,
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final ColorScheme cs;
  final TextStyle? style;
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
    required this.cs,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: cs.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: style?.copyWith(color: cs.onSurfaceVariant)),
            Text(value, style: style?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}
