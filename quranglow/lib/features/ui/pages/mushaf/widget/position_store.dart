// lib/features/ui/pages/mushaf/widgets/position_store.dart
import 'package:shared_preferences/shared_preferences.dart';

class LastPosition {
  final int surah;
  final int ayahIndex;
  const LastPosition({required this.surah, required this.ayahIndex});
}

class PositionStore {
  Future<void> save(int surah, int ayahIndex) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('pos.$surah', ayahIndex);
    await p.setInt('last.surah', surah);
    await p.setInt('last.ayahIndex', ayahIndex);
  }

  Future<int?> load(int surah) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('pos.$surah');
  }

  Future<LastPosition?> loadLast() async {
    final p = await SharedPreferences.getInstance();
    final surah = p.getInt('last.surah');
    final ayahIndex = p.getInt('last.ayahIndex');
    if (surah == null || ayahIndex == null) return null;
    return LastPosition(surah: surah, ayahIndex: ayahIndex);
  }
}
