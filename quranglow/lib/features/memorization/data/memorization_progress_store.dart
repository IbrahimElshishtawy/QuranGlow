import 'package:quranglow/core/storage/local_storage.dart';
import 'package:quranglow/core/storage/local_storage_ext.dart';
import 'package:quranglow/features/memorization/domain/memorization_models.dart';

class MemorizationProgressStore {
  MemorizationProgressStore(this.storage);

  final LocalStorage storage;

  static const _levelsKey = 'memorization_levels_v1';
  static const _profileKey = 'memorization_player_profile_v1';

  Future<List<MemorizationLevel>?> loadLevels() async {
    final raw = await storage.getJson<List<dynamic>>(_levelsKey);
    if (raw == null) return null;

    return raw
        .whereType<Map>()
        .map(
          (item) => MemorizationLevel.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((level) => level.levelId.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> saveLevels(List<MemorizationLevel> levels) {
    return storage.setJson(
      _levelsKey,
      levels.map((level) => level.toJson()).toList(growable: false),
    );
  }

  Future<LocalPlayerProfile?> loadProfile() async {
    final raw = await storage.getJson<Map<String, dynamic>>(_profileKey);
    if (raw == null) return null;
    return LocalPlayerProfile.fromJson(raw);
  }

  Future<void> saveProfile(LocalPlayerProfile profile) {
    return storage.setJson(_profileKey, profile.toJson());
  }
}
