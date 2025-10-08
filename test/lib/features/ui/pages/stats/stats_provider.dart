import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/core/di/providers.dart';

class StatsVm {
  final String totalReading; // hh:mm
  final int ayatCount;
  final int sessions;
  final int streakDays;
  final List<int> weekly; // 0..100

  StatsVm({
    required this.totalReading,
    required this.ayatCount,
    required this.sessions,
    required this.streakDays,
    required this.weekly,
  });
}

String _fmt(int totalSeconds) {
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

final statsProvider = FutureProvider<StatsVm>((ref) async {
  final s = ref.read(trackingServiceProvider);
  final m = await s.getStats();
  return StatsVm(
    totalReading: _fmt(m['totalSeconds'] as int),
    ayatCount: m['ayatCount'] as int,
    sessions: m['sessions'] as int,
    streakDays: m['streakDays'] as int,
    weekly: (m['weekly'] as List).cast<int>(),
  );
});
