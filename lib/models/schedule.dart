import 'package:uuid/uuid.dart' show Uuid;

class Schedule {
  final String id;
  final String name;
  final DateTime startDate;

  const Schedule({
    required this.id,
    required this.name,
    required this.startDate,
  });

  Schedule copyWith({
    String? name,
    DateTime? startDate,
  }) {
    return Schedule(
      id: id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
    );
  }

  static Schedule createDefault() {
    return Schedule(
      id: const Uuid().v4(),
      name: 'График',
      startDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
    };
  }

  static Schedule fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
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
    startDate.day == other.startDate.day;

  @override
  int get hashCode => Object.hash(id, name, startDate.year, startDate.month, startDate.day);

  @override
  String toString() {
    return 'Schedule(id: $id, name: $name, startDate: $startDate)';
  }
}