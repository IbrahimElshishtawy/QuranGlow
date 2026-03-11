import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/prayer/prayer_times_data.dart';

final prayerTimesProvider = FutureProvider.autoDispose<PrayerTimesData>((ref) {
  return ref.watch(prayerTimesServiceProvider).fetchForToday();
});
