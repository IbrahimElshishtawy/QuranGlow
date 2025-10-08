// lib/core/model/goal.dart
import 'dart:convert';

enum GoalType { reading, listening, memorization, tafsir }

class Goal {
  final String id;
  final String title;
  final GoalType type;
  final int target;
  final int current;
  final bool active;
  final DateTime? createdAt;

  const Goal({
    required this.id,
    required this.title,
    required this.type,
    required this.target,
    this.current = 0,
    this.active = true,
    this.createdAt,
    required String unit,
  });

  double get progress => target == 0 ? 0 : (current / target).clamp(0, 1);
  bool get completed => current >= target;

  Goal copyWith({
    String? id,
    String? title,
    GoalType? type,
    int? target,
    int? current,
    bool? active,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      target: target ?? this.target,
      current: current ?? this.current,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      unit: '',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'type': type.name,
    'target': target,
    'current': current,
    'active': active,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
    id: (map['id'] ?? '').toString(),
    title: (map['title'] ?? '').toString(),
    type: _typeFrom(map['type']),
    target: (map['target'] as num? ?? 0).toInt(),
    current: (map['current'] as num? ?? 0).toInt(),
    active: map['active'] is bool ? map['active'] as bool : true,
    createdAt:
        (map['createdAt'] is String && (map['createdAt'] as String).isNotEmpty)
        ? DateTime.tryParse(map['createdAt'] as String)
        : null,
    unit: '',
  );

  static GoalType _typeFrom(dynamic v) {
    final s = (v ?? '').toString();
    return GoalType.values.firstWhere(
      (e) => e.name == s,
      orElse: () => GoalType.reading,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory Goal.fromJson(String s) =>
      Goal.fromMap(jsonDecode(s) as Map<String, dynamic>);
}
