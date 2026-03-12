import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart' as di;
import 'package:quranglow/core/model/setting/goal.dart';

Future<void> openGoalEditor(
  BuildContext context,
  WidgetRef ref, {
  Goal? goal,
}) async {
  final result = await showModalBottomSheet<Goal>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _GoalEditorSheet(goal: goal),
  );
  if (result == null) return;
  await ref.read(di.goalsServiceProvider).upsertGoal(result);
}

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final asyncGoals = ref.watch(di.goalsStreamProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأهداف'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => openGoalEditor(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('هدف جديد'),
        ),
        body: asyncGoals.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
          data: (goals) {
            if (goals.isEmpty) {
              return const Center(child: Text('لا توجد أهداف بعد'));
            }

            final completed = goals.where((g) => g.completed).length;
            final active = goals.where((g) => g.active).length;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        cs.primary.withValues(alpha: .14),
                        cs.tertiary.withValues(alpha: .08),
                      ],
                    ),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      _StatChip(label: 'مفعلة', value: '$active'),
                      const SizedBox(width: 10),
                      _StatChip(label: 'مكتملة', value: '$completed'),
                      const Spacer(),
                      Expanded(
                        child: Text(
                          'عدّل أهدافك، اربطها بتذكير يومي، وحدث التقدم من هنا أو من الصفحة الرئيسية.',
                          textAlign: TextAlign.end,
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...goals.map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _GoalCard(goal: goal),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal});

  final Goal goal;

  String _typeLabel(GoalType type) {
    switch (type) {
      case GoalType.reading:
        return 'قراءة';
      case GoalType.listening:
        return 'استماع';
      case GoalType.memorization:
        return 'حفظ';
      case GoalType.tafsir:
        return 'تفسير';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final svc = ref.read(di.goalsServiceProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_typeLabel(goal.type)} • ${goal.current}/${goal.target} ${goal.unit}',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Switch(
                value: goal.active,
                onChanged: (value) async {
                  await svc.upsertGoal(goal.copyWith(active: value));
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 10,
              backgroundColor: cs.primary.withValues(alpha: .12),
              valueColor: AlwaysStoppedAnimation(
                goal.completed ? Colors.green : cs.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniTag(
                icon: Icons.notifications_active_outlined,
                text: goal.reminderEnabled
                    ? 'تذكير ${goal.reminderTime.format(context)}'
                    : 'بدون تذكير',
              ),
              _MiniTag(
                icon: goal.completed ? Icons.check_circle : Icons.flag_outlined,
                text: goal.completed ? 'مكتمل' : 'قيد التنفيذ',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: () => svc.decrement(goal.id),
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => svc.increment(goal.id),
                icon: const Icon(Icons.add),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => openGoalEditor(context, ref, goal: goal),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('تعديل'),
              ),
              TextButton.icon(
                onPressed: () => svc.resetProgress(goal.id),
                icon: const Icon(Icons.restart_alt),
                label: const Text('تصفير'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalEditorSheet extends StatefulWidget {
  const _GoalEditorSheet({this.goal});

  final Goal? goal;

  @override
  State<_GoalEditorSheet> createState() => _GoalEditorSheetState();
}

class _GoalEditorSheetState extends State<_GoalEditorSheet> {
  late final TextEditingController _title;
  late final TextEditingController _target;
  late final TextEditingController _unit;
  late GoalType _type;
  late bool _active;
  late bool _reminderEnabled;
  late TimeOfDay _reminderTime;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _title = TextEditingController(text: goal?.title ?? '');
    _target = TextEditingController(text: (goal?.target ?? 40).toString());
    _unit = TextEditingController(text: goal?.unit ?? 'آية');
    _type = goal?.type ?? GoalType.reading;
    _active = goal?.active ?? true;
    _reminderEnabled = goal?.reminderEnabled ?? false;
    _reminderTime = goal?.reminderTime ?? const TimeOfDay(hour: 9, minute: 0);
  }

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    _unit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.goal == null ? 'إضافة هدف' : 'تعديل الهدف',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'اسم الهدف',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<GoalType>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'نوع الهدف',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: GoalType.reading, child: Text('قراءة')),
                DropdownMenuItem(value: GoalType.listening, child: Text('استماع')),
                DropdownMenuItem(value: GoalType.memorization, child: Text('حفظ')),
                DropdownMenuItem(value: GoalType.tafsir, child: Text('تفسير')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _type = value);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _target,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الهدف المطلوب',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _unit,
                    decoration: const InputDecoration(
                      labelText: 'الوحدة',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _active,
              onChanged: (value) => setState(() => _active = value),
              title: const Text('تفعيل الهدف'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _reminderEnabled,
              onChanged: (value) => setState(() => _reminderEnabled = value),
              title: const Text('ربط الهدف بإشعار يومي'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: _reminderEnabled,
              title: const Text('وقت التذكير'),
              subtitle: Text(_reminderTime.format(context)),
              trailing: const Icon(Icons.schedule),
              onTap: !_reminderEnabled
                  ? null
                  : () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _reminderTime,
                      );
                      if (picked != null) {
                        setState(() => _reminderTime = picked);
                      }
                    },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('حفظ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final title = _title.text.trim();
    final target = int.tryParse(_target.text.trim()) ?? 0;
    final unit = _unit.text.trim().isEmpty ? 'آية' : _unit.text.trim();
    if (title.isEmpty || target <= 0) {
      Navigator.pop(context);
      return;
    }

    final old = widget.goal;
    Navigator.pop(
      context,
      Goal(
        id: old?.id ?? '${_type.name}-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        type: _type,
        target: target,
        current: old?.current ?? 0,
        active: _active,
        createdAt: old?.createdAt ?? DateTime.now(),
        unit: unit,
        reminderEnabled: _reminderEnabled,
        reminderHour: _reminderTime.hour,
        reminderMinute: _reminderTime.minute,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: .82),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text(label, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
