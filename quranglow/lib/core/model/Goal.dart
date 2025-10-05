import 'package:hive/hive.dart';

enum GoalType { reading, listening, memorization, tafsir, wird }

class Goal {
  final String id;
  final GoalType type;
  final String title;
  final int target;
  final int current;
  final String unit;
  final bool active;

  const Goal({
    required this.id,
    required this.type,
    required this.title,
    required this.target,
    this.current = 0,
    this.unit = 'آية',
    this.active = true,
  });

  double get progress => target == 0 ? 0 : (current / target).clamp(0, 1);

  Goal copyWith({
    String? id,
    GoalType? type,
    String? title,
    int? target,
    int? current,
    String? unit,
    bool? active,
  }) {
    return Goal(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      target: target ?? this.target,
      current: current ?? this.current,
      unit: unit ?? this.unit,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'title': title,
    'target': target,
    'current': current,
    'unit': unit,
    'active': active,
  };

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
    id: (map['id'] ?? '') as String,
    type: GoalType.values.firstWhere(
      (e) => e.name == (map['type'] ?? 'reading'),
      orElse: () => GoalType.reading,
    ),
    title: (map['title'] ?? '') as String,
    target: (map['target'] ?? 0) as int,
    current: (map['current'] ?? 0) as int,
    unit: (map['unit'] ?? 'آية') as String,
    active: (map['active'] ?? true) as bool,
  );
}

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 1;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      id: fields[0] as String,
      type: GoalType.values[fields[1] as int],
      title: fields[2] as String,
      target: fields[3] as int,
      current: fields[4] as int,
      unit: fields[5] as String,
      active: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type.index)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.target)
      ..writeByte(4)
      ..write(obj.current)
      ..writeByte(5)
      ..write(obj.unit)
      ..writeByte(6)
      ..write(obj.active);
  }
}
