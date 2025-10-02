// lib/core/di/providers.dart  (Dio مضبوط وتوصيل الخدمات)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:quranglow/core/api/fawaz_cdn_source.dart';
import 'package:quranglow/core/api/alquran_cloud_source.dart';
import 'package:quranglow/core/service/quran_service.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'QuranGlow/1.0 (+flutter; dio)',
      },
      validateStatus: (s) => s != null && s < 500, // لا يرمى على 4xx
    ),
  );
});

final fawazSourceProvider = Provider<FawazCdnSource>((ref) {
  return FawazCdnSource(dio: ref.read(dioProvider));
});

final alQuranCloudSourceProvider = Provider<AlQuranCloudSource>((ref) {
  return AlQuranCloudSource(dio: ref.read(dioProvider));
});

final quranServiceProvider = Provider<QuranService>((ref) {
  return QuranService(
    fawaz: ref.read(fawazSourceProvider),
    audio: ref.read(alQuranCloudSourceProvider),
  );
});
