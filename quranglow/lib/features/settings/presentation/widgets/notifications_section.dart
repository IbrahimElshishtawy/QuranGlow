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
        _snack(enabled ? 'Daily reminder enabled' : 'Daily reminder disabled');
      } catch (e) {
        _snack(
          'Failed to update daily reminder: $e',
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
          _snack('Daily reminder time updated to ${time.format(context)}');
        }
      } catch (e) {
        _snack(
          'Failed to update time: $e',
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
            _snack('Daily reminder type updated');
          }
        } catch (e) {
          _snack(
            'Failed to update reminder type: $e',
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
          enabled ? 'Salawat reminder enabled' : 'Salawat reminder disabled',
        );
      } catch (e) {
        _snack(
          'Failed to update salawat reminder: $e',
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
          _snack('Salawat reminder time updated to ${time.format(context)}');
        }
      } catch (e) {
        _snack(
          'Failed to update salawat time: $e',
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
    final dailyEnabled = ref.watch(notificationsEnabledProvider);
    final dailyTime = ref.watch(reminderTimeProvider);
    final dailyKind = ref.watch(dailyReminderKindProvider);
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
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              value: dailyEnabled,
              title: const Text('Enable daily reminder'),
              onChanged: (v) =>
                  ref.read(notificationsEnabledProvider.notifier).state = v,
            ),
            ListTile(
              title: const Text('Daily reminder time'),
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
              title: const Text('Reminder content type'),
              subtitle: Text(switch (dailyKind) {
                DailyReminderKind.quran => 'Quran reading',
                DailyReminderKind.adhan => 'Adhan / Salah prep',
                DailyReminderKind.dhikr => 'Dhikr',
              }),
              trailing: DropdownButton<DailyReminderKind>(
                value: dailyKind,
                onChanged: (v) {
                  if (v == null) return;
                  ref.read(dailyReminderKindProvider.notifier).state = v;
                },
                items: const [
                  DropdownMenuItem(
                    value: DailyReminderKind.quran,
                    child: Text('Quran'),
                  ),
                  DropdownMenuItem(
                    value: DailyReminderKind.adhan,
                    child: Text('Adhan'),
                  ),
                  DropdownMenuItem(
                    value: DailyReminderKind.dhikr,
                    child: Text('Dhikr'),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            SwitchListTile(
              value: salawatEnabled,
              title: const Text('Enable salawat reminder'),
              onChanged: (v) =>
                  ref.read(salawatEnabledProvider.notifier).state = v,
            ),
            ListTile(
              title: const Text('Salawat reminder time'),
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
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('Test notification now'),
                onPressed: () async {
                  try {
                    final kindText = switch (dailyKind) {
                      DailyReminderKind.quran => 'Quran',
                      DailyReminderKind.adhan => 'Adhan',
                      DailyReminderKind.dhikr => 'Dhikr',
                    };
                    await NotificationService.instance.scheduleReminder(
                      id: 991001,
                      title: 'Test Notification ($kindText)',
                      body: 'This is a test notification from QuranGlow.',
                      when: DateTime.now().add(const Duration(seconds: 3)),
                      daily: false,
                    );
                    _snack('Test notification will appear in a few seconds');
                  } catch (e) {
                    _snack(
                      'Failed to schedule test: $e',
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
