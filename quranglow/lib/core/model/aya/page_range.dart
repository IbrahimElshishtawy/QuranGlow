import 'package:flutter/foundation.dart';

@immutable
class PageRange {
  final int start;
  final int end;
  const PageRange({required this.start, required this.end});

  bool contains(int idx) => idx >= start && idx < end;
}
