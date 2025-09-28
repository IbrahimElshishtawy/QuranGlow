import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:quranglow/core/api/alquran_cloud_source.dart';
import 'package:quranglow/core/api/fawaz_cdn_source.dart';
import 'package:quranglow/core/service/audio_service.dart';
import 'package:quranglow/core/service/download_service.dart';
import 'package:quranglow/core/service/quran_service.dart';

final httpClientProvider = Provider<http.Client>((ref) => http.Client());
final fawazProvider = Provider(
  (ref) => FawazCdnSource(ref.watch(httpClientProvider)),
);
final alQuranProvider = Provider(
  (ref) => AlQuranCloudSource(ref.watch(httpClientProvider)),
);
final quranServiceProvider = Provider(
  (ref) => QuranService(
    fawaz: ref.watch(fawazProvider),
    audio: ref.watch(alQuranProvider),
  ),
);
final audioServiceProvider = Provider((ref) => AudioService());
final downloadServiceProvider = Provider((ref) => DownloadService());
