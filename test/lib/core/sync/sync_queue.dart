import 'dart:async';
import '../storage/local_storage.dart';
import '../utils/logger.dart';

class SyncQueue {
  final LocalStorage storage;
  final String _queueKey = 'sync_jobs';
  final StreamController<void> _controller = StreamController.broadcast();

  SyncQueue({required this.storage});

  Future<List<Map<String, dynamic>>> _load() async {
    final m = storage.getMap(_queueKey);
    if (m == null) return [];
    final list = m['jobs'] as List? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> _save(List<Map<String, dynamic>> jobs) =>
      storage.putMap(_queueKey, {'jobs': jobs});

  Future<void> enqueue(Map<String, dynamic> job) async {
    final jobs = await _load();
    jobs.add(job);
    await _save(jobs);
    _controller.add(null);
    L.d('SyncQueue', 'enqueued job ${job['type'] ?? ''}');
  }

  Future<Map<String, dynamic>?> dequeue() async {
    final jobs = await _load();
    if (jobs.isEmpty) return null;
    final job = jobs.removeAt(0);
    await _save(jobs);
    L.d('SyncQueue', 'dequeued job ${job['type'] ?? ''}');
    return job;
  }

  Future<List<Map<String, dynamic>>> peekAll() => _load();

  Stream<void> get onNew => _controller.stream;

  Future<void> clear() async {
    await storage.delete(_queueKey);
  }

  void dispose() {
    _controller.close();
  }
}
