class SearchService {
  // Simple in-memory search as placeholder
  List<Map<String, dynamic>> index = [];

  void indexSurah(int surahNumber, List<Map<String, dynamic>> verses) {
    for (var v in verses) {
      index.add({'surah': surahNumber, 'aya': v['number'], 'text': v['text']});
    }
  }

  List<Map<String, dynamic>> search(String q) {
    final ql = q.toLowerCase();
    return index
        .where((m) => (m['text'] as String).toLowerCase().contains(ql))
        .toList();
  }
}
