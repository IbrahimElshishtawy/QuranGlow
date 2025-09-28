// Very small logger helper — replace with logger package if needed
// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/foundation.dart';

class L {
  static void d(String tag, Object? msg) {
    // simple debug print
    // avoid printing in production: guard with kDebugMode if you want
    // import 'package:flutter/foundation.dart';
    if (kDebugMode) {
      print('[$tag] $msg');
    }
  }

  static void e(String tag, Object? error, [StackTrace? st]) {
    if (kDebugMode) {
      print('[ERROR][$tag] $error');
    }
    if (st != null)
      if (kDebugMode) {
        print(st);
      }
  }
}
