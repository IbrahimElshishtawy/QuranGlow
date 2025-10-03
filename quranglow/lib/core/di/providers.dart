// lib/core/di/providers.dart
// ignore_for_file: unnecessary_import

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

import 'package:quranglow/core/api/fawaz_cdn_source.dart';
import 'package:quranglow/core/api/alquran_cloud_source.dart';
import 'package:quranglow/core/model/App_Settings.dart';
import 'package:quranglow/core/model/goal.dart';
import 'package:quranglow/core/model/surah.dart';
import 'package:quranglow/core/service/goals_service.dart';
import 'package:quranglow/core/service/quran_service.dart';
import 'package:quranglow/core/service/settings_service.dart';
import 'package:quranglow/core/service/tracking_service.dart';
import 'package:quranglow/core/storage/hive_storage_impl.dart';
import 'package:quranglow/core/storage/local_storage.dart';
import 'package:state_notifier/state_notifier.dart';

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json', 'User-Agent': 'QuranGlow/1.0'},
      validateStatus: (s) => s != null && s < 500,
    ),
  );
  return dio;
});

final storageProvider = Provider<LocalStorage>((ref) => HiveStorageImpl());

/// FawazCdnSource(client, dio)
final fawazProvider = Provider<FawazCdnSource>((ref) {
  final client = ref.watch(httpClientProvider);
  final dio = ref.watch(dioProvider);
  return FawazCdnSource(client, dio);
});

final alQuranProvider = Provider<AlQuranCloudSource>(
  (ref) => AlQuranCloudSource(ref.watch(httpClientProvider)),
);

final goalsServiceProvider = Provider<GoalsService>((ref) => GoalsService());

final goalsProvider = FutureProvider<List<Goal>>(
  (ref) async => ref.read(goalsServiceProvider).listGoals(),
);

final quranServiceProvider = Provider<QuranService>((ref) {
  return QuranService(
    fawaz: ref.watch(fawazProvider),
    cloud: ref.watch(alQuranProvider),
    audio: ref.watch(alQuranProvider),
  );
});

final trackingServiceProvider = Provider<TrackingService>(
  (ref) => TrackingService(ref.watch(storageProvider)),
);

final quranAllProvider = FutureProvider.autoDispose.family<List<Surah>, String>(
  (ref, editionId) {
    final service = ref.read(quranServiceProvider);
    return service.getQuranAllText(editionId);
  },
);

final settingsServiceProvider = Provider<SettingsService>(
  (ref) => SettingsService(),
);

final settingsProvider =
    StateNotifierProvider<SettingsController, AsyncValue<AppSettings>>(
      (ref) => SettingsController(ref),
    );

class SettingsController extends StateNotifier<AsyncValue<AppSettings>> {
  SettingsController(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }
  final Ref ref;

  Future<void> _init() async {
    final svc = ref.read(settingsServiceProvider);
    final s = await svc.load();
    state = AsyncValue.data(s);
  }

  Future<void> setDark(bool v) async {
    final cur = state.maybeWhen(data: (s) => s, orElse: () => null);
    if (cur == null) return;
    state = AsyncValue.data(cur.copyWith(darkMode: v));
    await ref.read(settingsServiceProvider).setDark(v);
  }

  Future<void> setFontScale(double v) async {
    final cur = state.maybeWhen(data: (s) => s, orElse: () => null);
    if (cur == null) return;
    state = AsyncValue.data(cur.copyWith(fontScale: v));
    await ref.read(settingsServiceProvider).setFontScale(v);
  }

  Future<void> setReader(String id) async {
    final cur = state.maybeWhen(data: (s) => s, orElse: () => null);
    if (cur == null) return;
    state = AsyncValue.data(cur.copyWith(readerEditionId: id));
    await ref.read(settingsServiceProvider).setReader(id);
  }
}

final audioEditionsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.read(quranServiceProvider).listAudioEditions();
});
