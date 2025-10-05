// lib/core/storage/hive_storage_impl.dart
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:quranglow/core/constants/constants.dart';
import 'package:quranglow/core/storage/local_storage.dart';

class HiveStorageImpl implements LocalStorage {
  HiveStorageImpl({this.boxName = CoreConstants.appBoxName});

  final String boxName;
  Box? _box; // قابل للا-null لتجنّب LateInitializationError

  Future<void> _ensureBox() async {
    if (Hive.isBoxOpen(boxName)) {
      _box ??= Hive.box(boxName);
      return;
    }
    _box = await Hive.openBox(boxName);
  }

  @override
  Future<void> init() async => _ensureBox();

  // --- واجهة LocalStorage الأساسية ---
  @override
  Future<void> write(String key, Object? value) async {
    await _ensureBox();
    await _box!.put(key, value);
  }

  @override
  Future<T?> read<T>(String key) async {
    await _ensureBox();
    final v = _box!.get(key);
    return v as T?;
  }

  @override
  Future<void> remove(String key) async {
    await _ensureBox();
    await _box!.delete(key);
  }

  @override
  Future<void> clear() async {
    await _ensureBox();
    await _box!.clear();
  }

  // --- Helpers ---
  @override
  Future<void> putString(String key, String value) => write(key, value);

  // getString/getMap متزامنتان: أعِد null بأمان إن لم يكن الـBox جاهزًا بعد
  @override
  String? getString(String key) {
    final bx = Hive.isBoxOpen(boxName) ? Hive.box(boxName) : _box;
    if (bx == null) return null;
    final v = bx.get(key);
    if (v == null) return null;
    return v is String ? v : v.toString();
  }

  @override
  Future<void> putMap(String key, Map<String, dynamic> value) =>
      write(key, value);

  @override
  Map<String, dynamic>? getMap(String key) {
    final bx = Hive.isBoxOpen(boxName) ? Hive.box(boxName) : _box;
    if (bx == null) return null;

    final v = bx.get(key);
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
