class SearchHit {
  final int surah;
  final int ayah;
  final String surahName;
  final String text;

  const SearchHit({
    required this.surah,
    required this.ayah,
    required this.surahName,
    required this.text,
  });

  factory SearchHit.fromMap(Map<String, dynamic> m) => SearchHit(
    surah: (m['surahNumber'] as num).toInt(),
    ayah: (m['ayahNumber'] as num).toInt(),
    surahName: (m['surahName'] ?? '').toString(),
    text: (m['text'] ?? '').toString(),
  );
}
