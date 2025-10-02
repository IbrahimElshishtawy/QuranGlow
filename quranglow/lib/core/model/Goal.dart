class Goal {
  final String title;
  final double progress;

  const Goal({required this.title, required this.progress});

  factory Goal.fromMap(Map<String, dynamic> m) => Goal(
    title: m['title'] as String,
    progress: (m['progress'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {'title': title, 'progress': progress};
}
