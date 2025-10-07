import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/service/notification_service.dart';
import 'package:quranglow/features/ui/pages/setting/widgets/settings_providers.dart';

class NotificationsSection extends ConsumerStatefulWidget {
  const NotificationsSection({super.key});
  @override
  ConsumerState<NotificationsSection> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<NotificationsSection> {
  @override
  void initState() {
    super.initState();

    // daily
    ref.listen<bool>(notificationsEnabledProvider, (_, enabled) async {
      final t = ref.read(reminderTimeProvider);
      await NotificationService.instance.scheduleDailyReminder(
        enabled: enabled,
        time: t,
      );
    });

    ref.listen<TimeOfDay>(reminderTimeProvider, (_, time) async {
      final en = ref.read(notificationsEnabledProvider);
      await NotificationService.instance.scheduleDailyReminder(
        enabled: en,
        time: time,
      );
    });

    // salawat
    ref.listen<bool>(salawatEnabledProvider, (_, enabled) async {
      final t = ref.read(salawatTimeProvider);
      await NotificationService.instance.scheduleSalawat(
        enabled: enabled,
        time: t,
      );
    });

    ref.listen<TimeOfDay>(salawatTimeProvider, (_, time) async {
      final en = ref.read(salawatEnabledProvider);
      await NotificationService.instance.scheduleSalawat(
        enabled: en,
        time: time,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null, // حسب تصميمك
      body: SingleChildScrollView(child: NotificationsSection()),
    );
  }
}
