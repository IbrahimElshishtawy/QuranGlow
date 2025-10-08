// lib/core/service/goals_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:quranglow/core/model/setting/goal.dart';

import 'package:quranglow/core/storage/local_storage.dart';

class GoalsService {
  static const _kStorageKey = 'goals.v1';

  GoalsService({required LocalStorage storage}) : _storage = storage;

  final LocalStorage _storage;

  List<Goal> _cache = const [];
  final _controller = StreamController<List<Goal>>.broadcast();

  Future<List<Goal>> listGoals() async {
    if (_cache.isNotEmpty) return _cache;

    final raw = _storage.getString(_kStorageKey); // getString متزامنة
    if (raw != null && raw.isNotEmpty) {
      try {
        final List list = jsonDecode(raw);
        _cache = list.map((e) => Goal.fromMap(e)).cast<Goal>().toList();
        return _cache;
      } catch (e, st) {
        debugPrint('Goals decode error: $e\n$st');
      }
    }
    _cache = _defaults();
    return _cache;
  }

  Future<void> saveAll(List<Goal> goals) async {
    _cache = goals;
    final s = jsonEncode(goals.map((g) => g.toMap()).toList());
    await _storage.putString(_kStorageKey, s);
    if (!_controller.isClosed) _controller.add(_cache);
  }

  Stream<List<Goal>> watchGoalsWithInitial() async* {
    yield await listGoals();
    yield* _controller.stream;
  }

  // تتبّع تلقائي حسب الحدث
  Future<void> trackReading({int verses = 1}) =>
      _bump(GoalType.reading, verses);
  Future<void> trackListening({int verses = 1}) =>
      _bump(GoalType.listening, verses);
  Future<void> trackMemorization({int verses = 1}) =>
      _bump(GoalType.memorization, verses);
  Future<void> trackTafsir({int verses = 1}) => _bump(GoalType.tafsir, verses);

  Future<void> _bump(GoalType t, int by) async {
    final goals = await listGoals();
    bool changed = false;
    final upd = goals.map((g) {
      if (!g.active || g.type != t) return g;
      changed = true;
      final next = g.current + by;
      return g.copyWith(current: next > g.target ? g.target : next);
    }).toList();
    if (changed) await saveAll(upd);
  }

  List<Goal> _defaults() => [
    Goal(
      id: 'reading-daily',
      type: GoalType.reading,
      title: 'ورد قراءة يومي',
      target: 40,
      unit: 'آية',
    ),
    Goal(
      id: 'listening-daily',
      type: GoalType.listening,
      title: 'استماع يومي',
      target: 40,
      unit: 'آية',
    ),
    Goal(
      id: 'memorize-weekly',
      type: GoalType.memorization,
      title: 'حفظ أسبوعي',
      target: 20,
      unit: 'آية',
    ),
    Goal(
      id: 'tafsir-daily',
      type: GoalType.tafsir,
      title: 'تفسير يومي',
      target: 10,
      unit: 'آية',
    ),
  ];

  void dispose() => _controller.close();
}
