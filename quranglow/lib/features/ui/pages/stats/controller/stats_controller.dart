import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/stats_models.dart';

class StatsState {
  final StatsSummary summary;
  final WeeklyProgress weekly;
  final MonthlyGoal goal;
  const StatsState({
    required this.summary,
    required this.weekly,
    required this.goal,
  });
}

final statsControllerProvider =
    StateNotifierProvider<StatsController, AsyncValue<StatsState>>((ref) {
      return StatsController(ref)..reload();
    });

class StatsController extends StateNotifier<AsyncValue<StatsState>> {
  StatsController(this._ref) : super(const AsyncValue.loading());
  final Ref _ref;

  Future<void> reload() async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(statsServiceProvider);
      final summary = await service.getSummary();
      final weekly = await service.getWeekly();
      final goal = await service.getMonthlyGoal();
      state = AsyncValue.data(
        StatsState(summary: summary, weekly: weekly, goal: goal),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
