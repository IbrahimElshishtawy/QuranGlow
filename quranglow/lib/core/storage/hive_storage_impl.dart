import 'package:hive/hive.dart';
import 'package:quranglow/core/constants/constants.dart';
import 'local_storage.dart';

class HiveStorageImpl implements LocalStorage {
  late Box _box;
  final String boxName;

  HiveStorageImpl({this.boxName = CoreConstants.appBoxName});

  @override
  Future<void> init() async {
    _box = await Hive.openBox(boxName);
  }

  @override
  Future<void> putString(String key, String value) async {
    await _box.put(key, value);
  }

  @override
  String? getString(String key) => _box.get(key) as String?;

  @override
  Future<void> putMap(String key, Map<String, dynamic> value) async {
    await _box.put(key, value);
  }

  @override
  Map<String, dynamic>? getMap(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    if (raw is Map) return Map<String, dynamic>.from(raw.cast());
    return null;
  }

  @override
  Future<void> delete(String key) => _box.delete(key);

  @override
  Future<void> clear() => _box.clear();
}
