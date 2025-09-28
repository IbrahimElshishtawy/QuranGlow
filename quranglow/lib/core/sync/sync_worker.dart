import 'dart:async';

import '../storage/local_storage.dart';
import 'sync_queue.dart';
import '../utils/logger.dart';

/// A minimal worker that listens to queue changes and network status.
/// On online it processes jobs by calling a provided handler callback.
/// You must provide jobHandler(job) => Future<bool> (true on success).
class SyncWorker {
  final SyncQueue queue;
  final NetworkInfo networkInfo;
  final Future<bool> Function(Map<String, dynamic> job) jobHandler;
  StreamSubscription? _subQueue;
  StreamSubscription? _subNet;

  SyncWorker({
    required this.queue,
    required this.networkInfo,
    required this.jobHandler,
  });

  Future<void> start() async {
    // react to queue changes and network changes
    _subQueue = queue.onNew.listen((_) => _tryProcess());
    _subNet = networkInfo.onStatusChanged.listen((_) => _tryProcess());
    // initial attempt
    await _tryProcess();
  }

  Future<void> _tryProcess() async {
    if (!await networkInfo.isConnected) {
      L.d('SyncWorker', 'offline — skip processing');
      return;
    }
    while (true) {
      final job = await queue.dequeue();
      if (job == null) break;
      try {
        final ok = await jobHandler(job);
        if (!ok) {
          // failed: re-enqueue at end and break (stop processing to avoid tight loop)
          await queue.enqueue(job);
          break;
        }
      } catch (e, st) {
        L.e('SyncWorker', e, st);
        await queue.enqueue(job);
        break;
      }
    }
  }

  Future<void> stop() async {
    await _subQueue?.cancel();
    await _subNet?.cancel();
    _subQueue = null;
    _subNet = null;
  }
}
