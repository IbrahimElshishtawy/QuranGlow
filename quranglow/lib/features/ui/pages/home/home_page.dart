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
import 'package:quranglow/features/ui/pages/home/widgets/section_spacing.dart';

// الصفحات الأخرى
import 'package:quranglow/features/ui/pages/search/search_page.dart';
import 'package:quranglow/features/ui/pages/player/player_page.dart';
import 'package:quranglow/features/ui/pages/downloads/downloads_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  // final int _defaultSurah = 18;
  // final String _defaultReciterId = 'ar.alafasy';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: AppDrawer(
          onNavigate: (r) {
            Navigator.pop(context);
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

            // البحث
            if (_tab == 1)
              const SliverFillRemaining(
                hasScrollBody: true,
                child: SearchPage(),
              ),

            // التنزيلات — تمرير البراميتر المطلوبة
            if (_tab == 2)
              SliverFillRemaining(
                hasScrollBody: true,
                child: DownloadsPage(
                  // surah: _defaultSurah,
                  // reciterId: _defaultReciterId,
                ),
              ),

            // المشغّل
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
