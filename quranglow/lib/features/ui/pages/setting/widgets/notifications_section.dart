// lib/features/ui/pages/settings/widgets/notifications_section.dart
// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/service/setting/notification_service.dart';
import 'settings_providers.dart';

class NotificationsSection extends ConsumerStatefulWidget {
  const NotificationsSection({super.key});
  @override
  ConsumerState<NotificationsSection> createState() =>
      _NotificationsSectionState();
}

class _NotificationsSectionState extends ConsumerState<NotificationsSection> {
  late final ProviderSubscription<bool> _dailyEnabledSub;
  late final ProviderSubscription<TimeOfDay> _dailyTimeSub;
  late final ProviderSubscription<bool> _salawatEnabledSub;
  late final ProviderSubscription<TimeOfDay> _salawatTimeSub;

  void _snack(String s, {Color? bg}) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s), backgroundColor: bg ?? cs.primary),
    );
  }

  @override
  void initState() {
    super.initState();

    _dailyEnabledSub = ref.listenManual<bool>(notificationsEnabledProvider, (
      prev,
      enabled,
    ) async {
      try {
        final t = ref.read(reminderTimeProvider);
        await NotificationService.instance.scheduleDailyReminder(
          enabled: enabled,
          time: t,
        );
        _snack(enabled ? 'تم تفعيل التذكير اليومي' : 'تم إيقاف التذكير اليومي');
      } catch (e) {
        _snack(
          'فشل ضبط التذكير اليومي: $e',
          bg: Theme.of(context).colorScheme.error,
        );
      }
    }, fireImmediately: true);

    _dailyTimeSub = ref.listenManual<TimeOfDay>(reminderTimeProvider, (
      prev,
      time,
    ) async {
      try {
        final en = ref.read(notificationsEnabledProvider);
        await NotificationService.instance.scheduleDailyReminder(
          enabled: en,
          time: time,
        );
        if (en) {
          _snack('تم تحديث وقت التذكير اليومي إلى ${time.format(context)}');
        }
      } catch (e) {
        _snack(
          'فشل تحديث وقت التذكير اليومي: $e',
          bg: Theme.of(context).colorScheme.error,
        );
      }
    });

    _salawatEnabledSub = ref.listenManual<bool>(salawatEnabledProvider, (
      prev,
      enabled,
    ) async {
      try {
        final t = ref.read(salawatTimeProvider);
        await NotificationService.instance.scheduleSalawat(
          enabled: enabled,
          time: t,
        );
        _snack(
          enabled
              ? 'تم تفعيل تذكير الصلاة على النبي ﷺ'
              : 'تم إيقاف تذكير الصلاة على النبي ﷺ',
        );
      } catch (e) {
        _snack(
          'فشل ضبط تذكير الصلاة على النبي ﷺ: $e',
          bg: Theme.of(context).colorScheme.error,
        );
      }
    }, fireImmediately: true);

    _salawatTimeSub = ref.listenManual<TimeOfDay>(salawatTimeProvider, (
      prev,
      time,
    ) async {
      try {
        final en = ref.read(salawatEnabledProvider);
        await NotificationService.instance.scheduleSalawat(
          enabled: en,
          time: time,
        );
        if (en) {
          _snack(
            'تم تحديث وقت تذكير الصلاة على النبي ﷺ إلى ${time.format(context)}',
          );
        }
      } catch (e) {
        _snack('فشل تحديث الوقت: $e', bg: Theme.of(context).colorScheme.error);
      }
    });
  }

  @override
  void dispose() {
    _dailyEnabledSub.close();
    _dailyTimeSub.close();
    _salawatEnabledSub.close();
    _salawatTimeSub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dailyEnabled = ref.watch(notificationsEnabledProvider);
    final dailyTime = ref.watch(reminderTimeProvider);
    final salawatEnabled = ref.watch(salawatEnabledProvider);
    final salawatTime = ref.watch(salawatTimeProvider);

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الإشعارات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // التذكير اليومي
            SwitchListTile(
              value: dailyEnabled,
              title: const Text('تفعيل التذكير اليومي'),
              onChanged: (v) =>
                  ref.read(notificationsEnabledProvider.notifier).state = v,
            ),
            ListTile(
              title: const Text('وقت التذكير اليومي'),
              subtitle: Text(dailyTime.format(context)),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: dailyTime,
                );
                if (t != null) {
                  ref.read(reminderTimeProvider.notifier).state = t;
                }
              },
            ),

            const Divider(height: 24),

            // تذكير الصلاة على النبي ﷺ
            SwitchListTile(
              value: salawatEnabled,
              title: const Text('تفعيل تذكير الصلاة على النبي ﷺ'),
              onChanged: (v) =>
                  ref.read(salawatEnabledProvider.notifier).state = v,
            ),
            ListTile(
              title: const Text('الوقت'),
              subtitle: Text(salawatTime.format(context)),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: salawatTime,
                );
                if (t != null) ref.read(salawatTimeProvider.notifier).state = t;
              },
            ),

            const SizedBox(height: 8),

            // زر اختبار سريع
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('اختبار إشعار الآن'),
                onPressed: () async {
                  try {
                    await NotificationService.instance.scheduleReminder(
                      id: 991001,
                      title: 'اختبار إشعار',
                      body: 'هذا إشعار اختباري للتأكد من الصلاحيات والقناة.',
                      when: DateTime.now().add(const Duration(seconds: 3)),
                      daily: false,
                    );
                    _snack('سيصل إشعار الاختبار بعد ثوانٍ');
                  } catch (e) {
                    _snack(
                      'فشل إرسال اختبار: $e',
                      bg: Theme.of(context).colorScheme.error,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
