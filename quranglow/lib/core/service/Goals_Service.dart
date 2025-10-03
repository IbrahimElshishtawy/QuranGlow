// ignore_for_file: file_names

import 'package:hive/hive.dart';
import 'package:quranglow/core/model/goal.dart';

class GoalsService {
  static const boxName = 'goals';

  Future<Box<Goal>> _openBox() async => Hive.openBox<Goal>(boxName);

  Future<List<Goal>> listGoals() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<void> addGoal(Goal goal) async {
    final box = await _openBox();
    await box.add(goal);
  }

  Future<void> updateGoal(int key, Goal goal) async {
    final box = await _openBox();
    await box.put(key, goal);
  }

  Future<void> deleteGoal(int key) async {
    final box = await _openBox();
    await box.delete(key);
  }

  Future<void> clearGoals() async {
    final box = await _openBox();
    await box.clear();
  }
}
