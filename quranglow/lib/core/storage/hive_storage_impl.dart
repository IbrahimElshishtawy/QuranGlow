// lib/core/storage/hive_storage_impl.dart
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:quranglow/core/constants/constants.dart';
import 'package:quranglow/core/storage/local_storage.dart';

class HiveStorageImpl implements LocalStorage {
  HiveStorageImpl({this.boxName = CoreConstants.appBoxName});

  final String boxName;
  late Box _box;

  @override
  Future<void> init() async {
    _box = Hive.isBoxOpen(boxName)
        ? Hive.box(boxName)
        : await Hive.openBox(boxName);
  }

  // --- واجهة LocalStorage الأساسية ---
  @override
  Future<void> write(String key, Object? value) async {
    await _box.put(key, value);
  }

  @override
  Future<T?> read<T>(String key) async {
    final v = _box.get(key);
    return v as T?;
  }

  @override
  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }

  // --- Helpers ---
  @override
  Future<void> putString(String key, String value) => write(key, value);

  // يجب أن تكون متزامنة لتطابق LocalStorage.getString: String? Function(String)
  @override
  String? getString(String key) {
    final v = _box.get(key);
    if (v == null) return null;
    return v is String ? v : v.toString();
  }

  @override
  Future<void> putMap(String key, Map<String, dynamic> value) =>
      write(key, value);

  // يجب أن تكون متزامنة لتطابق LocalStorage.getMap: Map<String, dynamic>? Function(String)
  @override
  Map<String, dynamic>? getMap(String key) {
    final v = _box.get(key);
    if (v is Map) {
      return Map<String, dynamic>.from(v.cast<String, dynamic>());
    }
    if (v is String) {
      try {
        final decoded = jsonDecode(v);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded.cast<String, dynamic>());
        }
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<void> delete(String key) async {
    await remove(key);
  }
}
