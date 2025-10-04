import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

// حالياً StateProviders بسيطة (لو عايز نخزنها دايمًا نربط SharedPrefs لاحقًا)
final notificationsEnabledProvider = StateProvider<bool>((_) => false);
final reminderTimeProvider = StateProvider<TimeOfDay>(
  (_) => const TimeOfDay(hour: 7, minute: 30),
);

final keepScreenOnProvider = StateProvider<bool>((_) => false);
final useCellularProvider = StateProvider<bool>((_) => true);
final hapticsProvider = StateProvider<bool>((_) => true);
final reduceMotionProvider = StateProvider<bool>((_) => false);
