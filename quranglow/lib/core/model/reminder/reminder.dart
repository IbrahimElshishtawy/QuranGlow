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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'daily': daily,
      'notes': notes,
      'scheduled': scheduled,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int,
      title: map['title'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      daily: map['daily'] as bool,
      notes: map['notes'] as String?,
      scheduled: map['scheduled'] as bool,
    );
  }
}
