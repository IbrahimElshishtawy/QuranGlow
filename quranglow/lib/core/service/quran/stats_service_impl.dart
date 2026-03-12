import 'package:quranglow/core/model/book/stats_models.dart';
import 'package:quranglow/core/service/quran/stats_service.dart';
import 'package:quranglow/core/service/tracking_service.dart';

class StatsServiceImpl implements StatsService {
  final TrackingService trackingService;

  StatsServiceImpl(this.trackingService);

  @override
  Future<StatsSummary> getSummary() async {
    final stats = await trackingService.getStats();
    return StatsSummary(
      totalReading: Duration(seconds: (stats['totalSeconds'] as int?) ?? 0),
      readAyat: (stats['ayatCount'] as int?) ?? 0,
      streakDays: (stats['streakDays'] as int?) ?? 0,
      sessions: (stats['sessions'] as int?) ?? 0,
      memorizedCount: (stats['memorizedCount'] as int?) ?? 0,
      listeningTime: Duration(seconds: (stats['listeningSeconds'] as int?) ?? 0),
      remembranceCount: (stats['remembranceCount'] as int?) ?? 0,
    );
  }

  @override
  Future<WeeklyProgress> getWeekly() async {
    final stats = await trackingService.getStats();
    final weeklyRaw = stats['weekly'] as List?;
    final weekly = weeklyRaw?.cast<int>() ?? List<int>.filled(7, 0);
    return WeeklyProgress(weekly);
  }

  @override
  Future<MonthlyGoal> getMonthlyGoal() async {
    final stats = await trackingService.getStats();
    final readAyat = (stats['ayatCount'] as int?) ?? 0;
    const targetAyat = 500;
    final progress = (readAyat / targetAyat).clamp(0.0, 1.0);

    return MonthlyGoal(
      title: 'الهدف الشهري',
      hint: 'قرأت $readAyat من أصل $targetAyat آية هذا الشهر',
      progress: progress,
    );
  }
}
