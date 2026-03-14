class PrayerTimesData {
  const PrayerTimesData({
    required this.timezone,
    required this.methodName,
    required this.prayers,
    required this.nextPrayerName,
    required this.nextPrayerTime,
  });

  final String timezone;
  final String methodName;
  final Map<String, DateTime> prayers;
  final String nextPrayerName;
  final DateTime nextPrayerTime;
}

class PrayerScheduleDay {
  const PrayerScheduleDay({
    required this.date,
    required this.timezone,
    required this.methodName,
    required this.prayers,
  });

  final DateTime date;
  final String timezone;
  final String methodName;
  final Map<String, DateTime> prayers;
}
