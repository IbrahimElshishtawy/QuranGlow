import 'package:state_notifier/state_notifier.dart';
import 'package:test/core/model/book/bookmark.dart';

class BookmarksController extends StateNotifier<List<Bookmark>> {
  BookmarksController() : super(const []);

  void add(Bookmark b) => state = [...state, b];
  void removeAt(int i) => state = [...state]..removeAt(i);
  void clearAll() => state = const [];
}
