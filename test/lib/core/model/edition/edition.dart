class Edition {
  final String identifier; // e.g. "quran-uthmani" or "en.sahih"
  final String language; // 'ar','en'
  final String type; // 'translation','versebyverse'
  final String format; // 'text'|'audio'
  final String name;

  Edition({
    required this.identifier,
    required this.language,
    required this.type,
    required this.format,
    required this.name,
  });

  factory Edition.fromMap(Map<String, dynamic> m) {
    return Edition(
      identifier: (m['identifier'] ?? m['id'] ?? m['edition'] ?? '') as String,
      language: (m['language'] ?? '') as String,
      type: (m['type'] ?? '') as String,
      format: (m['format'] ?? '') as String,
      name: (m['englishName'] ?? m['name'] ?? '') as String,
    );
  }
}
