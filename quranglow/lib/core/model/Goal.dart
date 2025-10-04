// lib/core/model/goal.dart
import 'package:hive/hive.dart';

class Goal {
  final String title;
  final double progress;

  const Goal({required this.title, required this.progress});

  Goal copyWith({String? title, double? progress}) =>
      Goal(title: title ?? this.title, progress: progress ?? this.progress);

  Map<String, dynamic> toMap() => {'title': title, 'progress': progress};

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
    title: (map['title'] ?? '') as String,
    progress: (map['progress'] ?? 0).toDouble(),
  );
}

/// Hive TypeAdapter يدوي (بدون توليد)
class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 1; // تأكد أنه فريد داخل مشروعك

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(title: fields[0] as String, progress: (fields[1] as double));
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.progress);
  }
}
