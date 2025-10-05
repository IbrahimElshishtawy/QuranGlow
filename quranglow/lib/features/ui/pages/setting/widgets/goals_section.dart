// lib/features/ui/pages/settings/goals_settings_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
// انتبه: نستورد نموذج Goal الحديث من الملف الصحيح (الكابيتال كما في مشروعك)
import 'package:quranglow/core/model/Goal.dart' as models;

class GoalsSettings extends ConsumerStatefulWidget {
  const GoalsSettings({super.key});

  @override
  ConsumerState<GoalsSettings> createState() => _GoalsSettingsState();
}

class _GoalsSettingsState extends ConsumerState<GoalsSettings> {
  List<models.Goal>? _goals;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ref.read(goalsServiceProvider).listGoals();
    if (!mounted) return;
    setState(() => _goals = List<models.Goal>.from(list));
  }

  @override
  Widget build(BuildContext context) {
    final goals = _goals;
    if (goals == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('إعداد الأهداف')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: goals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final g = goals[i];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          g.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Switch(
                        value: g.active,
                        onChanged: (v) {
                          setState(() => goals[i] = g.copyWith(active: v));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('الهدف: ${g.target} ${g.unit}'),
                  Slider(
                    min: 5,
                    max: 200,
                    divisions: 39,
                    value: g.target.toDouble(),
                    label: '${g.target}',
                    onChanged: (v) {
                      setState(() => goals[i] = g.copyWith(target: v.round()));
                    },
                  ),
                  Text('الوحدة: ${g.unit}'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() => goals[i] = g.copyWith(current: 0));
                        },
                        child: const Text('تصفير التقدم'),
                      ),
                      const Spacer(),
                      Text(
                        '${g.current} / ${g.target} (${(g.progress * 100).round()}%)',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            onPressed: () async {
              await ref.read(goalsServiceProvider).saveAll(goals);
              if (!mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('تم الحفظ')));
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ),
      ),
    );
  }
}
