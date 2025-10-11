// lib/features/ui/pages/azkar/azkar_tasbih_page.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'widgets/tasbih_counter.dart';
import 'widgets/reminder_list.dart';
import 'widgets/duas_list.dart';

class AzkarTasbihPage extends StatefulWidget {
  const AzkarTasbihPage({super.key});

  @override
  State<AzkarTasbihPage> createState() => _AzkarTasbihPageState();
}

class _AzkarTasbihPageState extends State<AzkarTasbihPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // لا AppBar
        body: SafeArea(
          child: Column(
            children: [
              // تبويب علوي بسيط بدل الشريط العالي
              Material(
                color: cs.surface,
                child: TabBar(
                  controller: _tab,
                  labelColor: cs.primary,
                  unselectedLabelColor: cs.onSurfaceVariant,
                  indicatorColor: cs.primary,
                  tabs: const [
                    Tab(icon: Icon(Icons.bubble_chart), text: 'التسبيح'),
                    Tab(icon: Icon(Icons.alarm), text: 'تذكير بالأدعية'),
                    Tab(icon: Icon(Icons.menu_book), text: 'أدعية'),
                  ],
                ),
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [cs.surface, cs.surfaceContainerHighest],
                    ),
                  ),
                  child: TabBarView(
                    controller: _tab,
                    physics: const BouncingScrollPhysics(),
                    children: const [
                      TasbihCounter(),
                      ReminderList(),
                      DuasList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
