// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = _actions(context, cs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitleLocal('إجراءات سريعة'),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (_, c) {
            final w = c.maxWidth;
            final cross = w < 600 ? 2 : (w < 900 ? 3 : 4);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.06,
              ),
              itemBuilder: (_, i) => _ActionCard(item: items[i], cs: cs),
            );
          },
        ),
      ],
    );
  }


  List<_ActionItem> _actions(BuildContext context, ColorScheme cs) => [
    _ActionItem(
      'السور',
      Icons.list_alt,
          () => Navigator.pushNamed(context, AppRoutes.surahs),
    ),
    _ActionItem(
      'المحفوظات',
      Icons.bookmark,
          () => Navigator.pushNamed(context, AppRoutes.bookmarks),
    ),
    _ActionItem(
      'التنزيلات',
      Icons.download,
          () => Navigator.pushNamed(context, AppRoutes.downloads),
    ),
    _ActionItem(
      'الإحصائيات',
      Icons.insights,
          () => Navigator.pushNamed(context, AppRoutes.stats),
    ),
    _ActionItem(
      'التفسير',
      Icons.menu_book_outlined,
          () => Navigator.pushNamed(context, AppRoutes.tafsir),
    ),


    _ActionItem(
      'الصلاة',
      Icons.explore, // بوصلة
          () => showModalBottomSheet(
        context: context,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => _PrayerSheet(cs: cs),
      ),
    ),
  ];
}

class _PrayerSheet extends StatelessWidget {
  final ColorScheme cs;
  const _PrayerSheet({required this.cs});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.explore, color: cs.primary),
              title: const Text('اتجاه القبلة'),
              subtitle: const Text('استخدم البوصلة لمعرفة الاتجاه الصحيح'),
              onTap: () {
                Navigator.pop(context);
                // TODO: غيّر إلى الراوت الصحيح عند تجهيز صفحة القبلة
                // Navigator.pushNamed(context, AppRoutes.qibla);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('صفحة القبلة ستُضاف لاحقًا')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.access_time, color: cs.primary),
              title: const Text('مواقيت الصلاة'),
              subtitle: const Text('عرض أوقات الفجر إلى العشاء'),
              onTap: () {
                Navigator.pop(context);
                // TODO: غيّر إلى الراوت الصحيح عند تجهيز صفحة المواقيت
                // Navigator.pushNamed(context, AppRoutes.prayerTimes);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('صفحة المواقيت ستُضاف لاحقًا')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  _ActionItem(this.title, this.icon, this.onTap);
}

class _ActionCard extends StatelessWidget {
  final _ActionItem item;
  final ColorScheme cs;
  const _ActionCard({required this.item, required this.cs});

  @override
  Widget build(BuildContext context) {
    final bg = cs.surfaceContainerHigh;
    return Semantics(
      button: true,
      label: item.title,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, size: 30, color: cs.primary),
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
