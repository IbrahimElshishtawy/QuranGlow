import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../api/alquran_cloud_source.dart';
import '../api/fawaz_cdn_source.dart';
import '../service/quran_service.dart';
import '../service/audio_service.dart';
import '../service/download_service.dart';

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final fawazProvider = Provider<FawazCdnSource>(
  (ref) => FawazCdnSource(ref.watch(httpClientProvider)),
);

final alQuranProvider = Provider<AlQuranCloudSource>(
  (ref) => AlQuranCloudSource(ref.watch(httpClientProvider)),
);

final quranServiceProvider = Provider<QuranService>(
  (ref) => QuranService(
    fawaz: ref.watch(fawazProvider),
    audio: ref.watch(alQuranProvider),
  ),
);

final audioServiceProvider = Provider<AudioService>((ref) => AudioService());
final downloadServiceProvider = Provider<DownloadService>(
  (ref) => DownloadService(),
);
