import 'dart:ui' show Color;
import 'package:flutter/material.dart' show Colors;
import 'package:uuid/uuid.dart' show Uuid;

enum ShiftCategory { dayOff, workingDay, vacation, sickLeave }

class WorkShift {
  String id;
  String name;
  ShiftCategory category;
  Color color;

  bool isStatic() {
    return category == ShiftCategory.vacation || category == ShiftCategory.sickLeave;
  }

  WorkShift({required this.id, required this.name, required this.category, required this.color});

  WorkShift.copy(WorkShift other) : this(id: other.id, name: other.name, category: other.category, color: other.color);

  static WorkShift createDefault() {
    return WorkShift(id: const Uuid().v4(), name: 'В день', category: ShiftCategory.workingDay, color: Colors.brown);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'category': category.index, 'color': color.toARGB32()};
  }

  static WorkShift fromJson(Map<String, dynamic> json) {
    return WorkShift(
      id: json['id'] as String,
      name: json['name'] as String,
      category: ShiftCategory.values[json['category']],
      color: Color(json['color']),
    );
  }
}

class Vacation extends WorkShift {
  static const int greenColorArgbInt = 4283215696;

  Vacation({super.color = const Color(greenColorArgbInt)})
    : super(id: 'vacation', name: 'Отпуск', category: ShiftCategory.vacation);
}

class SickLeave extends WorkShift {
  static const int redColorArgbInt = 4294198070;

  SickLeave({super.color = const Color(redColorArgbInt)})
    : super(id: 'sickLeave', name: 'Больничный', category: ShiftCategory.sickLeave);
}
