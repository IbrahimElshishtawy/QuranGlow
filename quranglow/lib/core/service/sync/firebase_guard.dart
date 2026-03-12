import 'package:firebase_core/firebase_core.dart';
import 'package:quranglow/firebase_options.dart';

class FirebaseGuard {
  static bool get isReady =>
      DefaultFirebaseOptions.isConfigured && Firebase.apps.isNotEmpty;
}
