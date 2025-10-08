import 'dart:async';
import 'package:quranglow/core/network/network_info.dart';
import 'sync_queue.dart';
import '../utils/logger.dart';

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
    _subQueue = queue.onNew.listen((_) => _tryProcess());
    _subNet = networkInfo.onStatusChanged.listen((_) => _tryProcess());
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
