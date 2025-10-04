// lib/core/storage/local_storage_ext.dart
import 'dart:convert';
import 'package:quranglow/core/storage/local_storage.dart';

extension LocalStorageStringKV on LocalStorage {
  /// حفظ String
  Future<void> setString(String key, String value) async {
    await write(key, value); // يفترض LocalStorage فيه write(String, Object?)
  }

  /// قراءة String
  Future<String?> getString(String key) async {
    final v = await read(key); // لا تستخدم نوعيات جنريك هنا
    if (v == null) return null;
    return v is String ? v : v.toString();
  }

  /// حفظ JSON كـ String
  Future<void> setJson(String key, Object? value) async {
    await setString(key, jsonEncode(value));
  }

  /// قراءة JSON (مع فكّه)
  Future<T?> getJson<T>(String key) async {
    final raw = await getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as T;
    } catch (_) {
      return null;
    }
  }
}

Future<void> write(String key, String value) async {
  return;
}

Future<dynamic> read(String key) async {
  return null;
}
