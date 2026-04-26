import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/service/quran/quran_service.dart';
import 'package:quranglow/features/memorization/data/memorization_level_factory.dart';
import 'package:quranglow/features/memorization/data/memorization_progress_store.dart';
import 'package:quranglow/features/memorization/domain/memorization_models.dart';

final memorizationProgressStoreProvider = Provider<MemorizationProgressStore>(
  (ref) => MemorizationProgressStore(ref.watch(storageProvider)),
);

final memorizationControllerProvider =
    StateNotifierProvider<
      MemorizationController,
      AsyncValue<MemorizationState>
    >((ref) {
      final controller = MemorizationController(
        quranService: ref.watch(quranServiceProvider),
        store: ref.watch(memorizationProgressStoreProvider),
        levelFactory: const MemorizationLevelFactory(),
      );
      controller.initialize();
      return controller;
    });

class MemorizationController
    extends StateNotifier<AsyncValue<MemorizationState>> {
  MemorizationController({
    required QuranService quranService,
    required MemorizationProgressStore store,
    required MemorizationLevelFactory levelFactory,
  }) : _quranService = quranService,
       _store = store,
       _levelFactory = levelFactory,
       super(const AsyncValue.loading());

  final QuranService _quranService;
  final MemorizationProgressStore _store;
  final MemorizationLevelFactory _levelFactory;
  bool _initialized = false;

  Future<void> initialize({bool forceRegenerate = false}) async {
    if (_initialized && !forceRegenerate && state.hasValue) return;

    state = const AsyncValue.loading();
    try {
      var levels = forceRegenerate ? null : await _store.loadLevels();
      var profile = forceRegenerate ? null : await _store.loadProfile();

      if (levels == null || levels.isEmpty) {
        final surahs = await _quranService.getQuranAllText('quran-uthmani');
        levels = _levelFactory.buildFromSurahs(surahs);
        if (levels.isEmpty) {
          throw StateError(
            'تعذر تحميل أي سورة من مصدر القرآن الحالي لإنشاء خريطة الحفظ.',
          );
        }
        await _store.saveLevels(levels);
      }

      profile ??= LocalPlayerProfile.initial(levels.first.levelId);
      final normalized = _normalizeProfile(profile, levels);
      await _store.saveProfile(normalized);

      _initialized = true;
      state = AsyncValue.data(
        MemorizationState(profile: normalized, levels: levels),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reload() async {
    _initialized = false;
    await initialize();
  }

  Future<int> loseHeart() async {
    final current = state.valueOrNull;
    if (current == null) return 0;

    final today = _startOfDay(DateTime.now());
    final profile = current.profile.copyWith(
      hearts: math.max(0, current.profile.hearts - 1),
      lastHeartRefillDate: today,
    );

    await _save(current.copyWith(profile: profile));
    return profile.hearts;
  }

  Future<MemorizationSessionResult> finishLevel({
    required String levelId,
    required int mistakes,
    required Duration elapsed,
    required bool reviewMode,
    required bool failedByHearts,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      throw StateError('Memorization state is not ready');
    }

    final index = current.levels.indexWhere(
      (level) => level.levelId == levelId,
    );
    if (index < 0) throw StateError('Level $levelId was not found');

    final now = DateTime.now();
    final levels = [...current.levels];
    final level = levels[index];
    final success = !failedByHearts && mistakes <= 3;
    final stars = success ? _starsFor(mistakes) : 0;
    final highSpeedBonus = success && _isFast(level, elapsed);
    final noMistakeBonus = success && mistakes == 0;
    final xp = success
        ? 10 + (noMistakeBonus ? 5 : 0) + (highSpeedBonus ? 5 : 0)
        : 0;
    final practicedDifficulty = reviewMode || level.isCompleted
        ? level.difficulty.next
        : level.difficulty;
    final nextDifficulty = _nextDifficulty(
      practicedDifficulty: practicedDifficulty,
      success: success,
      stars: stars,
      mistakes: mistakes,
    );
    final memoryStrength = _nextMemoryStrength(
      level.memoryStrength,
      success: success,
      stars: stars,
      mistakes: mistakes,
    );
    final nextReview = _nextReviewDate(
      now,
      level: level,
      success: success,
      stars: stars,
      memoryStrength: memoryStrength,
      difficulty: nextDifficulty,
    );

    var unlockedNext = false;
    if (success && stars >= 2 && index + 1 < levels.length) {
      final next = levels[index + 1];
      if (!next.isUnlocked) {
        levels[index + 1] = next.copyWith(isUnlocked: true);
        unlockedNext = true;
      }
    }

    levels[index] = level.copyWith(
      stars: math.max(level.stars, stars),
      xpEarned: level.xpEarned + xp,
      memoryStrength: memoryStrength,
      lastReviewed: now,
      nextReview: nextReview,
      difficulty: nextDifficulty,
      completedCount: success ? level.completedCount + 1 : level.completedCount,
      mistakesCount: level.mistakesCount + mistakes,
    );

    final completedLevels = levels.where((item) => item.stars > 0).length;
    final streakInfo = success
        ? _updatedStreak(current.profile, now)
        : (
            streak: current.profile.streak,
            lastActiveDate: current.profile.lastActiveDate,
          );

    final currentLevelId = _nextCurrentLevelId(
      levels: levels,
      fallbackLevelId: level.levelId,
      preferNext: success && stars >= 2,
    );

    final profile = current.profile.copyWith(
      totalXp: current.profile.totalXp + xp,
      streak: streakInfo.streak,
      lastActiveDate: streakInfo.lastActiveDate,
      completedLevels: completedLevels,
      currentLevelId: currentLevelId,
    );

    await _save(MemorizationState(profile: profile, levels: levels));

    return MemorizationSessionResult(
      levelId: levelId,
      success: success,
      stars: stars,
      xpEarned: xp,
      mistakes: mistakes,
      highSpeedBonus: highSpeedBonus,
      noMistakeBonus: noMistakeBonus,
      unlockedNext: unlockedNext,
      memoryStrength: memoryStrength,
      nextReview: nextReview,
      difficulty: nextDifficulty,
    );
  }

  LocalPlayerProfile _normalizeProfile(
    LocalPlayerProfile profile,
    List<MemorizationLevel> levels,
  ) {
    final today = _startOfDay(DateTime.now());
    var next = profile;

    if (next.currentLevelId.isEmpty ||
        !levels.any((level) => level.levelId == next.currentLevelId)) {
      next = next.copyWith(currentLevelId: levels.first.levelId);
    }

    final lastRefill = next.lastHeartRefillDate;
    if (lastRefill == null || !_sameDay(lastRefill, today)) {
      next = next.copyWith(hearts: 5, lastHeartRefillDate: today);
    }

    final completedLevels = levels.where((level) => level.stars > 0).length;
    if (next.completedLevels != completedLevels) {
      next = next.copyWith(completedLevels: completedLevels);
    }

    return next;
  }

  Future<void> _save(MemorizationState nextState) async {
    await _store.saveLevels(nextState.levels);
    await _store.saveProfile(nextState.profile);
    state = AsyncValue.data(nextState);
  }

  int _starsFor(int mistakes) {
    if (mistakes == 0) return 3;
    if (mistakes <= 2) return 2;
    if (mistakes == 3) return 1;
    return 0;
  }

  bool _isFast(MemorizationLevel level, Duration elapsed) {
    final targetSeconds = math.max(45, level.ayahCount * 12);
    return elapsed.inSeconds <= targetSeconds;
  }

  int _nextMemoryStrength(
    int current, {
    required bool success,
    required int stars,
    required int mistakes,
  }) {
    final delta = success
        ? switch (stars) {
            3 => 22,
            2 => 13,
            1 => 4,
            _ => 0,
          }
        : -18;
    return (current + delta - (mistakes * 2)).clamp(0, 100).toInt();
  }

  MemorizationDifficulty _nextDifficulty({
    required MemorizationDifficulty practicedDifficulty,
    required bool success,
    required int stars,
    required int mistakes,
  }) {
    if (!success || mistakes > 3 || stars <= 1) {
      return practicedDifficulty.previous;
    }
    if (stars == 3) return practicedDifficulty.next;
    return practicedDifficulty;
  }

  DateTime _nextReviewDate(
    DateTime now, {
    required MemorizationLevel level,
    required bool success,
    required int stars,
    required int memoryStrength,
    required MemorizationDifficulty difficulty,
  }) {
    if (!success) return now.add(const Duration(hours: 2));
    if (stars == 1) return now.add(const Duration(hours: 10));

    final baseHours = switch (difficulty) {
      MemorizationDifficulty.beginner => 20,
      MemorizationDifficulty.medium => 36,
      MemorizationDifficulty.hard => 72,
      MemorizationDifficulty.expert => 120,
    };
    final reviewMultiplier =
        1 + (memoryStrength / 100) + math.min(level.completedCount, 5) * 0.25;
    final starMultiplier = stars == 3 ? 1.35 : 1.0;
    return now.add(
      Duration(hours: (baseHours * reviewMultiplier * starMultiplier).round()),
    );
  }

  ({int streak, DateTime lastActiveDate}) _updatedStreak(
    LocalPlayerProfile profile,
    DateTime now,
  ) {
    final today = _startOfDay(now);
    final lastActive = profile.lastActiveDate;
    if (lastActive != null && _sameDay(lastActive, today)) {
      return (streak: profile.streak, lastActiveDate: today);
    }

    final yesterday = today.subtract(const Duration(days: 1));
    final streak = lastActive != null && _sameDay(lastActive, yesterday)
        ? profile.streak + 1
        : 1;
    return (streak: streak, lastActiveDate: today);
  }

  String _nextCurrentLevelId({
    required List<MemorizationLevel> levels,
    required String fallbackLevelId,
    required bool preferNext,
  }) {
    if (preferNext) {
      for (final level in levels) {
        if (level.isUnlocked && !level.isCompleted) return level.levelId;
      }
    }
    return fallbackLevelId;
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
