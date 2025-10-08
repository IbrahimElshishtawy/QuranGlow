// lib/features/ui/routes/router.dart
// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:test/core/model/aya/aya.dart';
import 'package:test/core/model/book/surah.dart';
import 'package:test/features/ui/pages/ayah/ayah_detail_page.dart';
import 'package:test/features/ui/pages/bookmarks/bookmarks_page.dart';
import 'package:test/features/ui/pages/downloads/download_detail_page.dart'
    as ddp;
import 'package:test/features/ui/pages/downloads/downloads_page.dart' as dlp;
import 'package:test/features/ui/pages/goals/goals_page.dart';
import 'package:test/features/ui/pages/home/home_page.dart';
import 'package:test/features/ui/pages/mushaf/mushaf_page.dart';
import 'package:test/features/ui/pages/mushaf/paged_mushaf.dart';
import 'package:test/features/ui/pages/onboarding/onboarding_page.dart';
import 'package:test/features/ui/pages/player/player_page.dart';
import 'package:test/features/ui/pages/search/search_page.dart';
import 'package:test/features/ui/pages/setting/settings_page.dart';
import 'package:test/features/ui/pages/spa/splash_screen.dart';
import 'package:test/features/ui/pages/stats/stats_page.dart';
import 'package:test/features/ui/pages/surah/surah_list_page.dart';
import 'package:test/features/ui/pages/tafsir/tafsir_explorer_page.dart';

import 'app_routes.dart';

class MushafArgs {
  const MushafArgs({
    this.initialAyah,
    this.chapter = 1,
    this.editionId = 'quran-uthmani',
  });
  final int chapter;
  final int? initialAyah; // 1-based
  final String editionId;
}

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
  final int? initialSelectedAyah; // 1-based
}

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
      MushafPage(
        chapter: args.chapter,
        editionId: args.editionId,
        initialAyah: args.initialAyah,
      ),
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
    // DownloadsPage تتطلب surah و reciterId
    final a = s.arguments;
    if (a is Map<String, dynamic> &&
        a['surah'] is int &&
        a['reciterId'] is String) {
      return _mat(dlp.DownloadsPage(), s);
    }
    return _mat(
      const Scaffold(
        body: Center(
          child: Text('downloads يحتاج {surah:int, reciterId:String}'),
        ),
      ),
      s,
    );
  } else if (name == AppRoutes.downloadDetail) {
    final a = s.arguments;
    if (a is Map<String, dynamic> &&
        a['surah'] is int &&
        a['reciterId'] is String) {
      return _mat(
        ddp.DownloadDetailPage(
          surah: a['surah'] as int,
          reciterId: a['reciterId'] as String,
        ),
        s,
      );
    }
    return _mat(
      const Scaffold(
        body: Center(
          child: Text('downloadDetail يحتاج {surah:int, reciterId:String}'),
        ),
      ),
      s,
    );
  } else if (name == AppRoutes.setting) {
    return _mat(const SettingsPage(), s);
  } else if (name == AppRoutes.goals) {
    return _mat(const GoalsPage(), s);
  } else if (name == AppRoutes.stats) {
    return _mat(const StatsPage(), s);
  } else if (name == AppRoutes.onboarding) {
    return _mat(const OnboardingPage(), s);
  } else if (name == AppRoutes.tafsir || name == AppRoutes.tafsirReader) {
    return _mat(const TafsirReaderPage(), s);
  }

  return _mat(const Scaffold(body: Center(child: Text('Route not found'))), s);
}

MaterialPageRoute _mat(Widget w, [RouteSettings? s]) =>
    MaterialPageRoute(builder: (_) => w, settings: s);
