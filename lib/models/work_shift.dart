import 'dart:ui' show Color;
import 'package:flutter/material.dart' show Colors;
import 'package:uuid/uuid.dart' show Uuid;

enum ShiftCategory {
  dayOff,
  workingDay
}

class WorkShift {
  String id;
  String name;
  ShiftCategory category;
  Color color;
  bool isStatic = false;

  WorkShift({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    this.isStatic = false,
  });

  WorkShift.copy(WorkShift other)
      : this(
    id: other.id,
    name: other.name,
    category: other.category,
    color: other.color,
    isStatic: other.isStatic,
  );

  static WorkShift createDefault() {
    return WorkShift(
      id: const Uuid().v4(),
      name: 'В день',
      category: ShiftCategory.workingDay,
      color: Colors.brown,
    );
  }

  static WorkShift createStatic({
    String name = 'Отпуск',
    Color color = Colors.green,
  }) {
    return WorkShift(
      id: const Uuid().v4(),
      name: name,
      category: ShiftCategory.dayOff,
      color: color,
      isStatic: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.index,
      'color': color.toARGB32(),
      'isStatic': isStatic,
    };
  }

  static WorkShift fromJson(Map<String, dynamic> json) {
    return WorkShift(
      id: json['id'] as String,
      name: json['name'] as String,
      category: ShiftCategory.values[json['category']],
      color: Color(json['color']),
      isStatic: json['isStatic'] as bool,
    );
  }
}