import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quranglow/core/model/setting/goal.dart';
import 'package:quranglow/core/service/setting/notification_service.dart';
import 'package:quranglow/core/storage/local_storage.dart';

class GoalsService {
  static const _kStorageKey = 'goals.v2';

  GoalsService({required LocalStorage storage}) : _storage = storage;

  final LocalStorage _storage;
  List<Goal> _cache = const [];
  final _controller = StreamController<List<Goal>>.broadcast();

  Future<List<Goal>> listGoals() async {
    if (_cache.isNotEmpty) return _cache;

    final raw = _storage.getString(_kStorageKey) ?? _storage.getString('goals.v1');
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        _cache = list
            .whereType<Map>()
            .map((e) => Goal.fromMap(Map<String, dynamic>.from(e)))
            .toList();
        if (_cache.isNotEmpty) return _cache;
      } catch (_) {}
    }

    _cache = _defaults();
    await saveAll(_cache);
    return _cache;
  }

  Stream<List<Goal>> watchGoalsWithInitial() async* {
    yield await listGoals();
    yield* _controller.stream;
  }

  Future<void> saveAll(List<Goal> goals) async {
    _cache = goals;
    final encoded = jsonEncode(goals.map((g) => g.toMap()).toList());
    await _storage.putString(_kStorageKey, encoded);
    await _syncGoalReminders(goals);
    if (!_controller.isClosed) _controller.add(_cache);
  }

  Future<void> upsertGoal(Goal goal) async {
    final list = List<Goal>.from(await listGoals());
    final idx = list.indexWhere((g) => g.id == goal.id);
    if (idx == -1) {
      list.add(goal);
    } else {
      list[idx] = goal;
    }
    await saveAll(list);
  }

  Future<void> deleteGoal(String id) async {
    final list = List<Goal>.from(await listGoals())..removeWhere((g) => g.id == id);
    await NotificationService.instance.cancel(_notificationIdFor(id));
    await saveAll(list);
  }

  Future<void> increment(String id, {int by = 1}) async {
    final list = List<Goal>.from(await listGoals());
    final idx = list.indexWhere((g) => g.id == id);
    if (idx == -1) return;
    final current = list[idx];
    list[idx] = current.copyWith(
      current: (current.current + by).clamp(0, current.target),
    );
    await saveAll(list);
  }

  Future<void> decrement(String id, {int by = 1}) async {
    await increment(id, by: -by);
  }

  Future<void> resetProgress(String id) async {
    final list = List<Goal>.from(await listGoals());
    final idx = list.indexWhere((g) => g.id == id);
    if (idx == -1) return;
    list[idx] = list[idx].copyWith(current: 0);
    await saveAll(list);
  }

  Future<void> trackReading({int verses = 1}) => _bump(GoalType.reading, verses);
  Future<void> trackListening({int verses = 1}) => _bump(GoalType.listening, verses);
  Future<void> trackMemorization({int verses = 1}) =>
      _bump(GoalType.memorization, verses);
  Future<void> trackTafsir({int verses = 1}) => _bump(GoalType.tafsir, verses);

  Future<void> _bump(GoalType type, int by) async {
    final list = List<Goal>.from(await listGoals());
    var changed = false;
    for (var i = 0; i < list.length; i++) {
      final goal = list[i];
      if (!goal.active || goal.type != type || goal.completed) continue;
      list[i] = goal.copyWith(
        current: (goal.current + by).clamp(0, goal.target),
      );
      changed = true;
    }
    if (changed) await saveAll(list);
  }

  Future<void> _syncGoalReminders(List<Goal> goals) async {
    for (final goal in goals) {
      final id = _notificationIdFor(goal.id);
      if (!goal.active || !goal.reminderEnabled) {
        await NotificationService.instance.cancel(id);
        continue;
      }
      await NotificationService.instance.scheduleReminder(
        id: id,
        title: 'تذكير هدف: ${goal.title}',
        body: 'متبقي ${goal.target - goal.current} ${goal.unit} لإكمال هدفك.',
        when: DateTime(
          2000,
          1,
          1,
          goal.reminderHour,
          goal.reminderMinute,
        ),
        daily: true,
      );
    }
  }

  int _notificationIdFor(String id) =>
      700000 + id.codeUnits.fold<int>(0, (sum, e) => sum + e) % 100000;

  List<Goal> _defaults() => [
    Goal(
      id: 'reading-daily',
      title: 'ورد القراءة اليومي',
      type: GoalType.reading,
      target: 40,
      unit: 'آية',
      reminderEnabled: true,
      reminderHour: 9,
    ),
    Goal(
      id: 'listening-daily',
      title: 'الاستماع اليومي',
      type: GoalType.listening,
      target: 40,
      unit: 'آية',
      reminderHour: 13,
    ),
    Goal(
      id: 'memorize-weekly',
      title: 'الحفظ الأسبوعي',
      type: GoalType.memorization,
      target: 20,
      unit: 'آية',
      reminderHour: 17,
    ),
    Goal(
      id: 'tafsir-daily',
      title: 'التفسير اليومي',
      type: GoalType.tafsir,
      target: 10,
      unit: 'آية',
      reminderHour: 20,
    ),
  ];

  void dispose() => _controller.close();
}
