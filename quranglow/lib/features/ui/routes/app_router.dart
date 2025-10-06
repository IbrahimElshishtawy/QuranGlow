// lib/features/ui/routes/router.dart
// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

import 'package:quranglow/core/model/aya.dart';
import 'package:quranglow/core/model/surah.dart';

import 'package:quranglow/features/ui/pages/ayah/ayah_detail_page.dart';
import 'package:quranglow/features/ui/pages/bookmarks/bookmarks_page.dart';
import 'package:quranglow/features/ui/pages/downloads/download_detail_page.dart';
import 'package:quranglow/features/ui/pages/downloads/downloads_page.dart';
import 'package:quranglow/features/ui/pages/goals/goals_page.dart';
import 'package:quranglow/features/ui/pages/home/home_page.dart';
import 'package:quranglow/features/ui/pages/mushaf/mushaf_page.dart'; // يجلب من الـ API
import 'package:quranglow/features/ui/pages/mushaf/paged_mushaf.dart'; // عرض صفحي مباشر
import 'package:quranglow/features/ui/pages/onboarding/onboarding_page.dart';
import 'package:quranglow/features/ui/pages/player/player_page.dart';
import 'package:quranglow/features/ui/pages/search/search_page.dart';
import 'package:quranglow/features/ui/pages/setting/settings_page.dart';
import 'package:quranglow/features/ui/pages/spa/splash_screen.dart';
import 'package:quranglow/features/ui/pages/stats/stats_page.dart';
import 'package:quranglow/features/ui/pages/surah/surah_list_page.dart';
import 'package:quranglow/features/ui/pages/tafsir/tafsir_explorer_page.dart';

import 'app_routes.dart';

// وسائط مسار mushaf (API)
class MushafArgs {
  const MushafArgs({this.chapter = 1, this.editionId = 'quran-uthmani'});
  final int chapter;
  final String editionId;
}

// وسائط مسار mushafPaged (عرض صفحي مباشر)
class PagedMushafArgs {
  const PagedMushafArgs({
    required this.ayat,
    required this.surahName,
    required this.surahNumber,
    this.initialSelectedAyah,
  });
  final List<Aya> ayat;
  final String surahName;
  final int surahNumber;
  final int? initialSelectedAyah;
}

// وسائط مسار ayah (تفاصيل آية)
class AyahArgs {
  const AyahArgs({required this.aya, required this.surah, this.tafsir});
  final Aya aya;
  final Surah surah;
  final String? tafsir;
}

Route<dynamic>? onGenerateRoute(RouteSettings s) {
  final name = s.name;

  if (name == AppRoutes.splash) {
    return _mat(const SplashScreen(), s);
  } else if (name == AppRoutes.home) {
    return _mat(const HomePage(), s);
  } else if (name == AppRoutes.mushaf) {
    final a = s.arguments;
    final args = a is MushafArgs ? a : const MushafArgs();
    return _mat(
      MushafPage(chapter: args.chapter, editionId: args.editionId),
      s,
    );
  } else if (name == AppRoutes.mushafPaged) {
    final a = s.arguments;
    if (a is PagedMushafArgs) {
      return MaterialPageRoute(
        settings: s,
        builder: (context) {
          return PagedMushaf(
            ayat: a.ayat,
            surahName: a.surahName,
            surahNumber: a.surahNumber,
            initialSelectedAyah: a.initialSelectedAyah,
            // التوقيع الصحيح: (int ayahNumber, Aya aya)
            onAyahTap: (int ayahNumber, Aya aya) {
              final fakeSurah = Surah(
                number: a.surahNumber,
                name: a.surahName,
                ayat: a.ayat,
              );
              Navigator.pushNamed(
                context,
                AppRoutes.ayah,
                arguments: AyahArgs(aya: aya, surah: fakeSurah, tafsir: null),
              );
            },
          );
        },
      );
    }
    return _mat(
      const Scaffold(
        body: Center(
          child: Text('mushafPaged يحتاج ayat + surahName + surahNumber'),
        ),
      ),
      s,
    );
  } else if (name == AppRoutes.surahs) {
    return _mat(const SurahListPage(), s);
  } else if (name == AppRoutes.ayah) {
    final a = s.arguments;
    if (a is AyahArgs) {
      return _mat(
        AyahDetailPage(aya: a.aya, surah: a.surah, tafsir: a.tafsir),
        s,
      );
    }
    return _mat(
      const Scaffold(body: Center(child: Text('ayah route يحتاج Aya + Surah'))),
      s,
    );
  } else if (name == AppRoutes.player) {
    return _mat(const PlayerPage(), s);
  } else if (name == AppRoutes.search) {
    return _mat(const SearchPage(), s);
  } else if (name == AppRoutes.bookmarks) {
    return _mat(const BookmarksPage(), s);
  } else if (name == AppRoutes.downloads) {
    return _mat(const DownloadsPage(), s);
  } else if (name == AppRoutes.downloadDetail) {
    return _mat(const DownloadDetailPage(), s);
  } else if (name == AppRoutes.setting) {
    return _mat(const SettingsPage(), s);
  } else if (name == AppRoutes.goals) {
    return _mat(const GoalsPage(), s);
  } else if (name == AppRoutes.stats) {
    return _mat(const StatsPage(), s);
  } else if (name == AppRoutes.onboarding) {
    return _mat(const OnboardingPage(), s);
  } else if (name == AppRoutes.tafsir) {
    return _mat(const TafsirReaderPage(), s);
  }

  return _mat(const Scaffold(body: Center(child: Text('Route not found'))), s);
}

MaterialPageRoute _mat(Widget w, [RouteSettings? s]) =>
    MaterialPageRoute(builder: (_) => w, settings: s);
