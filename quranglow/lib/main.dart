// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:quranglow/Quran_Glow_App.dart';
import 'package:quranglow/core/service/setting/notification_service.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await Hive.initFlutter();
  await NotificationService.instance.init(); // بدون طلب صلاحية هنا
  runApp(const ProviderScope(child: _Bootstrap(child: QuranGlowApp())));
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => FlutterNativeSplash.remove(),
  );
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
