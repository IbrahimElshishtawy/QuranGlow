// ignore_for_file: depend_on_referenced_packages, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:quranglow/Quran_Glow_App.dart';
import 'package:quranglow/core/service/quran/quran_service.dart';
import 'package:quranglow/core/service/setting/notification_service.dart';
import 'package:quranglow/core/api/alquran_cloud_source.dart';
import 'package:quranglow/core/api/fawaz_cdn_source.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await Hive.initFlutter();
  await NotificationService.instance.init();
  try {
    final dio = Dio();
    final cloud = AlQuranCloudSource(dio: dio);
    final fawaz = FawazCdnSource(http.Client(), dio);
    final service = QuranService(fawaz: fawaz, cloud: cloud, audio: cloud);

    await service.getQuranAllText('quran-uthmani');
  } catch (e) {
    debugPrint('⚠️ فشل تحميل بعض السور: $e');
  }
  runApp(const ProviderScope(child: QuranGlowApp()));
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}
