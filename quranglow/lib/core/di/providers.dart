import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:quranglow/core/api/fawaz_cdn_source.dart';
import 'package:quranglow/core/api/alquran_cloud_source.dart';
import 'package:quranglow/core/model/surah.dart';
import 'package:quranglow/core/service/quran_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'QuranGlow/1.0 (+flutter; dio)',
      },
      validateStatus: (s) => s != null && s < 500,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, h) {
        debugPrint('[DIO][REQ] ${o.method} ${o.uri}');
        h.next(o);
      },
      onResponse: (r, h) {
        debugPrint('[DIO][RES] ${r.statusCode} ${r.requestOptions.uri}');
        h.next(r);
      },
      onError: (e, h) {
        debugPrint(
          '[DIO][ERR] ${e.response?.statusCode} ${e.requestOptions.uri}',
        );
        h.next(e);
      },
    ),
  );
  return dio;
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
    cloud: ref.read(alQuranCloudSourceProvider),
  );
});

/// مصحف كامل بنفس الـ edition
final quranAllProvider = FutureProvider.autoDispose.family<List<Surah>, String>(
  (ref, editionId) {
    final service = ref.read(quranServiceProvider);
    return service.getQuranAllText(editionId);
  },
);
