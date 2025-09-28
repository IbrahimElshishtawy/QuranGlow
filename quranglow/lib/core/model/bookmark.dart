class Bookmark {
  final String id; // uuid or composite "surah:aya"
  final int surah;
  final int aya;
  final String note;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.surah,
    required this.aya,
    this.note = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'surah': surah,
    'aya': aya,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Bookmark.fromMap(Map<String, dynamic> m) => Bookmark(
    id: m['id'] as String,
    surah: m['surah'] as int,
    aya: m['aya'] as int,
    note: m['note'] as String? ?? '',
    createdAt: DateTime.parse(m['createdAt'] as String),
  );
}
