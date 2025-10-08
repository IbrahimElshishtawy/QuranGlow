// ignore_for_file: unrelated_type_equality_checks

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity _connectivity = Connectivity();
  Future<bool> get isConnected async {
    final res = await _connectivity.checkConnectivity();
    return res != ConnectivityResult.none;
  }

  Stream<List<ConnectivityResult>> get onStatusChanged =>
      _connectivity.onConnectivityChanged;
}
