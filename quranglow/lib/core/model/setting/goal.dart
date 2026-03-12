import 'dart:convert';

import 'package:flutter/material.dart';

enum GoalType { reading, listening, memorization, tafsir }

class Goal {
  final String id;
  final String title;
  final GoalType type;
  final int target;
  final int current;
  final bool active;
  final DateTime? createdAt;
  final String unit;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;

  const Goal({
    required this.id,
    required this.title,
    required this.type,
    required this.target,
    this.current = 0,
    this.active = true,
    this.createdAt,
    required this.unit,
    this.reminderEnabled = false,
    this.reminderHour = 9,
    this.reminderMinute = 0,
  });

  double get progress => target == 0 ? 0 : (current / target).clamp(0, 1);
  bool get completed => current >= target;
  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderHour, minute: reminderMinute);

  Goal copyWith({
    String? id,
    String? title,
    GoalType? type,
    int? target,
    int? current,
    bool? active,
    DateTime? createdAt,
    String? unit,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      target: target ?? this.target,
      current: current ?? this.current,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      unit: unit ?? this.unit,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
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
    'unit': unit,
    'reminderEnabled': reminderEnabled,
    'reminderHour': reminderHour,
    'reminderMinute': reminderMinute,
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
    unit: (map['unit'] ?? _defaultUnit(_typeFrom(map['type']))).toString(),
    reminderEnabled: map['reminderEnabled'] is bool
        ? map['reminderEnabled'] as bool
        : false,
    reminderHour: (map['reminderHour'] as num? ?? 9).toInt(),
    reminderMinute: (map['reminderMinute'] as num? ?? 0).toInt(),
  );

  static GoalType _typeFrom(dynamic value) {
    final s = (value ?? '').toString();
    return GoalType.values.firstWhere(
      (e) => e.name == s,
      orElse: () => GoalType.reading,
    );
  }

  static String _defaultUnit(GoalType type) {
    switch (type) {
      case GoalType.reading:
      case GoalType.listening:
      case GoalType.memorization:
      case GoalType.tafsir:
        return 'آية';
    }
  }

  String toJson() => jsonEncode(toMap());

  factory Goal.fromJson(String s) =>
      Goal.fromMap(jsonDecode(s) as Map<String, dynamic>);
}
