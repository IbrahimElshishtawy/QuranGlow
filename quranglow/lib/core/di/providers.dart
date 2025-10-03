// lib/core/di/providers.dart
// ignore_for_file: implementation_imports

import 'package:dio/src/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:http/http.dart' as http;

import 'package:quranglow/core/api/fawaz_cdn_source.dart';
import 'package:quranglow/core/api/alquran_cloud_source.dart';
import 'package:quranglow/core/model/App_Settings.dart';
import 'package:quranglow/core/model/goal.dart';
import 'package:quranglow/core/model/surah.dart';
import 'package:quranglow/core/service/Goals_Service.dart';
import 'package:quranglow/core/service/quran_service.dart';
import 'package:quranglow/core/service/settings_service.dart';
import 'package:quranglow/core/service/tracking_service.dart';
import 'package:quranglow/core/storage/hive_storage_impl.dart';
import 'package:quranglow/core/storage/local_storage.dart';
import 'package:riverpod/riverpod.dart';

/// HTTP client (موحّد)
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

/// Local storage (تأكد من init() في main قبل runApp)
final storageProvider = Provider<LocalStorage>((ref) {
  final s = HiveStorageImpl();
  return s;
});

/// Data sources
final fawazProvider = Provider(
  (ref) => FawazCdnSource(
    ref.watch(httpClientProvider),
    ref.watch(storageProvider as ProviderListenable<Dio?>),
  ),
);

final goalsServiceProvider = Provider<GoalsService>((ref) => GoalsService());

final goalsProvider = FutureProvider<List<Goal>>((ref) async {
  final service = ref.read(goalsServiceProvider);
  return service.listGoals();
});
final alQuranProvider = Provider(
  (ref) => AlQuranCloudSource(ref.watch(httpClientProvider)),
);

/// Services
final quranServiceProvider = Provider(
  (ref) => QuranService(
    fawaz: ref.watch(fawazProvider),
    audio: ref.watch(alQuranProvider),
    cloud: ref.watch(alQuranProvider),
  ),
);

final trackingServiceProvider = Provider(
  (ref) => TrackingService(ref.watch(storageProvider)),
);

/// مصحف كامل لنفس الـ edition
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
      (ref) => SettingsController(ref.read as Ref),
    );

class SettingsController extends StateNotifier<AsyncValue<AppSettings>> {
  SettingsController(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }
  final Ref _ref;

  Future<void> _init() async {
    final svc = _ref.read(settingsServiceProvider);
    final s = await svc.load();
    state = AsyncValue.data(s);
  }

  Future<void> setDark(bool v) async {
    final svc = _ref.read(settingsServiceProvider);
    final cur = state.maybeWhen(data: (s) => s, orElse: () => null);
    if (cur == null) return;
    state = AsyncValue.data(cur.copyWith(darkMode: v));
    await svc.setDark(v);
  }

  Future<void> setFontScale(double v) async {
    final svc = _ref.read(settingsServiceProvider);
    final cur = state.maybeWhen(data: (s) => s, orElse: () => null);
    if (cur == null) return;
    state = AsyncValue.data(cur.copyWith(fontScale: v));
    await svc.setFontScale(v);
  }

  Future<void> setReader(String id) async {
    final svc = _ref.read(settingsServiceProvider);
    final cur = state.maybeWhen(data: (s) => s, orElse: () => null);
    if (cur == null) return;
    state = AsyncValue.data(cur.copyWith(readerEditionId: id));
    await svc.setReader(id);
  }
}

final audioEditionsProvider = FutureProvider<List<dynamic>>((ref) async {
  final svc = ref.read(quranServiceProvider);
  final list = await svc.listAudioEditions();
  return list;
});
