// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/service/setting/notification_service.dart';
import 'package:quranglow/features/azkar/presentation/widgets/reminder_editor.dart';
import 'package:quranglow/features/azkar/presentation/widgets/reminder_tile.dart';
import '../../../../../core/model/reminder/reminder.dart';

enum _AzkarPreset { morning, evening, afterPrayer }

class ReminderList extends ConsumerStatefulWidget {
  const ReminderList({super.key});

  @override
  ConsumerState<ReminderList> createState() => _ReminderListState();
}

class _ReminderListState extends ConsumerState<ReminderList> {
  static const _morningKey = 'azkar.reminder.morning';
  static const _eveningKey = 'azkar.reminder.evening';
  static const _afterPrayerKey = 'azkar.reminder.afterPrayer';

  final List<Reminder> _items = [];
  final Map<_AzkarPreset, bool> _presetStates = {
    _AzkarPreset.morning: false,
    _AzkarPreset.evening: false,
    _AzkarPreset.afterPrayer: false,
  };
  bool _loadingPresets = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
    _loadPresetStates();
  }

  Future<void> _loadPresetStates() async {
    final storage = ref.read(storageProvider);
    await storage.init();
    if (!mounted) return;
    setState(() {
      _presetStates[_AzkarPreset.morning] =
          (storage.getString(_morningKey) ?? 'false') == 'true';
      _presetStates[_AzkarPreset.evening] =
          (storage.getString(_eveningKey) ?? 'false') == 'true';
      _presetStates[_AzkarPreset.afterPrayer] =
          (storage.getString(_afterPrayerKey) ?? 'false') == 'true';
      _loadingPresets = false;
    });
  }

  Future<void> _persistPresetState(_AzkarPreset preset, bool value) async {
    final storage = ref.read(storageProvider);
    await storage.init();
    final key = switch (preset) {
      _AzkarPreset.morning => _morningKey,
      _AzkarPreset.evening => _eveningKey,
      _AzkarPreset.afterPrayer => _afterPrayerKey,
    };
    await storage.putString(key, value.toString());
  }

  Future<void> _loadReminders() async {
    final reminders = await ref.read(remindersServiceProvider).fetchReminders();
    if (mounted) {
      setState(() {
        _items
          ..clear()
          ..addAll(reminders);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('إضافة يدويًا'),
        onPressed: _openEditor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'تذكيرات الأذكار',
            subtitle:
                'فعّل التذكير الذي تريده، وسيتم جدولة الإشعار مباشرة حسب اختيارك.',
            child: _loadingPresets
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    children: [
                      _PresetTile(
                        icon: Icons.wb_sunny_rounded,
                        title: 'أذكار الصباح',
                        subtitle: 'تذكير يومي صباحي لبدء يومك بالذكر',
                        value: _presetStates[_AzkarPreset.morning] ?? false,
                        onChanged: (v) =>
                            _togglePreset(_AzkarPreset.morning, v),
                      ),
                      _PresetTile(
                        icon: Icons.nightlight_round,
                        title: 'أذكار المساء',
                        subtitle: 'تذكير يومي مسائي لختم يومك بالطمأنينة',
                        value: _presetStates[_AzkarPreset.evening] ?? false,
                        onChanged: (v) =>
                            _togglePreset(_AzkarPreset.evening, v),
                      ),
                      _PresetTile(
                        icon: Icons.mosque_rounded,
                        title: 'أذكار بعد كل صلاة',
                        subtitle:
                            'خمسة تذكيرات يومية بعد الفجر والظهر والعصر والمغرب والعشاء',
                        value: _presetStates[_AzkarPreset.afterPrayer] ?? false,
                        onChanged: (v) =>
                            _togglePreset(_AzkarPreset.afterPrayer, v),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'تذكيرات مخصصة',
            subtitle: 'أنشئ تذكيرًا خاصًا بك بتاريخ ووقت محددين.',
            child: _items.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => ReminderTile(
                      r: _items[i],
                      onEdit: () => _openEditor(edit: _items[i]),
                      onSchedule: () => _schedule(_items[i]),
                      onCancel: () => _cancel(_items[i]),
                      onDelete: () => _delete(_items[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePreset(_AzkarPreset preset, bool enabled) async {
    try {
      switch (preset) {
        case _AzkarPreset.morning:
          await NotificationService.instance.scheduleMorningAzkarReminder(
            enabled: enabled,
          );
        case _AzkarPreset.evening:
          await NotificationService.instance.scheduleEveningAzkarReminder(
            enabled: enabled,
          );
        case _AzkarPreset.afterPrayer:
          if (enabled) {
            final prayerData = await ref
                .read(prayerTimesServiceProvider)
                .fetchForToday();
            await NotificationService.instance
                .scheduleAfterPrayerAzkarReminders(
                  enabled: true,
                  data: prayerData,
                );
          } else {
            await NotificationService.instance
                .cancelAfterPrayerAzkarReminders();
          }
      }

      await _persistPresetState(preset, enabled);
      if (!mounted) return;
      setState(() => _presetStates[preset] = enabled);
      _snack(enabled ? 'تم تفعيل التذكير' : 'تم إيقاف التذكير');
    } catch (e) {
      _snack('تعذر ضبط التذكير: $e');
    }
  }

  Future<void> _openEditor({Reminder? edit}) async {
    final res = await showModalBottomSheet<Reminder>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReminderEditor(existing: edit),
    );
    if (!mounted || res == null) return;
    setState(() {
      if (edit == null) {
        _items.add(res);
        ref.read(remindersServiceProvider).saveReminder(res);
      } else {
        edit.title = res.title;
        edit.dateTime = res.dateTime;
        edit.daily = res.daily;
        edit.notes = res.notes;
        ref.read(remindersServiceProvider).saveReminder(edit);
      }
    });
  }

  Future<void> _schedule(Reminder r) async {
    try {
      if (r.dateTime.isBefore(DateTime.now()) && !r.daily) {
        final now = DateTime.now();
        r.dateTime = DateTime(
          now.year,
          now.month,
          now.day + 1,
          r.dateTime.hour,
          r.dateTime.minute,
        );
      }

      await NotificationService.instance.scheduleReminder(
        id: r.id,
        title: r.title.isNotEmpty ? r.title : 'تذكير',
        body: r.notes?.isNotEmpty == true ? r.notes! : 'موعد تذكيرك الآن',
        when: r.dateTime,
        daily: r.daily,
      );

      if (!mounted) return;
      setState(() => r.scheduled = true);
      _snack('تمت جدولة التذكير بنجاح');
    } catch (e) {
      _snack('فشلت الجدولة: $e');
    }
  }

  Future<void> _cancel(Reminder r) async {
    try {
      await NotificationService.instance.cancel(r.id);
      if (!mounted) return;
      setState(() => r.scheduled = false);
      _snack('تم إلغاء التذكير');
    } catch (e) {
      _snack('فشل الإلغاء: $e');
    }
  }

  void _delete(Reminder r) async {
    try {
      NotificationService.instance.cancel(r.id).catchError((_) {});
      if (!mounted) return;
      setState(() => _items.removeWhere((x) => x.id == r.id));
      await ref.read(remindersServiceProvider).deleteReminder(r.id);
      if (!mounted) return;
      _snack('تم حذف التذكير');
    } catch (e) {
      _snack('فشل الحذف: $e');
    }
  }

  void _snack(String s) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value
              ? cs.primary.withValues(alpha: 0.55)
              : cs.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final ct = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 56, color: ct.outline),
            const SizedBox(height: 12),
            Text(
              'لا توجد تذكيرات مخصصة بعد',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'أضف تذكيرًا يدويًا من الزر السفلي',
              style: TextStyle(color: ct.outline),
            ),
          ],
        ),
      ),
    );
  }
}
