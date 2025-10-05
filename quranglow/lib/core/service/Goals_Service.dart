// lib/core/service/goals_service.dart
// ignore_for_file: await_only_futures

import 'dart:async';
import 'dart:convert';
import 'package:quranglow/core/model/goal.dart';
import 'package:quranglow/core/storage/local_storage.dart';
import 'package:quranglow/core/storage/local_storage_ext.dart'; // هنضيفه تحت

class GoalsService {
  GoalsService({required LocalStorage storage}) : _storage = storage;

  static const _kGoalsKey = 'goals.defaults';
  final LocalStorage _storage;

  List<Goal> _cache = const [];
  final _controller = StreamController<List<Goal>>.broadcast();

  Future<List<Goal>> listGoals() async {
    if (_cache.isNotEmpty) return _cache;
    final raw = await _storage.getString(_kGoalsKey);
    if (raw != null && raw.isNotEmpty) {
      final List data = json.decode(raw) as List;
      _cache = data
          .map((e) => Goal.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      return _cache;
    }
    // افتراضي فارغ أو حط أي أهداف أولية لو حابب
    _cache = <Goal>[];
    return _cache;
  }

  Stream<List<Goal>> watchGoals() => _controller.stream;

  Stream<List<Goal>> watchGoalsWithInitial() async* {
    yield await listGoals();
    yield* _controller.stream;
  }

  Future<void> refresh() async {
    final goals = await listGoals();
    if (!_controller.isClosed) _controller.add(goals);
  }

  /// من الإعدادات: احفظ القائمة
  Future<void> setDefaults(List<Goal> goals) async {
    _cache = goals;
    await _storage.setString(
      _kGoalsKey,
      json.encode(goals.map((g) => g.toMap()).toList()),
    );
    if (!_controller.isClosed) _controller.add(_cache);
  }

  Future<void> updateGoal({
    required String title,
    required double progress,
  }) async {
    final goals = await listGoals();
    final i = goals.indexWhere((g) => g.title == title);
    if (i != -1) {
      final updated = goals[i].copyWith(progress: progress.clamp(0, 1));
      _cache = [...goals]..[i] = updated;
      await _storage.setString(
        _kGoalsKey,
        json.encode(_cache.map((g) => g.toMap()).toList()),
      );
      if (!_controller.isClosed) _controller.add(_cache);
    }
  }

  void dispose() => _controller.close();
}
