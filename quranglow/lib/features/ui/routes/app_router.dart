import 'package:flutter/material.dart';
import 'package:quranglow/features/ui/pages/ayah/ayah_detail_page';
import 'package:quranglow/features/ui/pages/bookmarks/bookmarks_page.dart';
import 'package:quranglow/features/ui/pages/downloads/download_detail_page.dart';
import 'package:quranglow/features/ui/pages/downloads/downloads_page.dart';
import 'package:quranglow/features/ui/pages/goals/goals_page.dart';
import 'package:quranglow/features/ui/pages/home/home_page.dart';
import 'package:quranglow/features/ui/pages/mushaf/mushaf_page.dart';
import 'package:quranglow/features/ui/pages/onboarding/onboarding_page.dart';
import 'package:quranglow/features/ui/pages/player/player_page.dart';
import 'package:quranglow/features/ui/pages/search/search_page.dart';
import 'package:quranglow/features/ui/pages/setting/settings_page.dart';
import 'package:quranglow/features/ui/pages/spa/splash_screen.dart';
import 'package:quranglow/features/ui/pages/stats/stats_page.dart';
import 'package:quranglow/features/ui/pages/surah/surah_list_page.dart';
import 'package:quranglow/features/ui/pages/tafsir/tafsir_explorer_page.dart';

import 'app_routes.dart';

Route<dynamic>? onGenerateRoute(RouteSettings s) {
  switch (s.name) {
    case AppRoutes.splash:
      return _mat(const SplashScreen());
    case AppRoutes.home:
      return _mat(const HomePage());
    case AppRoutes.mushaf:
      return _mat(const MushafPage());
    case AppRoutes.surahs:
      return _mat(const SurahListPage());
    case AppRoutes.ayah:
      return _mat(const AyahDetailPage());
    case AppRoutes.player:
      return _mat(const PlayerPage());
    case AppRoutes.search:
      return _mat(const SearchPage());
    case AppRoutes.bookmarks:
      return _mat(const BookmarksPage());
    case AppRoutes.downloads:
      return _mat(const DownloadsPage());
    case AppRoutes.downloadDetail:
      return _mat(const DownloadDetailPage());
    case AppRoutes.settings:
      return _mat(const SettingsPage());
    case AppRoutes.goals:
      return _mat(const GoalsPage());
    case AppRoutes.stats:
      return _mat(const StatsPage());
    case AppRoutes.onboarding:
      return _mat(const OnboardingPage());
    case AppRoutes.tafsir:
      return _mat(const TafsirExplorerPage());
  }
  return _mat(const Scaffold(body: Center(child: Text('Route not found'))));
}

MaterialPageRoute _mat(Widget w) => MaterialPageRoute(builder: (_) => w);
