import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/features/ui/pages/setting/widgets/settings_providers.dart';
import 'section_header.dart';

class NotificationsSection extends ConsumerWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledDaily = ref.watch(notificationsEnabledProvider);
    final timeDaily = ref.watch(reminderTimeProvider);

    final enabledSalawat = ref.watch(salawatEnabledProvider);
    final timeSalawat = ref.watch(salawatTimeProvider);

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
          value: enabledDaily,
          onChanged: (v) {
            ref.read(notificationsEnabledProvider.notifier).state = v;
            toast(v ? 'تم تفعيل الإشعارات' : 'تم إيقاف الإشعارات');
          },
        ),
        ListTile(
          enabled: enabledDaily,
          leading: const Icon(Icons.alarm),
          title: const Text('وقت التذكير اليومي'),
          subtitle: Text(
            formatTime(timeDaily),
            style: TextStyle(
              color: enabledDaily
                  ? null
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
          trailing: const Icon(Icons.chevron_left),
          onTap: !enabledDaily
              ? null
              : () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: timeDaily,
                    helpText: 'اختر وقت التذكير اليومي',
                  );
                  if (picked != null) {
                    ref.read(reminderTimeProvider.notifier).state = picked;
                    toast('تم تعيين التذكير على ${formatTime(picked)}');
                  }
                },
        ),
        const SectionHeader('الصلاة على النبي ﷺ'),
        SwitchListTile(
          title: const Text('تفعيل تذكير الصلاة على النبي'),
          value: enabledSalawat,
          onChanged: (v) {
            ref.read(salawatEnabledProvider.notifier).state = v;
            toast(v ? 'تم تفعيل تذكير الصلاة على النبي' : 'تم إيقاف التذكير');
          },
        ),
        ListTile(
          enabled: enabledSalawat,
          leading: const Icon(Icons.favorite_outline),
          title: const Text('وقت الترديد اليومي'),
          subtitle: Text(
            formatTime(timeSalawat),
            style: TextStyle(
              color: enabledSalawat
                  ? null
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
          trailing: const Icon(Icons.chevron_left),
          onTap: !enabledSalawat
              ? null
              : () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: timeSalawat,
                    helpText: 'اختر وقت ترديد الصلاة على النبي',
                  );
                  if (picked != null) {
                    ref.read(salawatTimeProvider.notifier).state = picked;
                    toast('تم تعيين الترديد على ${formatTime(picked)}');
                  }
                },
        ),
      ],
    );
  }
}
