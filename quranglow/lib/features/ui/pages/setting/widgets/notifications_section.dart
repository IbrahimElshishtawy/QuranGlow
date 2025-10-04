import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/features/ui/pages/setting/widgets/settings_providers.dart';

import 'section_header.dart';

class NotificationsSection extends ConsumerWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(notificationsEnabledProvider);
    final time = ref.watch(reminderTimeProvider);

    String formatTime(TimeOfDay t) {
      final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
      final mm = t.minute.toString().padLeft(2, '0');
      final ampm = t.period == DayPeriod.am ? 'ص' : 'م';
      return '$h:$mm $ampm';
    }

    void toast(String msg) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }

    return Column(
      children: [
        const SectionHeader('الإشعارات'),
        SwitchListTile(
          title: const Text('تفعيل الإشعارات اليومية'),
          value: enabled,
          onChanged: (v) {
            ref.read(notificationsEnabledProvider.notifier).state = v;
            toast(v ? 'تم تفعيل الإشعارات' : 'تم إيقاف الإشعارات');
          },
        ),
        ListTile(
          enabled: enabled,
          leading: const Icon(Icons.alarm),
          title: const Text('وقت التذكير اليومي'),
          subtitle: Text(
            formatTime(time),
            style: TextStyle(
              color: enabled ? null : Theme.of(context).colorScheme.outline,
            ),
          ),
          trailing: const Icon(Icons.chevron_left),
          onTap: !enabled
              ? null
              : () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time,
                    helpText: 'اختر وقت التذكير اليومي',
                  );
                  if (picked != null) {
                    ref.read(reminderTimeProvider.notifier).state = picked;
                    toast('تم تعيين التذكير على ${formatTime(picked)}');
                  }
                },
        ),
      ],
    );
  }
}
