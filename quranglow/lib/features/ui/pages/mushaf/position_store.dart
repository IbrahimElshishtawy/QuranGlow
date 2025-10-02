// lib/features/ui/pages/mushaf/position_store.dart

import 'package:shared_preferences/shared_preferences.dart';

class LastPosition {
  const LastPosition(this.surah, this.ayahIndex);
  final int surah;
  final int ayahIndex;
}

class PositionStore {
  static const _kSurah = 'last_surah';
  static const _kAyah = 'last_ayah';

  Future<void> save(int surah, int ayahIndex) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kSurah, surah);
    await sp.setInt(_kAyah, ayahIndex);
  }

  Future<LastPosition?> load() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getInt(_kSurah);
    final a = sp.getInt(_kAyah);
    if (s == null || a == null) return null;
    return LastPosition(s, a);
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kSurah);
    await sp.remove(_kAyah);
  }
}
