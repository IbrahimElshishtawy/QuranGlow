// lib/features/ui/pages/home/sections/shortcuts_list.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

class ShortcutsList extends StatelessWidget {
  const ShortcutsList({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitleLocal('اختصارات'),
        const SizedBox(height: 8),
        _ShortcutTile(
          icon: Icons.history,
          title: 'آخر قراءاتك',
          subtitle: 'نرجعك لنفس الموضع السابق',
          color: cs.primary,
          onTap: () => Navigator.pushNamed(context, AppRoutes.bookmarks),
        ),
        const SizedBox(height: 8),
        _ShortcutTile(
          icon: Icons.headset,
          title: 'اختر قارئًا',
          subtitle: 'استعرض التلاوات الصوتية',
          color: cs.primary,
          onTap: () => Navigator.pushNamed(context, AppRoutes.player),
        ),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ShortcutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Opacity(opacity: .75, child: Text(subtitle)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitleLocal extends StatelessWidget {
  final String title;
  const _SectionTitleLocal(this.title);
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ],
  );
}
