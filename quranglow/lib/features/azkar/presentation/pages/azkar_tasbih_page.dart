// lib/features/ui/pages/azkar/azkar_tasbih_page.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:quranglow/core/widgets/pro_app_bar.dart';
import 'package:quranglow/features/azkar/presentation/widgets/duas_list.dart';
import 'package:quranglow/features/azkar/presentation/widgets/reminder_list.dart';
import 'package:quranglow/features/azkar/presentation/widgets/tasbih_counter.dart';
import 'package:quranglow/features/ui/routes/app_routes.dart';

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
        appBar: ProAppBar(
          title: 'الأذكار والتسبيح',
          subtitle: 'عداد يومي مع التذكيرات والأدعية',
          onBack: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).maybePop();
            } else {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            }
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        cs.primary.withValues(alpha: 0.10),
                        cs.surfaceContainerHigh,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.72),
                    ),
                  ),
                  child: TabBar(
                    controller: _tab,
                    labelColor: cs.onPrimaryContainer,
                    unselectedLabelColor: cs.onSurfaceVariant,
                    indicator: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(icon: Icon(Icons.bubble_chart), text: 'التسبيح'),
                      Tab(icon: Icon(Icons.alarm), text: 'تذكير بالأدعية'),
                      Tab(icon: Icon(Icons.menu_book), text: 'أدعية'),
                    ],
                  ),
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
