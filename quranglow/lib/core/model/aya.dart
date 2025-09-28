// ignore_for_file: unnecessary_null_in_if_null_operators

class Aya {
  final int globalId;
  final int surah;
  final int number;
  final String text;
  final String? translation;
  final String? audioUrl;

  Aya({
    required this.globalId,
    required this.surah,
    required this.number,
    required this.text,
    this.translation,
    this.audioUrl,
  });

  factory Aya.fromMap(Map<String, dynamic> m) {
    return Aya(
      globalId: (m['global'] ?? m['globalId'] ?? 0) as int,
      surah: (m['surah'] ?? m['chapter'] ?? 0) as int,
      number: (m['number'] ?? m['verse'] ?? m['verse_number'] ?? 0) as int,
      text: (m['text'] ?? m['arabic'] ?? '') as String,
      translation:
          (m['translation'] ?? m['translation_text'] ?? null) as String?,
      audioUrl: (m['audio'] ?? m['audioUrl'] ?? null) as String?,
    );
  }
}
