// lib/features/ui/pages/azkar/models/reminder.dart
class Reminder {
  Reminder({
    required this.id,
    required this.title,
    required this.dateTime,
    this.daily = false,
    this.notes,
    this.scheduled = false,
  });

  final int id;
  String title;
  DateTime dateTime;
  bool daily;
  String? notes;
  bool scheduled;
}
