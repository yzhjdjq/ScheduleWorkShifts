import 'package:uuid/uuid.dart' show Uuid;

class Schedule {
  String id;
  String name;

  Schedule({
    required this.id,
    required this.name,
  });

  Schedule.copy(Schedule other)
      : this(
    id: other.id,
    name: other.name,
  );

  static Schedule createDefault() {
    return Schedule(
      id: const Uuid().v4(),
      name: 'График',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  static Schedule fromJson(Map<String, dynamic> json) {
    return Schedule(
        id: json['id'] as String,
        name: json['name'] as String,
    );
  }
}