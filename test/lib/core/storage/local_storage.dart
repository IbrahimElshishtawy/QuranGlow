abstract class LocalStorage {
  Future<void> init(); // init if necessary
  Future<void> putString(String key, String value);
  String? getString(String key);
  Future<void> putMap(String key, Map<String, dynamic> value);
  Map<String, dynamic>? getMap(String key);
  Future<void> delete(String key);
  Future<void> clear();
  Future<T?> read<T>(String key);
  Future<void> write(String key, Object? value);
  Future<void> remove(String key);
}
