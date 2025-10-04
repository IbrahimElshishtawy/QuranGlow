// lib/core/di/providers.dart
// ignore_for_file: implementation_imports

import 'dart:async';

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
import 'package:riverpod/src/framework.dart';

// --- HTTP & Dio --------------------------------------------------------------

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json', 'User-Agent': 'QuranGlow/1.0'},
      validateStatus: (s) => s != null && s < 500,
    ),
  );
});

// --- Storage -----------------------------------------------------------------

final storageProvider = Provider<LocalStorage>((ref) => HiveStorageImpl());

// --- API Sources -------------------------------------------------------------

final fawazProvider = Provider<FawazCdnSource>((ref) {
  final client = ref.watch(httpClientProvider);
  final dio = ref.watch(dioProvider);
  return FawazCdnSource(client, dio);
});

final alQuranProvider = Provider<AlQuranCloudSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AlQuranCloudSource(dio: dio);
});

// --- Services ----------------------------------------------------------------

final goalsServiceProvider = Provider<GoalsService>((ref) {
  final svc = GoalsService(
    storage: ref.watch(storageProvider),
  ); // لو عندك constructor مختلف عدّله هنا
  ref.onDispose(svc.dispose);
  return svc;
});

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

final settingsServiceProvider = Provider<SettingsService>(
  (ref) => SettingsService(),
);

// --- Goals (Future + Stream) -------------------------------------------------

final goalsProvider = FutureProvider.autoDispose<List<Goal>>((ref) async {
  final service = ref.read(goalsServiceProvider);
  return service.listGoals();
});

final goalsStreamProvider = StreamProvider.autoDispose<List<Goal>>((ref) {
  final service = ref.watch(goalsServiceProvider);
  // إن كان عندك watchGoalsWithInitial في الخدمة فإرجعه مباشرة
  return service.watchGoalsWithInitial();
});

// --- Quran Text --------------------------------------------------------------

final quranAllProvider = FutureProvider.autoDispose.family<List<Surah>, String>(
  (ref, editionId) {
    final service = ref.read(quranServiceProvider);
    return service.getQuranAllText(editionId);
  },
);

// --- Settings (StateNotifier) ------------------------------------------------

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

// --- Audio Editions ----------------------------------------------------------

final audioEditionsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.read(quranServiceProvider).listAudioEditions();
});
// --- Daily Ayah --------------------------------------------------------------

final dailyAyahProvider = FutureProvider.autoDispose<Map<String, String>>((
  ref,
) async {
  // نقرأ الإعدادات للحصول على نسخة القارئ الحالية
  final settings = await ref.watch(settingsProvider.future);
  final editionId = settings.readerEditionId.isNotEmpty
      ? settings.readerEditionId
      : 'ar.alafasy';

  final dio = ref.read(dioProvider);
  // endpoint من AlQuran Cloud: آية عشوائية حسب النسخة
  final res = await dio.get(
    'https://api.alquran.cloud/v1/ayah/random/$editionId',
  );

  if (res.statusCode != 200 || res.data == null) {
    throw Exception('تعذر جلب آية اليوم');
  }

  final data = res.data['data'] ?? {};
  final text = (data['text'] ?? data['ayahText'] ?? '').toString();

  final surah = data['surah'] ?? {};
  final surahName = (surah['name'] ?? surah['englishName'] ?? 'سورة غير معروفة')
      .toString();
  final nInSurah = data['numberInSurah']?.toString() ?? '';

  return {'text': text, 'ref': '$surahName • $nInSurah'};
});

extension on Object? {
  get readerEditionId => this.hashCode;
}

extension
    on StateNotifierProvider<SettingsController, AsyncValue<AppSettings>> {
  ProviderListenable<FutureOr<Object?>> get future =>
      this.select((s) => s.whenOrNull(data: (v) => v));
}
