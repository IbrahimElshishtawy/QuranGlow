import 'package:flutter/material.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  final void Function(String route) onNavigate;
  const AppDrawer({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.menu_book, color: cs.primary),
              title: const Text('المصحف'),
              onTap: () => onNavigate(AppRoutes.mushaf),
            ),
            ListTile(
              leading: Icon(Icons.list_alt, color: cs.primary),
              title: const Text('السور'),
              onTap: () => onNavigate(AppRoutes.surahs),
            ),
            ListTile(
              leading: Icon(Icons.bookmark, color: cs.primary),
              title: const Text('المحفوظات'),
              onTap: () => onNavigate(AppRoutes.bookmarks),
            ),
            ListTile(
              leading: Icon(Icons.menu_book_outlined, color: cs.primary),
              title: const Text('التفسير'),
              onTap: () => onNavigate(AppRoutes.tafsir),
            ),
            ListTile(
              leading: Icon(Icons.flag, color: cs.primary),
              title: const Text('الأهداف'),
              onTap: () => onNavigate(AppRoutes.goals),
            ),
            ListTile(
              leading: Icon(Icons.insights, color: cs.primary),
              title: const Text('الإحصائيات'),
              onTap: () => onNavigate(AppRoutes.stats),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text('الإعدادات'),
            ),
          ],
        ),
      ),
    );
  }
}
