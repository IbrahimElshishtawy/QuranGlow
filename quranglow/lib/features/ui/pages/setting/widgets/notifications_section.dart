import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/service/setting/notification_service.dart';
import 'settings_providers.dart';


class NotificationsSection extends ConsumerStatefulWidget {
  const NotificationsSection({super.key});
  @override
  ConsumerState<NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends ConsumerState<NotificationsSection> {
  late final ProviderSubscription<bool> _dailyEnabledSub;
  late final ProviderSubscription<TimeOfDay> _dailyTimeSub;
  late final ProviderSubscription<bool> _salawatEnabledSub;
  late final ProviderSubscription<TimeOfDay> _salawatTimeSub;

  @override
  void initState() {
    super.initState();

    _dailyEnabledSub = ref.listenManual<bool>(
      notificationsEnabledProvider,
          (prev, enabled) async {
        final t = ref.read(reminderTimeProvider);
        await NotificationService.instance.scheduleDailyReminder(enabled: enabled, time: t);
      },
      fireImmediately: true,
    );

    _dailyTimeSub = ref.listenManual<TimeOfDay>(
      reminderTimeProvider,
          (prev, time) async {
        final en = ref.read(notificationsEnabledProvider);
        await NotificationService.instance.scheduleDailyReminder(enabled: en, time: time);
      },
    );

    _salawatEnabledSub = ref.listenManual<bool>(
      salawatEnabledProvider,
          (prev, enabled) async {
        final t = ref.read(salawatTimeProvider);
        await NotificationService.instance.scheduleSalawat(enabled: enabled, time: t);
      },
      fireImmediately: true,
    );

    _salawatTimeSub = ref.listenManual<TimeOfDay>(
      salawatTimeProvider,
          (prev, time) async {
        final en = ref.read(salawatEnabledProvider);
        await NotificationService.instance.scheduleSalawat(enabled: en, time: time);
      },
    );
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('الإشعارات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            value: dailyEnabled,
            title: const Text('تفعيل التذكير اليومي'),
            onChanged: (v) => ref.read(notificationsEnabledProvider.notifier).state = v,
          ),
          ListTile(
            title: const Text('وقت التذكير اليومي'),
            subtitle: Text(dailyTime.format(context)),
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: dailyTime);
              if (t != null) ref.read(reminderTimeProvider.notifier).state = t;
            },
          ),
          const Divider(height: 24),
          SwitchListTile(
            value: salawatEnabled,
            title: const Text('تفعيل تذكير الصلاة على النبي ﷺ'),
            onChanged: (v) => ref.read(salawatEnabledProvider.notifier).state = v,
          ),
          ListTile(
            title: const Text('الوقت'),
            subtitle: Text(salawatTime.format(context)),
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: salawatTime);
              if (t != null) ref.read(salawatTimeProvider.notifier).state = t;
            },
          ),
        ]),
      ),
    );
  }
}
