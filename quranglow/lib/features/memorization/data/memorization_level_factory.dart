import 'package:quranglow/core/model/book/surah.dart';
import 'package:quranglow/features/memorization/domain/memorization_models.dart';

class MemorizationLevelFactory {
  const MemorizationLevelFactory();

  List<MemorizationLevel> buildFromSurahs(List<Surah> surahs) {
    final levels = <MemorizationLevel>[];

    for (final surah in surahs) {
      final totalAyat = surah.ayat.length;
      if (totalAyat == 0) continue;

      final chunkSize = _chunkSizeFor(totalAyat);
      for (var start = 1; start <= totalAyat; start += chunkSize) {
        final sequence = levels.length + 1;
        final end = (start + chunkSize - 1).clamp(1, totalAyat).toInt();
        final isBossReview = sequence % 8 == 0;

        levels.add(
          MemorizationLevel(
            levelId: 's${surah.number}_a${start}_$end',
            sequence: sequence,
            surahId: surah.number,
            surahName: surah.name,
            ayahStart: start,
            ayahEnd: end,
            stars: 0,
            xpEarned: 0,
            isUnlocked: sequence == 1,
            memoryStrength: 30,
            lastReviewed: null,
            nextReview: null,
            difficulty: _difficultyFor(sequence, isBossReview),
            completedCount: 0,
            mistakesCount: 0,
            isBossReview: isBossReview,
          ),
        );
      }
    }

    return levels;
  }

  int _chunkSizeFor(int ayatCount) {
    if (ayatCount <= 8) return ayatCount;
    if (ayatCount <= 28) return 5;
    if (ayatCount <= 90) return 8;
    return 10;
  }

  MemorizationDifficulty _difficultyFor(int sequence, bool isBossReview) {
    if (isBossReview && sequence > 16) return MemorizationDifficulty.hard;
    if (sequence <= 18) return MemorizationDifficulty.beginner;
    if (sequence <= 72) return MemorizationDifficulty.medium;
    if (sequence <= 180) return MemorizationDifficulty.hard;
    return MemorizationDifficulty.expert;
  }
}
