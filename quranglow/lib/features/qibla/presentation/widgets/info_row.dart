import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, this.heading, this.bearing, this.delta});

  final double? heading;
  final double? bearing;
  final double? delta;

  String _fmt(double? v) => v == null ? '—' : '${v.toStringAsFixed(0)}°';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isSmall = c.maxWidth < 390;
        if (isSmall) {
          return Column(
            children: [
              _MetricCard(
                icon: Icons.explore_rounded,
                label: 'اتجاه الهاتف',
                value: _fmt(heading),
              ),
              const SizedBox(height: 8),
              _MetricCard(
                icon: Icons.place_rounded,
                label: 'زاوية القبلة',
                value: _fmt(bearing),
              ),
              const SizedBox(height: 8),
              _MetricCard(
                icon: Icons.navigation_rounded,
                label: 'الانحراف',
                value: _fmt(delta),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.explore_rounded,
                label: 'اتجاه الهاتف',
                value: _fmt(heading),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                icon: Icons.place_rounded,
                label: 'زاوية القبلة',
                value: _fmt(bearing),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricCard(
                icon: Icons.navigation_rounded,
                label: 'الانحراف',
                value: _fmt(delta),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.surface.withValues(alpha: 0.95),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cs.primary, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
