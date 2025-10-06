// lib/core/di/providers.dart
// ignore_for_file: implementation_imports, unnecessary_this

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

import 'package:quranglow/core/api/alquran_cloud_source.dart';
import 'package:quranglow/core/api/fawaz_cdn_source.dart';
import 'package:quranglow/core/model/App_Settings.dart';
// استخدم نموذج Goal الصحيح (النسخة التي تحتوي active/target/current/unit)
import 'package:quranglow/core/model/Goal.dart';
import 'package:quranglow/core/model/bookmark.dart';
import 'package:quranglow/core/model/surah.dart';
import 'package:quranglow/core/service/Settings_Service.dart';
import 'package:quranglow/core/service/download_service.dart';
import 'package:quranglow/core/service/goals_service.dart';
import 'package:quranglow/core/service/quran_service.dart';
import 'package:quranglow/core/service/tracking_service.dart';
import 'package:quranglow/core/storage/hive_storage_impl.dart';
import 'package:quranglow/core/storage/local_storage.dart';
import 'package:quranglow/features/ui/pages/bookmarks/controllers/bookmarks_controller.dart';
import 'package:quranglow/features/ui/pages/bookmarks/logic/bookmarks_usecase.dart';

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
  final svc = GoalsService(storage: ref.watch(storageProvider));
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

// --- Goals (Stream) ----------------------------------------------------------

final goalsStreamProvider = StreamProvider.autoDispose<List<Goal>>((ref) {
  return ref.watch(goalsServiceProvider).watchGoalsWithInitial();
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
  final s =
      ref.read(settingsProvider).whenOrNull(data: (v) => v) ??
      await ref.read(settingsServiceProvider).load();

  final editionId = s.readerEditionId.isNotEmpty
      ? s.readerEditionId
      : 'ar.alafasy';

  final dio = ref.read(dioProvider);
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

// --- Tafsir ------------------------------------------------------------------

final tafsirEditionsProvider = FutureProvider<List<Map<String, String>>>((ref) {
  return ref.read(quranServiceProvider).listTafsirEditions();
});

/// tuple: (surah, ayah, editionId)
final tafsirForAyahProvider = FutureProvider.family<String, (int, int, String)>(
  (ref, t) {
    final (surah, ayah, editionId) = t;
    return ref.read(quranServiceProvider).getAyahTafsir(surah, ayah, editionId);
  },
);
final quranSurahProvider = FutureProvider.autoDispose
    .family<Surah, (int, String)>((ref, t) {
      final (surah, editionId) = t;
      return ref
          .read(quranServiceProvider)
          .getSurahText(surah as String, editionId as int);
    });
final tafsirFutureProvider = FutureProvider.autoDispose
    .family<String?, ({int surah, int ayah, String editionId})>((ref, p) async {
      final svc = ref.read(quranServiceProvider);
      try {
        final t = await svc.getAyahTafsir(p.surah, p.ayah, p.editionId);
        return (t.trim().isEmpty) ? null : t;
      } catch (_) {
        return null;
      }
    });

/// يجلب جميع روابط الصوت لسورة واحدة لقارئ معيّن
final surahAudioUrlsProvider = FutureProvider.autoDispose
    .family<List<String>, ({int surah, String reciterId})>((ref, p) async {
      final svc = ref.read(quranServiceProvider);
      return svc.getSurahAudioUrls(p.reciterId, p.surah);
    });
// --- download service ---------------------------------------------------------

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService(dio: ref.read(dioProvider));
});

// --- bookmarks controller -----------------------------------------------------

final bookmarksProvider =
    StateNotifierProvider<BookmarksController, List<Bookmark>>(
      (ref) => BookmarksController(),
    );

final bookmarksUseCaseProvider = Provider<BookmarksUseCase>(
  (ref) => BookmarksUseCase(ref),
);

final surahNameProvider = FutureProvider.family<String, int>((ref, n) {
  final uc = ref.read(bookmarksUseCaseProvider);
  return uc.getSurahName(n);
});

final surahAyatCountProvider = FutureProvider.family<int, int>((ref, n) {
  final uc = ref.read(bookmarksUseCaseProvider);
  return uc.getAyatCount(n);
});
