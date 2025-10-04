import 'package:flutter/material.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  final void Function(String route)? onNavigate; // اختياري
  const AppDrawer({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final routeName = ModalRoute.of(context)?.settings.name;

    void go(String r) {
      // لو نفس الصفحة: بس اقفل الدرج
      if (routeName == r) {
        Navigator.of(context).pop();
        return;
      }

      // اقفل الدرج أولًا
      Navigator.of(context).pop();

      // نفّذ التنقل بعد ما يقفل الدرج (لمنع فلاش/شاشة سوداء)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (onNavigate != null) {
          onNavigate!(r);
        } else {
          // لصفحات رئيسية، يفضّل إزالة المكدس
          Navigator.of(context).pushNamedAndRemoveUntil(r, (route) => false);
          // لو عايز تكدّس الصفحات بدل الإزالة:
          // Navigator.of(context).pushNamed(r);
        }
      });
    }

    Widget tile({
      required IconData icon,
      required String title,
      required String route,
    }) {
      final selected = routeName == route;
      return ListTile(
        leading: Icon(icon, color: selected ? cs.onPrimary : cs.primary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? cs.onPrimary : null,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: selected,
        selectedTileColor: cs.primary,
        onTap: () => go(route),
      );
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // هيدر
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.auto_awesome, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QuranGlow',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'القائمة الرئيسية',
                          style: TextStyle(color: cs.outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  tile(
                    icon: Icons.menu_book,
                    title: 'المصحف',
                    route: AppRoutes.mushaf,
                  ),
                  tile(
                    icon: Icons.list_alt,
                    title: 'السور',
                    route: AppRoutes.surahs,
                  ),
                  tile(
                    icon: Icons.bookmark,
                    title: 'المحفوظات',
                    route: AppRoutes.bookmarks,
                  ),
                  tile(
                    icon: Icons.menu_book_outlined,
                    title: 'التفسير',
                    route: AppRoutes.tafsir,
                  ),
                  tile(
                    icon: Icons.flag,
                    title: 'الأهداف',
                    route: AppRoutes.goals,
                  ),
                  tile(
                    icon: Icons.insights,
                    title: 'الإحصائيات',
                    route: AppRoutes.stats,
                  ),
                  const Divider(height: 24),
                  // تأكد إن الاسم يطابق الراوتر: setting أو settings
                  tile(
                    icon: Icons.settings,
                    title: 'الإعدادات',
                    route: AppRoutes.setting,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'الإصدار 1.0.0',
                style: TextStyle(color: cs.outline, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
