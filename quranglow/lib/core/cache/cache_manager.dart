import 'package:quranglow/core/constants/constants.dart';
import 'package:quranglow/core/storage/local_storage.dart';

import '../utils/logger.dart';

class CacheManager {
  final LocalStorage storage;
  final Duration ttl;

  CacheManager({required this.storage, this.ttl = const Duration(days: 7)});

  String _key(String k) => '${CoreConstants.cachePrefix}$k';

  Future<void> put(String key, Map<String, dynamic> value) async {
    final wrapped = {'ts': DateTime.now().toIso8601String(), 'data': value};
    await storage.putMap(_key(key), wrapped);
    L.d('CacheManager', 'cached $key');
  }

  Map<String, dynamic>? get(String key) {
    final m = storage.getMap(_key(key));
    if (m == null) return null;
    try {
      final ts = DateTime.parse(m['ts'] as String);
      if (DateTime.now().difference(ts) > ttl) {
        // expired
        return null;
      }
      return Map<String, dynamic>.from(m['data'] as Map);
    } catch (e, st) {
      L.e('CacheManager', e, st);
      return null;
    }
  }

  Future<void> clear(String key) => storage.delete(_key(key));
}
