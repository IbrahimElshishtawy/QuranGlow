import 'dart:async';
import 'package:quranglow/core/model/stats_models.dart';
import 'package:quranglow/core/service/stats_service.dart';

class StatsServiceMock implements StatsService {
  @override
  Future<StatsSummary> getSummary() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const StatsSummary(
      totalReading: Duration(hours: 12, minutes: 30),
      readAyat: 520,
      streakDays: 7,
      sessions: 34,
    );
  }

  @override
  Future<WeeklyProgress> getWeekly() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const WeeklyProgress([20, 45, 30, 60, 40, 75, 55]);
  }

  @override
  Future<MonthlyGoal> getMonthlyGoal() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const MonthlyGoal(
      title: 'هدف هذا الشهر',
      hint: 'إكمال 3 أجزاء',
      progress: 0.62,
    );
  }
}
