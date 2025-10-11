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

// صفحات أخرى
import 'package:quranglow/features/ui/pages/search/search_page.dart';
import 'package:quranglow/features/ui/pages/player/player_page.dart';
// أبقي التنزيلات في الـDrawer فقط إن لزم
// import 'package:quranglow/features/ui/pages/downloads/downloads_page.dart';

// صفحات جديدة
import 'package:quranglow/features/ui/pages/mushaf/mushaf_page.dart';
import 'package:quranglow/features/ui/pages/azkar/azkar_tasbih_page.dart';

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
            Navigator.pushNamed(context, r);
          },
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'المصحف',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'أذكار وتسبيح',
            ),
            NavigationDestination(
              icon: Icon(Icons.play_circle_outline),
              selectedIcon: Icon(Icons.play_circle),
              label: 'المشغّل',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              selectedIcon: Icon(Icons.search),
              label: 'بحث',
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

            // تبويب 0: المصحف
            if (_tab == 0) ...[
              const SliverFillRemaining(
                hasScrollBody: true,
                child: MushafPage(),
              ),
            ],

            // تبويب 1: الأذكار والتسبيح
            if (_tab == 1) ...[
              const SliverFillRemaining(
                hasScrollBody: true,
                child: AzkarTasbihPage(),
              ),
            ],

            // تبويب 2: المشغّل
            if (_tab == 2) ...[
              const SliverFillRemaining(
                hasScrollBody: true,
                child: PlayerPage(),
              ),
            ],

            // تبويب 3: البحث
            if (_tab == 3) ...[
              const SliverFillRemaining(
                hasScrollBody: true,
                child: SearchPage(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _titleForTab(int i) => switch (i) {
    0 => 'المصحف',
    1 => 'الأذكار والتسبيح',
    2 => 'المشغّل',
    3 => 'بحث',
    _ => 'QuranGlow',
  };
}
