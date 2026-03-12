import 'package:flutter/material.dart';

class AboutSocialButton extends StatelessWidget {
  const AboutSocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        width: 104,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
