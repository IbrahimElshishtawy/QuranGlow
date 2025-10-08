import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranglow/core/di/providers.dart';
import 'package:quranglow/core/model/aya/aya.dart';
import 'package:quranglow/core/model/book/surah.dart';

class BookmarksUseCase {
  final Ref ref;
  BookmarksUseCase(this.ref);

  Future<Surah> fetchSurah(int surah) async {
    final svc = ref.read(quranServiceProvider);
    return svc.getSurahText('quran-uthmani', surah);
  }

  Future<(Surah, Aya?)> resolveAyah(int surahNum, int ayahInSurah) async {
    final surah = await fetchSurah(surahNum);
    Aya? aya;
    try {
      aya = surah.ayat.firstWhere((a) {
        final nIn = (a as dynamic).numberInSurah;
        if (nIn is int && nIn > 0) return nIn == ayahInSurah;
        return a.number == ayahInSurah;
      });
    } catch (_) {
      try {
        aya = surah.ayat.firstWhere((a) => a.number == ayahInSurah);
      } catch (_) {}
    }
    return (surah, aya);
  }

  Future<String> getSurahName(int surahNum) async {
    final s = await fetchSurah(surahNum);
    return s.name;
  }

  Future<int> getAyatCount(int surahNum) async {
    final s = await fetchSurah(surahNum);
    return s.ayat.length;
  }
}
