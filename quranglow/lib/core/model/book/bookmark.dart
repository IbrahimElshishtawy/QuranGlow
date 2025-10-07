import 'package:flutter/foundation.dart';

@immutable
class Bookmark {
  final int surah;
  final int ayah;
  final String? note;
  final DateTime createdAt;

  const Bookmark({
    required this.surah,
    required this.ayah,
    this.note,
    required this.createdAt,
  });
}
