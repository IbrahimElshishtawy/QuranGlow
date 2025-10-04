// lib/features/ui/pages/home/home_page.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:quranglow/features/ui/pages/home/sections/daily_ayah_card.dart';
import 'package:quranglow/features/ui/pages/home/sections/goals_strip.dart';
import 'package:quranglow/features/ui/pages/home/sections/last_read_card.dart';
import 'package:quranglow/features/ui/pages/home/sections/quick_actions_grid.dart';
import 'package:quranglow/features/ui/pages/home/sections/shortcuts_list.dart';
import 'package:quranglow/features/ui/pages/home/widgets/app_drawer.dart';
import 'package:quranglow/features/ui/pages/home/widgets/hero_header.dart';
import 'package:quranglow/features/ui/pages/home/widgets/section_shell.dart';
import 'package:quranglow/features/ui/pages/home/widgets/section_spacing.dart';

// أعرض الصفحات داخل التبويبات بدل التنقّل
import 'package:quranglow/features/ui/pages/search/search_page.dart';
import 'package:quranglow/features/ui/pages/player/player_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: AppDrawer(
          onNavigate: (r) {
            Navigator.pop(context);
            // لو محتاجين تنقّل من القائمة الجانبية يبقى هنا
            Navigator.pushNamed(context, r);
          },
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            NavigationDestination(icon: Icon(Icons.search), label: 'بحث'),
            NavigationDestination(icon: Icon(Icons.download), label: 'تنزيلات'),
            NavigationDestination(
              icon: Icon(Icons.play_circle),
              label: 'مشغّل',
            ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 150,
              centerTitle: true,
              title: Text(_titleForTab(_tab)),
              actions: const [
                // مثال: زر إعدادات (اختياري تحذف لو عندك صفحة إعدادات مستقلة)
                // IconButton(onPressed: (){}, icon: Icon(Icons.settings)),
              ],
              flexibleSpace: const FlexibleSpaceBar(background: HeroHeader()),
            ),

            // الرئيسية
            if (_tab == 0) ...[
              const SliverToBoxAdapter(
                child: SectionSpacing(child: LastReadCard()),
              ),
              const SliverToBoxAdapter(
                child: SectionSpacing(child: DailyAyahCard()),
              ),
              const SliverToBoxAdapter(
                child: SectionSpacing(child: GoalsStrip()),
              ),
              const SliverToBoxAdapter(
                child: SectionSpacing(child: QuickActionsGrid()),
              ),
              const SliverToBoxAdapter(
                child: SectionSpacing(child: ShortcutsList()),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 16,
                ),
              ),
            ],

            // البحث — يُعرَض داخل نفس الصفحة
            if (_tab == 1)
              const SliverFillRemaining(
                hasScrollBody: true,
                child: SearchPage(),
              ),

            // التنزيلات (قالب بسيط)
            if (_tab == 2)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: SectionShell(
                  title: 'التنزيلات',
                  subtitle: 'إدارة التحميلات والتشغيل دون إنترنت',
                ),
              ),

            // المشغّل — يُعرَض داخل نفس الصفحة
            if (_tab == 3)
              const SliverFillRemaining(
                hasScrollBody: true,
                child: PlayerPage(),
              ),
          ],
        ),
      ),
    );
  }

  String _titleForTab(int i) => switch (i) {
    0 => 'QuranGlow',
    1 => 'بحث',
    2 => 'التنزيلات',
    3 => 'المشغّل',
    _ => 'QuranGlow',
  };
}
