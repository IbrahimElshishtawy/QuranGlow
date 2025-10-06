class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const mushaf = '/mushaf';
  static const mushafPaged = '/mushaf-paged';
  static const surahs = '/surahs';
  static const ayah = '/ayah';
  static const player = '/player';
  static const search = '/search';
  static const tafsirReader = '/tafsir';
  static const bookmarks = '/bookmarks';
  static const downloads = '/downloads';
  static const downloadDetail = '/downloads/detail';
  static const setting = '/setting';
  static const goals = '/goals';
  static const stats = '/stats';
  static const onboarding = '/onboarding';
  static const tafsir = '/tafsir';
}

class TafsirArgs {
  final int surah;
  final int ayah;
  final String? editionId;
  final String? editionName;

  const TafsirArgs({
    required this.surah,
    required this.ayah,
    this.editionId,
    this.editionName,
  });
}
