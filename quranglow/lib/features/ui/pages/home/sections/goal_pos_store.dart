// lib/features/ui/pages/home/sections/goal_pos_store.dart
import 'package:shared_preferences/shared_preferences.dart';

class GoalPos {
  const GoalPos(this.surah, this.ayahIndex);
  final int surah;
  final int ayahIndex;
}

class GoalPosStore {
  static String _kS(Object goalId) => 'pos_${goalId.toString()}_surah';
  static String _kA(Object goalId) => 'pos_${goalId.toString()}_ayah';

  Future<GoalPos?> load(Object goalId) async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getInt(_kS(goalId));
    final a = sp.getInt(_kA(goalId));
    if (s == null || a == null) return null;
    return GoalPos(s, a);
  }

  Future<void> save(Object goalId, int surah, int ayahIndex) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kS(goalId), surah);
    await sp.setInt(_kA(goalId), ayahIndex);
  }

  Future<void> clear(Object goalId) async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kS(goalId));
    await sp.remove(_kA(goalId));
  }
}
