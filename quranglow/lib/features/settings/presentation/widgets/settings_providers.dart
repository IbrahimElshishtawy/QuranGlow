import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DailyReminderKind { quran, adhan, dhikr }

final notificationsEnabledProvider = StateProvider<bool>((ref) => false);

final reminderTimeProvider = StateProvider<TimeOfDay>(
  (ref) => const TimeOfDay(hour: 7, minute: 30),
);

final dailyReminderKindProvider = StateProvider<DailyReminderKind>(
  (ref) => DailyReminderKind.quran,
);

final salawatEnabledProvider = StateProvider<bool>((ref) => false);

final salawatTimeProvider = StateProvider<TimeOfDay>(
  (ref) => const TimeOfDay(hour: 12, minute: 0),
);

final keepScreenOnProvider = StateProvider<bool>((ref) => false);
final useCellularProvider = StateProvider<bool>((ref) => true);
final hapticsProvider = StateProvider<bool>((ref) => true);
final reduceMotionProvider = StateProvider<bool>((ref) => false);
