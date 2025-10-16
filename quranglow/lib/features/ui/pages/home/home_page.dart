// lib/features/ui/pages/home/home_page.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:quranglow/features/ui/pages/home/sections/daily_ayah_card.dart';

import 'package:quranglow/features/ui/pages/home/widgets/app_drawer.dart';
import 'package:quranglow/features/ui/pages/home/widgets/hero_header.dart';

import 'package:quranglow/features/ui/pages/home/sections/last_read_card.dart';
import 'package:quranglow/features/ui/pages/home/sections/goals_strip.dart';
import 'package:quranglow/features/ui/pages/home/sections/quick_actions_grid.dart';
import 'package:quranglow/features/ui/pages/home/sections/shortcuts_list.dart';
import 'package:quranglow/features/ui/pages/home/widgets/section_spacing.dart';

import '../mushaf/mushaf_page.dart';
import '../azkar/azkar_tasbih_page.dart';
import '../player/player_page.dart';
import '../search/search_page.dart';

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
        appBar: AppBar(
          flexibleSpace: const HeroHeader(),
          toolbarHeight: 120,
          centerTitle: true,
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
        body: IndexedStack(
          index: _tab,
          children: const [
            _HomeSections(),
            MushafPage(),
            AzkarTasbihPage(),
            PlayerPage(),
            SearchPage(),
          ],
        ),
      ),
    );
  }
}

class _HomeSections extends StatelessWidget {
  const _HomeSections();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SectionSpacing(child: LastReadCard())),
        const SliverToBoxAdapter(child: SectionSpacing(child: DailyAyahCard())),
        const SliverToBoxAdapter(child: SectionSpacing(child: GoalsStrip())),
        const SliverToBoxAdapter(
          child: SectionSpacing(child: QuickActionsGrid()),
        ),
        const SliverToBoxAdapter(child: SectionSpacing(child: ShortcutsList())),
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ),
      ],
    );
  }
}
