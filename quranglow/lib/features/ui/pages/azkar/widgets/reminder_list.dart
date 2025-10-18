// lib/features/ui/pages/azkar/widgets/reminder_list.dart
// ignore_for_file: prefer_const_constructors, dead_code

import 'package:flutter/material.dart';
import 'package:quranglow/core/service/setting/notification_service.dart';
import 'package:quranglow/features/ui/pages/azkar/widgets/reminder_editor.dart';
import 'package:quranglow/features/ui/pages/azkar/widgets/reminder_tile.dart';
import '../../../../../core/model/reminder/reminder.dart';

class ReminderList extends StatefulWidget {
  const ReminderList({super.key});

  @override
  State<ReminderList> createState() => _ReminderListState();
}

class _ReminderListState extends State<ReminderList> {
  final List<Reminder> _items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('إضافة'),
        onPressed: _openEditor,
      ),
      body: _items.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => ReminderTile(
                r: _items[i],
                onEdit: () => _openEditor(edit: _items[i]),
                onSchedule: () => _schedule(_items[i]),
                onCancel: () => _cancel(_items[i]),
                onDelete: () => _delete(_items[i]),
              ),
            ),
    );
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
      } else {
        edit.title = res.title;
        edit.dateTime = res.dateTime;
        edit.daily = res.daily;
        edit.notes = res.notes;
      }
    });
  }

  Future<void> _schedule(Reminder r) async {
    try {
      if (r.dateTime.isBefore(DateTime.now()) && !r.daily) {
        r.dateTime = DateTime.now()
            .add(const Duration(days: 1))
            .copyWith(hour: r.dateTime.hour, minute: r.dateTime.minute);
      }

      await NotificationService.instance.scheduleReminder(
        id: r.id,
        title: r.title.isNotEmpty ? r.title : 'تذكير',
        body: r.notes?.isNotEmpty == true ? r.notes! : 'موعد تذكيرك الآن',
        when: r.dateTime,
        daily: r.daily,
      );

      setState(() => r.scheduled = true);
      _snack('تمت جدولة التذكير بنجاح');
    } catch (e) {
      _snack('فشلت الجدولة: $e');
    }
  }

  Future<void> _cancel(Reminder r) async {
    try {
      await NotificationService.instance.cancel(r.id);
      setState(() => r.scheduled = false);
      _snack('تم إلغاء التذكير');
    } catch (e) {
      _snack('فشل الإلغاء: $e');
    }
  }

  void _delete(Reminder r) {
    try {
      NotificationService.instance.cancel(r.id).catchError((_) {});
      setState(() => _items.removeWhere((x) => x.id == r.id));
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final ct = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 64, color: ct.outline),
          const SizedBox(height: 12),
          Text(
            'لا توجد تذكيرات بعد',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'أضف تذكيرًا من زر الإضافة',
            style: TextStyle(color: ct.outline),
          ),
        ],
      ),
    );
  }
}
