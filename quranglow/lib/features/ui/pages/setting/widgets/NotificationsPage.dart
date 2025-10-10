import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/features/ui/pages/setting/widgets/settings_providers.dart';

class NotificationsSection extends ConsumerStatefulWidget {
  const NotificationsSection({super.key});

  @override
  ConsumerState<NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends ConsumerState<NotificationsSection> {
  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(notificationsEnabledProvider);
    final time = ref.watch(reminderTimeProvider);

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الإشعارات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SwitchListTile(
              value: enabled,
              title: const Text('تفعيل التذكير اليومي'),
              onChanged: (v) =>
              ref.read(notificationsEnabledProvider.notifier).state = v,
            ),
            ListTile(
              title: const Text('وقت التذكير اليومي'),
              subtitle: Text(time.format(context)),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: time);
                if (picked != null) {
                  ref.read(reminderTimeProvider.notifier).state = picked;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
