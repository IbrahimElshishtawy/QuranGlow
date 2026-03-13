// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/setting/adhan_sound.dart';
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
  static const _salawatIntervals = <int>[5, 10, 15, 20, 25];

  late final ProviderSubscription<bool> _dailyEnabledSub;
  late final ProviderSubscription<TimeOfDay> _dailyTimeSub;
  late final ProviderSubscription<DailyReminderKind> _dailyKindSub;
  late final ProviderSubscription<bool> _salawatEnabledSub;
  late final ProviderSubscription<int> _salawatIntervalSub;

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

  void _snack(String text, {Color? bg}) {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text), backgroundColor: bg ?? cs.primary));
  }

  Future<void> _rescheduleDaily() async {
    if (!mounted) return;
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
      if (!mounted) return;
      try {
        await _rescheduleDaily();
        if (!mounted) return;
        _snack(enabled ? 'تم تفعيل التذكير اليومي' : 'تم إيقاف التذكير اليومي');
      } catch (e) {
        if (!mounted) return;
        _snack(
          'تعذر تحديث التذكير اليومي: $e',
          bg: Theme.of(context).colorScheme.error,
        );
      }
    }, fireImmediately: true);

    _dailyTimeSub = ref.listenManual<TimeOfDay>(reminderTimeProvider, (
      prev,
      time,
    ) async {
      if (!mounted) return;
      try {
        await _rescheduleDaily();
        if (!mounted) return;
        if (ref.read(notificationsEnabledProvider)) {
          _snack('تم تحديث وقت التذكير اليومي إلى ${time.format(context)}');
        }
      } catch (e) {
        if (!mounted) return;
        _snack(
          'تعذر تحديث الوقت: $e',
          bg: Theme.of(context).colorScheme.error,
        );
      }
    });

    _dailyKindSub = ref.listenManual<DailyReminderKind>(
      dailyReminderKindProvider,
      (prev, next) async {
        if (!mounted) return;
        try {
          await _rescheduleDaily();
          if (!mounted) return;
          if (ref.read(notificationsEnabledProvider)) {
            _snack('تم تحديث نوع التذكير اليومي');
          }
        } catch (e) {
          if (!mounted) return;
          _snack(
            'تعذر تحديث نوع التذكير: $e',
            bg: Theme.of(context).colorScheme.error,
          );
        }
      },
    );

    _salawatEnabledSub = ref.listenManual<bool>(salawatEnabledProvider, (
      prev,
      enabled,
    ) async {
      if (!mounted) return;
      try {
        final interval = ref.read(salawatIntervalMinutesProvider);
        await NotificationService.instance.scheduleSalawat(
          enabled: enabled,
          intervalMinutes: interval,
        );
        if (!mounted) return;
        _snack(
          enabled
              ? 'تم تفعيل تذكير الصلاة على النبي'
              : 'تم إيقاف تذكير الصلاة على النبي',
        );
      } catch (e) {
        if (!mounted) return;
        _snack(
          'تعذر تحديث تذكير الصلاة على النبي: $e',
          bg: Theme.of(context).colorScheme.error,
        );
      }
    }, fireImmediately: true);

    _salawatIntervalSub = ref.listenManual<int>(
      salawatIntervalMinutesProvider,
      (prev, interval) async {
        if (!mounted) return;
        try {
          final enabled = ref.read(salawatEnabledProvider);
          await NotificationService.instance.scheduleSalawat(
            enabled: enabled,
            intervalMinutes: interval,
          );
          if (!mounted) return;
          if (enabled) {
            _snack('تم تحديث تكرار التذكير إلى كل $interval دقائق');
          }
        } catch (e) {
          if (!mounted) return;
          _snack(
            'تعذر تحديث تكرار التذكير: $e',
            bg: Theme.of(context).colorScheme.error,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _dailyEnabledSub.close();
    _dailyTimeSub.close();
    _dailyKindSub.close();
    _salawatEnabledSub.close();
    _salawatIntervalSub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dailyEnabled = ref.watch(notificationsEnabledProvider);
    final dailyTime = ref.watch(reminderTimeProvider);
    final dailyKind = ref.watch(dailyReminderKindProvider);
    final salawatEnabled = ref.watch(salawatEnabledProvider);
    final salawatInterval = ref.watch(salawatIntervalMinutesProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final selectedAdhan = settings?.adhanSound ?? AdhanSounds.makkah;

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
              onChanged: (value) =>
                  ref.read(notificationsEnabledProvider.notifier).state = value,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('وقت التذكير اليومي'),
              subtitle: Text(dailyTime.format(context)),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: dailyTime,
                );
                if (picked != null) {
                  ref.read(reminderTimeProvider.notifier).state = picked;
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('صوت أذان الإشعار'),
              subtitle: Text(selectedAdhan.label),
              trailing: DropdownButton<String>(
                value: selectedAdhan.id,
                onChanged: (value) async {
                  if (value == null) return;
                  await ref.read(settingsProvider.notifier).setAdhanSoundId(value);
                  if (!mounted) return;
                  _snack('تم تغيير صوت الأذان إلى ${AdhanSounds.byId(value).label}');
                },
                items: AdhanSounds.values
                    .map(
                      (sound) => DropdownMenuItem<String>(
                        value: sound.id,
                        child: Text(sound.label),
                      ),
                    )
                    .toList(),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('نوع التذكير'),
              subtitle: Text(_kindLabel(dailyKind)),
              trailing: DropdownButton<DailyReminderKind>(
                value: dailyKind,
                onChanged: (value) {
                  if (value == null) return;
                  ref.read(dailyReminderKindProvider.notifier).state = value;
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
              subtitle: const Text('رسالة متكررة: صلِّ على محمد ﷺ'),
              onChanged: (value) =>
                  ref.read(salawatEnabledProvider.notifier).state = value,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('تكرار التذكير'),
              subtitle: Text('كل $salawatInterval دقائق'),
              trailing: DropdownButton<int>(
                value: salawatInterval,
                onChanged: (value) {
                  if (value == null) return;
                  ref.read(salawatIntervalMinutesProvider.notifier).state = value;
                },
                items: _salawatIntervals
                    .map(
                      (minutes) => DropdownMenuItem<int>(
                        value: minutes,
                        child: Text('كل $minutes دقائق'),
                      ),
                    )
                    .toList(),
              ),
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
                    await NotificationService.instance
                        .requestPermissionsIfNeededFromUI(context);
                    await NotificationService.instance.showInstant(
                      id: 991001,
                      title: 'تنبيه تجريبي ($kindText)',
                      body: 'هذا إشعار تجريبي من تطبيق QuranGlow.',
                    );
                    _snack('تم إرسال إشعار تجريبي فوري');
                  } catch (e) {
                    _snack(
                      'تعذر إرسال الإشعار التجريبي: $e',
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
