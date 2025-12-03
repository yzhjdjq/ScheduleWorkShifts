import 'dart:ui' show Color;
import 'package:uuid/uuid.dart' show Uuid;

enum ShiftCategory { dayOff, workingDay, vacation, sickLeave }

class WorkShift {
  final String id;
  final String name;
  final ShiftCategory category;
  final Color color;

  const WorkShift({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
  });

  bool isStatic() {
    return category == ShiftCategory.vacation || category == ShiftCategory.sickLeave;
  }

  WorkShift copyWith({
    String? name,
    ShiftCategory? category,
    Color? color,
  }) {
    return WorkShift(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
    );
  }

  static WorkShift createDefault() {
    return WorkShift(
      id: const Uuid().v4(),
      name: 'В день',
      category: ShiftCategory.workingDay,
      color: const Color(0xFF864000),
    );
  }

  static WorkShift vacation({Color? color}) {
    return WorkShift(
      id: 'vacation',
      name: 'Отпуск',
      category: ShiftCategory.vacation,
      color: color ?? const Color(0xFF00FF00),
    );
  }

  bool isVacation() => category == ShiftCategory.vacation;

  static WorkShift sickLeave({Color? color}) {
    return WorkShift(
      id: 'sickLeave',
      name: 'Больничный',
      category: ShiftCategory.sickLeave,
      color: color ?? const Color(0xFFFF0000),
    );
  }

  bool isSickLeave() => category == ShiftCategory.sickLeave;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.index,
      'color': color.toARGB32(),
    };
  }

  static WorkShift fromJson(Map<String, dynamic> json) {
    return WorkShift(
      id: json['id'] as String,
      name: json['name'] as String,
      category: ShiftCategory.values[json['category'] as int],
      color: Color(json['color'] as int),
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is WorkShift &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    name == other.name &&
    category == other.category &&
    color.toARGB32() == other.color.toARGB32();

  @override
  int get hashCode => Object.hash(id, name, category, color.toARGB32());

  @override
  String toString() {
    return 'WorkShift(id: $id, name: $name, category: $category, color: $color)';
  }
}