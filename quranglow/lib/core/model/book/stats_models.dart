class StatsSummary {
  final Duration totalReading; // إجمالي وقت القراءة
  final int readAyat; // الآيات المقروءة
  final int streakDays; // أيام المواظبة
  final int sessions; // عدد الجلسات
  final int memorizedCount;
  final Duration listeningTime;
  final int remembranceCount;

  const StatsSummary({
    required this.totalReading,
    required this.readAyat,
    required this.streakDays,
    required this.sessions,
    this.memorizedCount = 0,
    this.listeningTime = Duration.zero,
    this.remembranceCount = 0,
  });
}

class WeeklyProgress {
  final List<int> dailyPercent;
  const WeeklyProgress(this.dailyPercent);
}

class MonthlyGoal {
  final String title;
  final String hint;
  final double progress;
  const MonthlyGoal({
    required this.title,
    required this.hint,
    required this.progress,
  });
}
