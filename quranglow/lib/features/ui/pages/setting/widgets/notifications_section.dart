import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/service/setting/notification_service.dart';
import 'package:quranglow/features/ui/pages/setting/widgets/settings_providers.dart';

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

    // Daily reminder
    _dailyEnabledSub = ref.listenManual<bool>(
      notificationsEnabledProvider,
          (prev, enabled) async {
        final t = ref.read(reminderTimeProvider);
        await NotificationService.instance.scheduleDailyReminder(
          enabled: enabled,
          time: t,
        );
      },
      fireImmediately: true, // شغّل عند الإقلاع لو محتاج
    );

    _dailyTimeSub = ref.listenManual<TimeOfDay>(
      reminderTimeProvider,
          (prev, time) async {
        final en = ref.read(notificationsEnabledProvider);
        await NotificationService.instance.scheduleDailyReminder(
          enabled: en,
          time: time,
        );
      },
    );

    // Salawat
    _salawatEnabledSub = ref.listenManual<bool>(
      salawatEnabledProvider,
          (prev, enabled) async {
        final t = ref.read(salawatTimeProvider);
        await NotificationService.instance.scheduleSalawat(
          enabled: enabled,
          time: t,
        );
      },
      fireImmediately: true,
    );

    _salawatTimeSub = ref.listenManual<TimeOfDay>(
      salawatTimeProvider,
          (prev, time) async {
        final en = ref.read(salawatEnabledProvider);
        await NotificationService.instance.scheduleSalawat(
          enabled: en,
          time: time,
        );
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
    return const Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Notifications settings UI here'),
        ),
      ),
    );
  }
}
