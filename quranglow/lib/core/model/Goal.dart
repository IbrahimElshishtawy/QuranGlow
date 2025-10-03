// ignore_for_file: file_names

import 'package:hive/hive.dart';

class Goal {
  String title;
  double progress;
  Goal({required this.title, required this.progress});
}

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 5;

  @override
  Goal read(BinaryReader reader) {
    final fieldsCount = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < fieldsCount; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Goal(
      title: fields[0] as String,
      progress: (fields[1] as num).toDouble(),
    );
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
