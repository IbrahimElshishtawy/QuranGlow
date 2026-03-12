// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quranglow/Quran_Glow_App.dart';
import 'package:quranglow/core/service/audio/audio_locator.dart';
import 'package:quranglow/core/service/sync/firebase_sync_service.dart';
import 'package:quranglow/core/service/setting/notification_service.dart';
import 'package:quranglow/firebase_options.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  final firebaseReady = await _safeInit(
    'firebase',
    () =>
        Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    timeout: const Duration(seconds: 8),
  );

  if (firebaseReady) {
    if (!kDebugMode) {
      unawaited(
        _safeInit(
          'firebase-anon-signin',
          () => FirebaseSyncService().signInAnonymously(),
          timeout: const Duration(seconds: 5),
        ),
      );
    } else {
      debugPrint('[BOOT] firebase-anon-signin skipped on debug build');
    }

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await _safeInit(
    'hive',
    () => Hive.initFlutter(),
    timeout: const Duration(seconds: 5),
  );
  final shouldInitAudioService =
      !(defaultTargetPlatform == TargetPlatform.android && kDebugMode);
  if (shouldInitAudioService) {
    await _safeInit(
      'audio-handler',
      () => initAudioHandler(),
      timeout: const Duration(seconds: 10),
    );
  } else {
    debugPrint('[BOOT] audio-handler skipped on Android debug build');
  }
  await _safeInit(
    'notifications',
    () => NotificationService.instance.init(),
    timeout: const Duration(seconds: 5),
  );

  runApp(const ProviderScope(child: _Bootstrap(child: QuranGlowApp())));
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}

Future<bool> _safeInit(
  String name,
  Future<void> Function() task, {
  required Duration timeout,
}) async {
  try {
    await task().timeout(timeout);
    return true;
  } catch (e, st) {
    debugPrint('[BOOT] $name failed/skipped: $e');
    debugPrintStack(stackTrace: st);
    return false;
  }
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap({required this.child});
  final Widget child;
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> with WidgetsBindingObserver {
  bool _asked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryAsk());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tryAsk();
  }

  Future<void> _tryAsk() async {
    if (!mounted || _asked) return;
    _asked = true;
    await NotificationService.instance.requestPermissionsIfNeededFromUI(
      context,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
