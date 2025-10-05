// lib/core/service/goals_service.dart
// ignore_for_file: unused_field

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:quranglow/core/model/goal.dart';
import 'package:quranglow/core/storage/local_storage.dart';

class GoalsService {
  GoalsService({LocalStorage? storage}) : _storage = storage;

  final LocalStorage? _storage;

  List<Goal> _cache = const [];
  final _controller = StreamController<List<Goal>>.broadcast();

  List<Goal> _defaults() => const [
    Goal(title: 'ورد يومي', progress: 0.5),
    Goal(title: 'حفظ سورة', progress: 0.24),
    Goal(title: 'تدبّر آيات', progress: 0.8),
  ];

  Future<List<Goal>> listGoals() async {
    try {
      if (_cache.isNotEmpty) return _cache;
      _cache = _defaults();
      return _cache;
    } catch (e, st) {
      debugPrint('GoalsService.listGoals error: $e\n$st');
      _cache = _cache.isNotEmpty ? _cache : _defaults();
      return _cache;
    }
  }

  Stream<List<Goal>> watchGoals() => _controller.stream;

  /// أول دفعة + أي تحديثات لاحقة — مع حماية من الأخطاء
  Stream<List<Goal>> watchGoalsWithInitial() async* {
    try {
      final first = await listGoals();
      yield first;
    } catch (e, st) {
      debugPrint('watchGoalsWithInitial initial error: $e\n$st');
      yield _cache.isNotEmpty ? _cache : _defaults();
    }

    // لو حصل Error لاحقًا ما نرميهوش برا، بس نطبعه
    yield* _controller.stream.handleError((e, st) {
      debugPrint('watchGoalsWithInitial stream error: $e\n$st');
    });
  }

  /// ادفع نسخة محدثة للستريم (مثلاً بعد كتابة/قراءة)
  Future<void> refresh() async {
    final goals = await listGoals();
    if (!_controller.isClosed) _controller.add(goals);
  }

  Future<void> updateGoal({
    required String title,
    required double progress,
  }) async {
    final goals = await listGoals();
    final i = goals.indexWhere((g) => g.title == title);
    if (i != -1) {
      final updated = Goal(
        title: goals[i].title,
        progress: progress.clamp(0, 1),
      );
      _cache = [...goals]..[i] = updated;
      if (!_controller.isClosed) _controller.add(_cache);
    }
  }

  void dispose() {
    _controller.close();
  }
}
