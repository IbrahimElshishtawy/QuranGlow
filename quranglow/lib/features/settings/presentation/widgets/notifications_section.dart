// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/service/setting/daily_reminder_kind.dart';
import 'package:quranglow/core/service/setting/notification_service.dart';

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
  late final ProviderSubscription<DailyReminderKind> _dailyKindSub;
  late final ProviderSubscription<bool> _salawatEnabledSub;
  late final ProviderSubscription<TimeOfDay> _salawatTimeSub;

  String _kindLabel(DailyReminderKind kind) {
    switch (kind) {
      case DailyReminderKind.quran:
        return 'تلاوة القرآن';
      case DailyReminderKind.adhan:
        return 'الاستعداد للصلاة';
      case DailyReminderKind.dhikr:
        return 'الأذكار';
    }
  }

  void _snack(String s, {Color? bg}) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s), backgroundColor: bg ?? cs.primary),
    );
  }

  Future<void> _rescheduleDaily() async {
    final enabled = ref.read(notificationsEnabledProvider);
    final time = ref.read(reminderTimeProvider);
    final kind = ref.read(dailyReminderKindProvider);

    await NotificationService.instance.scheduleDailyReminder(
      enabled: enabled,
      time: time,
      kind: kind,
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
        await _rescheduleDaily();
        _snack(enabled ? 'تم تفعيل التذكير اليومي' : 'تم إيقاف التذكير اليومي');
      } catch (e) {
        _snack(
          'تعذّر تحديث التذكير اليومي: $e',
          bg: Theme.of(context).colorScheme.error,
        );
      }
    }, fireImmediately: true);

    _dailyTimeSub = ref.listenManual<TimeOfDay>(reminderTimeProvider, (
      prev,
      time,
    ) async {
      try {
        await _rescheduleDaily();
        if (ref.read(notificationsEnabledProvider)) {
          _snack('تم تحديث وقت التذكير اليومي إلى ${time.format(context)}');
        }
      } catch (e) {
        _snack(
          'تعذّر تحديث الوقت: $e',
          bg: Theme.of(context).colorScheme.error,
        );
      }
    });

    _dailyKindSub = ref.listenManual<DailyReminderKind>(
      dailyReminderKindProvider,
      (prev, next) async {
        try {
          await _rescheduleDaily();
          if (ref.read(notificationsEnabledProvider)) {
            _snack('تم تحديث نوع التذكير اليومي');
          }
        } catch (e) {
          _snack(
            'تعذّر تحديث نوع التذكير: $e',
            bg: Theme.of(context).colorScheme.error,
          );
        }
      },
    );

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
          enabled ? 'تم تفعيل تذكير الصلاة على النبي' : 'تم إيقاف تذكير الصلاة على النبي',
        );
      } catch (e) {
        _snack(
          'تعذّر تحديث تذكير الصلاة على النبي: $e',
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
          _snack('تم تحديث وقت تذكير الصلاة على النبي إلى ${time.format(context)}');
        }
      } catch (e) {
        _snack(
          'تعذّر تحديث وقت التذكير: $e',
          bg: Theme.of(context).colorScheme.error,
        );
      }
    });
  }

  @override
  void dispose() {
    _dailyEnabledSub.close();
    _dailyTimeSub.close();
    _dailyKindSub.close();
    _salawatEnabledSub.close();
    _salawatTimeSub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dailyEnabled = ref.watch(notificationsEnabledProvider);
    final dailyTime = ref.watch(reminderTimeProvider);
    final dailyKind = ref.watch(dailyReminderKindProvider);
    final salawatEnabled = ref.watch(salawatEnabledProvider);
    final salawatTime = ref.watch(salawatTimeProvider);

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active_rounded, color: cs.primary),
                const SizedBox(width: 8),
                const Text(
                  'إعدادات الإشعارات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: dailyEnabled,
              title: const Text('تفعيل التذكير اليومي'),
              onChanged: (v) =>
                  ref.read(notificationsEnabledProvider.notifier).state = v,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('نوع التذكير'),
              subtitle: Text(_kindLabel(dailyKind)),
              trailing: DropdownButton<DailyReminderKind>(
                value: dailyKind,
                onChanged: (v) {
                  if (v == null) return;
                  ref.read(dailyReminderKindProvider.notifier).state = v;
                },
                items: const [
                  DropdownMenuItem(
                    value: DailyReminderKind.quran,
                    child: Text('القرآن'),
                  ),
                  DropdownMenuItem(
                    value: DailyReminderKind.adhan,
                    child: Text('الصلاة'),
                  ),
                  DropdownMenuItem(
                    value: DailyReminderKind.dhikr,
                    child: Text('الأذكار'),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: salawatEnabled,
              title: const Text('تفعيل تذكير الصلاة على النبي'),
              onChanged: (v) => ref.read(salawatEnabledProvider.notifier).state = v,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('وقت تذكير الصلاة على النبي'),
              subtitle: Text(salawatTime.format(context)),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: salawatTime,
                );
                if (t != null) {
                  ref.read(salawatTimeProvider.notifier).state = t;
                }
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('إرسال إشعار تجريبي الآن'),
                onPressed: () async {
                  try {
                    final kindText = _kindLabel(dailyKind);
                    await NotificationService.instance.scheduleReminder(
                      id: 991001,
                      title: 'تنبيه تجريبي ($kindText)',
                      body: 'هذا إشعار تجريبي من تطبيق QuranGlow.',
                      when: DateTime.now().add(const Duration(seconds: 3)),
                      daily: false,
                    );
                    _snack('سيظهر الإشعار التجريبي خلال ثوانٍ');
                  } catch (e) {
                    _snack(
                      'تعذّر إرسال الإشعار التجريبي: $e',
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
