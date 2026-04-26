enum MemorizationDifficulty {
  beginner,
  medium,
  hard,
  expert;

  String get label {
    switch (this) {
      case MemorizationDifficulty.beginner:
        return 'مبتدئ';
      case MemorizationDifficulty.medium:
        return 'متوسط';
      case MemorizationDifficulty.hard:
        return 'صعب';
      case MemorizationDifficulty.expert:
        return 'خبير';
    }
  }

  String get modeLabel {
    switch (this) {
      case MemorizationDifficulty.beginner:
        return 'اختيار من متعدد';
      case MemorizationDifficulty.medium:
        return 'إكمال آية';
      case MemorizationDifficulty.hard:
        return 'ترتيب كلمات';
      case MemorizationDifficulty.expert:
        return 'كتابة من الذاكرة';
    }
  }

  MemorizationDifficulty get next {
    switch (this) {
      case MemorizationDifficulty.beginner:
        return MemorizationDifficulty.medium;
      case MemorizationDifficulty.medium:
        return MemorizationDifficulty.hard;
      case MemorizationDifficulty.hard:
      case MemorizationDifficulty.expert:
        return MemorizationDifficulty.expert;
    }
  }

  MemorizationDifficulty get previous {
    switch (this) {
      case MemorizationDifficulty.beginner:
      case MemorizationDifficulty.medium:
        return MemorizationDifficulty.beginner;
      case MemorizationDifficulty.hard:
        return MemorizationDifficulty.medium;
      case MemorizationDifficulty.expert:
        return MemorizationDifficulty.hard;
    }
  }

  static MemorizationDifficulty fromJson(Object? value) {
    final name = value?.toString();
    return MemorizationDifficulty.values.firstWhere(
      (difficulty) => difficulty.name == name,
      orElse: () => MemorizationDifficulty.beginner,
    );
  }
}

class MemorizationLevel {
  const MemorizationLevel({
    required this.levelId,
    required this.sequence,
    required this.surahId,
    required this.surahName,
    required this.ayahStart,
    required this.ayahEnd,
    required this.stars,
    required this.xpEarned,
    required this.isUnlocked,
    required this.memoryStrength,
    required this.lastReviewed,
    required this.nextReview,
    required this.difficulty,
    required this.completedCount,
    required this.mistakesCount,
    required this.isBossReview,
  });

  final String levelId;
  final int sequence;
  final int surahId;
  final String surahName;
  final int ayahStart;
  final int ayahEnd;
  final int stars;
  final int xpEarned;
  final bool isUnlocked;
  final int memoryStrength;
  final DateTime? lastReviewed;
  final DateTime? nextReview;
  final MemorizationDifficulty difficulty;
  final int completedCount;
  final int mistakesCount;
  final bool isBossReview;

  int get ayahCount => ayahEnd - ayahStart + 1;
  bool get isCompleted => completedCount > 0;

  bool isDueToday(DateTime now) {
    if (!isCompleted || nextReview == null) return false;
    final startOfTomorrow = DateTime(now.year, now.month, now.day + 1);
    return nextReview!.isBefore(startOfTomorrow);
  }

  MemorizationLevel copyWith({
    String? levelId,
    int? sequence,
    int? surahId,
    String? surahName,
    int? ayahStart,
    int? ayahEnd,
    int? stars,
    int? xpEarned,
    bool? isUnlocked,
    int? memoryStrength,
    DateTime? lastReviewed,
    DateTime? nextReview,
    MemorizationDifficulty? difficulty,
    int? completedCount,
    int? mistakesCount,
    bool? isBossReview,
  }) {
    return MemorizationLevel(
      levelId: levelId ?? this.levelId,
      sequence: sequence ?? this.sequence,
      surahId: surahId ?? this.surahId,
      surahName: surahName ?? this.surahName,
      ayahStart: ayahStart ?? this.ayahStart,
      ayahEnd: ayahEnd ?? this.ayahEnd,
      stars: stars ?? this.stars,
      xpEarned: xpEarned ?? this.xpEarned,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      memoryStrength: memoryStrength ?? this.memoryStrength,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReview: nextReview ?? this.nextReview,
      difficulty: difficulty ?? this.difficulty,
      completedCount: completedCount ?? this.completedCount,
      mistakesCount: mistakesCount ?? this.mistakesCount,
      isBossReview: isBossReview ?? this.isBossReview,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'sequence': sequence,
      'surahId': surahId,
      'surahName': surahName,
      'ayahStart': ayahStart,
      'ayahEnd': ayahEnd,
      'stars': stars,
      'xpEarned': xpEarned,
      'isUnlocked': isUnlocked,
      'memoryStrength': memoryStrength,
      'lastReviewed': lastReviewed?.toIso8601String(),
      'nextReview': nextReview?.toIso8601String(),
      'difficulty': difficulty.name,
      'completedCount': completedCount,
      'mistakesCount': mistakesCount,
      'isBossReview': isBossReview,
    };
  }

  factory MemorizationLevel.fromJson(Map<String, dynamic> json) {
    return MemorizationLevel(
      levelId: json['levelId']?.toString() ?? '',
      sequence: _readInt(json['sequence']),
      surahId: _readInt(json['surahId']),
      surahName: json['surahName']?.toString() ?? '',
      ayahStart: _readInt(json['ayahStart'], fallback: 1),
      ayahEnd: _readInt(json['ayahEnd'], fallback: 1),
      stars: _readInt(json['stars']),
      xpEarned: _readInt(json['xpEarned']),
      isUnlocked: json['isUnlocked'] == true,
      memoryStrength: _readInt(
        json['memoryStrength'],
        fallback: 30,
      ).clamp(0, 100).toInt(),
      lastReviewed: _readDate(json['lastReviewed']),
      nextReview: _readDate(json['nextReview']),
      difficulty: MemorizationDifficulty.fromJson(json['difficulty']),
      completedCount: _readInt(json['completedCount']),
      mistakesCount: _readInt(json['mistakesCount']),
      isBossReview: json['isBossReview'] == true,
    );
  }
}

class LocalPlayerProfile {
  const LocalPlayerProfile({
    required this.totalXp,
    required this.hearts,
    required this.streak,
    required this.lastActiveDate,
    required this.completedLevels,
    required this.currentLevelId,
    required this.lastHeartRefillDate,
  });

  final int totalXp;
  final int hearts;
  final int streak;
  final DateTime? lastActiveDate;
  final int completedLevels;
  final String currentLevelId;
  final DateTime? lastHeartRefillDate;

  factory LocalPlayerProfile.initial(String firstLevelId) {
    final now = DateTime.now();
    return LocalPlayerProfile(
      totalXp: 0,
      hearts: 5,
      streak: 0,
      lastActiveDate: null,
      completedLevels: 0,
      currentLevelId: firstLevelId,
      lastHeartRefillDate: DateTime(now.year, now.month, now.day),
    );
  }

  LocalPlayerProfile copyWith({
    int? totalXp,
    int? hearts,
    int? streak,
    DateTime? lastActiveDate,
    int? completedLevels,
    String? currentLevelId,
    DateTime? lastHeartRefillDate,
  }) {
    return LocalPlayerProfile(
      totalXp: totalXp ?? this.totalXp,
      hearts: hearts ?? this.hearts,
      streak: streak ?? this.streak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      completedLevels: completedLevels ?? this.completedLevels,
      currentLevelId: currentLevelId ?? this.currentLevelId,
      lastHeartRefillDate: lastHeartRefillDate ?? this.lastHeartRefillDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalXp': totalXp,
      'hearts': hearts,
      'streak': streak,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'completedLevels': completedLevels,
      'currentLevelId': currentLevelId,
      'lastHeartRefillDate': lastHeartRefillDate?.toIso8601String(),
    };
  }

  factory LocalPlayerProfile.fromJson(Map<String, dynamic> json) {
    return LocalPlayerProfile(
      totalXp: _readInt(json['totalXp']),
      hearts: _readInt(json['hearts'], fallback: 5).clamp(0, 5).toInt(),
      streak: _readInt(json['streak']),
      lastActiveDate: _readDate(json['lastActiveDate']),
      completedLevels: _readInt(json['completedLevels']),
      currentLevelId: json['currentLevelId']?.toString() ?? '',
      lastHeartRefillDate: _readDate(json['lastHeartRefillDate']),
    );
  }
}

class MemorizationState {
  const MemorizationState({
    required this.profile,
    required this.levels,
    this.isGenerating = false,
  });

  final LocalPlayerProfile profile;
  final List<MemorizationLevel> levels;
  final bool isGenerating;

  int get totalLevels => levels.length;
  int get completedLevels => levels.where((level) => level.stars > 0).length;

  double get progressPercent {
    if (levels.isEmpty) return 0;
    return completedLevels / levels.length;
  }

  MemorizationLevel? get currentLevel {
    for (final level in levels) {
      if (level.levelId == profile.currentLevelId) return level;
    }
    for (final level in levels) {
      if (level.isUnlocked && !level.isCompleted) return level;
    }
    return levels.isEmpty ? null : levels.first;
  }

  List<MemorizationLevel> dueReviewLevels(DateTime now) {
    final due = levels.where((level) => level.isDueToday(now)).toList();
    due.sort((a, b) {
      final aDate = a.nextReview ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.nextReview ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aDate.compareTo(bDate);
    });
    return due;
  }

  MemorizationState copyWith({
    LocalPlayerProfile? profile,
    List<MemorizationLevel>? levels,
    bool? isGenerating,
  }) {
    return MemorizationState(
      profile: profile ?? this.profile,
      levels: levels ?? this.levels,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}

class MemorizationSessionResult {
  const MemorizationSessionResult({
    required this.levelId,
    required this.success,
    required this.stars,
    required this.xpEarned,
    required this.mistakes,
    required this.highSpeedBonus,
    required this.noMistakeBonus,
    required this.unlockedNext,
    required this.memoryStrength,
    required this.nextReview,
    required this.difficulty,
  });

  final String levelId;
  final bool success;
  final int stars;
  final int xpEarned;
  final int mistakes;
  final bool highSpeedBonus;
  final bool noMistakeBonus;
  final bool unlockedNext;
  final int memoryStrength;
  final DateTime? nextReview;
  final MemorizationDifficulty difficulty;
}

int _readInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

DateTime? _readDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
