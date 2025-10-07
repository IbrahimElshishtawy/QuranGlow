import 'package:quranglow/core/model/book/stats_models.dart';

abstract class StatsService {
  Future<StatsSummary> getSummary();
  Future<WeeklyProgress> getWeekly();
  Future<MonthlyGoal> getMonthlyGoal();
}
