class Topic {
  final int surah;
  final int startAyah;
  final int endAyah;
  final String title;

  const Topic({
    required this.surah,
    required this.startAyah,
    required this.endAyah,
    required this.title,
  });

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      surah: map['surah'] as int,
      startAyah: map['startAyah'] as int,
      endAyah: map['endAyah'] as int,
      title: map['title'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'surah': surah,
      'startAyah': startAyah,
      'endAyah': endAyah,
      'title': title,
    };
  }
}

// Mock topics data
final List<Topic> mockTopics = [
  const Topic(surah: 1, startAyah: 1, endAyah: 7, title: 'الفاتحة'),
  const Topic(surah: 2, startAyah: 1, endAyah: 5, title: 'صفات المؤمنين'),
  const Topic(surah: 2, startAyah: 6, endAyah: 7, title: 'صفات الكافرين'),
  const Topic(surah: 2, startAyah: 8, endAyah: 20, title: 'صفات المنافقين'),
];
