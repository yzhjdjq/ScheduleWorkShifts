import 'package:uuid/uuid.dart' show Uuid;

class Schedule {
  String id;
  String name;
  DateTime startDate;
  bool isActive;

  Schedule({
    required this.id,
    required this.name,
    required this.startDate,
    this.isActive = false,
  });

  Schedule.copy(Schedule other)
      : this(
    id: other.id,
    name: other.name,
    startDate: other.startDate,
    isActive: other.isActive,
  );

  static Schedule createDefault() {
    return Schedule(
      id: const Uuid().v4(),
      name: 'График',
      startDate: DateTime.now(),
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
        startDate: DateTime.parse((json['startDate'] as String)),
        isActive: json['isActive'] as bool,
    );
  }
}