// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../../../../core/model/reminder/reminder.dart';

class ReminderTile extends StatelessWidget {
  const ReminderTile({
    super.key,
    required this.r,
    required this.onEdit,
    required this.onSchedule,
    required this.onCancel,
    required this.onDelete,
  });

  final Reminder r;
  final VoidCallback onEdit, onSchedule, onCancel, onDelete;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(r.dateTime).format(context);
    // 1=Mon..7=Sun
    final week = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    final day = week[r.dateTime.weekday - 1];
    final fmt =
        '$day ${r.dateTime.day}/${r.dateTime.month}/${r.dateTime.year} • $time';

    return Card(
      child: ListTile(
        leading: Icon(r.scheduled ? Icons.notifications_active : Icons.alarm),
        title: Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '$fmt${r.daily ? ' • يوميًا' : ''}'
          '${(r.notes?.isNotEmpty ?? false) ? '\n${r.notes}' : ''}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            switch (v) {
              case 'schedule':
                onSchedule();
                break;
              case 'edit':
                onEdit();
                break;
              case 'cancel':
                onCancel();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'schedule', child: Text('جدولة/تحديث')),
            PopupMenuItem(value: 'edit', child: Text('تعديل')),
            PopupMenuItem(value: 'cancel', child: Text('إلغاء الإشعار')),
            PopupMenuItem(value: 'delete', child: Text('حذف')),
          ],
        ),
      ),
    );
  }
}
