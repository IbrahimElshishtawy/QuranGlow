class StatsSummary {
  final Duration totalReading; // إجمالي وقت القراءة
  final int readAyat; // الآيات المقروءة
  final int streakDays; // أيام المواظبة
  final int sessions; // عدد الجلسات
  const StatsSummary({
    required this.totalReading,
    required this.readAyat,
    required this.streakDays,
    required this.sessions,
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
