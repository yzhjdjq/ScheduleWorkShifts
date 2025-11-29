import 'package:uuid/uuid.dart' show Uuid;

class Schedule {
  final String id;
  final String name;
  final DateTime startDate;
  final bool isActive;

  const Schedule({
    required this.id,
    required this.name,
    required this.startDate,
    this.isActive = false,
  });

  Schedule copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    bool? isActive,
  }) {
    return Schedule(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
    );
  }

  static Schedule createDefault() {
    return Schedule(
      id: const Uuid().v4(),
      name: 'График',
      startDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      isActive: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  static Schedule fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      isActive: json['isActive'] as bool,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Schedule &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    name == other.name &&
    startDate.year == other.startDate.year &&
    startDate.month == other.startDate.month &&
    startDate.day == other.startDate.day &&
    isActive == other.isActive;

  @override
  int get hashCode => Object.hash(id, name, startDate.year, startDate.month, startDate.day, isActive);

  @override
  String toString() {
    return 'Schedule(id: $id, name: $name, startDate: $startDate, isActive: $isActive)';
  }
}