import 'package:sws/models/working_time.dart' show WorkingTime;

class ScheduleException {
  final String id;
  final String scheduleId;
  final String workShiftId;
  final DateTime startDate;
  final DateTime endDate;
  final WorkingTime? workingTime;

  const ScheduleException({
    required this.id,
    required this.scheduleId,
    required this.workShiftId,
    required this.startDate,
    required this.endDate,
    this.workingTime,
  });

  ScheduleException copyWith({
    String? id,
    String? scheduleId,
    String? workShiftId,
    DateTime? startDate,
    DateTime? endDate,
    WorkingTime? workingTime,
  }) {
    return ScheduleException(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      workShiftId: workShiftId ?? this.workShiftId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      workingTime: workingTime ?? this.workingTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'workShiftId': workShiftId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'workingTime': workingTime?.toJson(),
    };
  }

  static ScheduleException fromJson(Map<String, dynamic> json) {
    return ScheduleException(
      id: json['id'] as String,
      scheduleId: json['scheduleId'] as String,
      workShiftId: json['workShiftId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      workingTime: json['workingTime'] != null
          ? WorkingTime.fromJson(json['workingTime'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ScheduleException &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    scheduleId == other.scheduleId &&
    workShiftId == other.workShiftId &&
    startDate.year == other.startDate.year &&
    startDate.month == other.startDate.month &&
    startDate.day == other.startDate.day &&
    endDate.year == other.endDate.year &&
    endDate.month == other.endDate.month &&
    endDate.day == other.endDate.day &&
    workingTime == other.workingTime;

  @override
  int get hashCode => Object.hash(
        id,
        scheduleId,
        workShiftId,
        startDate.year,
        startDate.month,
        startDate.day,
        endDate.year,
        endDate.month,
        endDate.day,
        workingTime,
      );

  @override
  String toString() {
    return 'ScheduleException('
        'id: $id, '
        'scheduleId: $scheduleId, '
        'workShiftId: $workShiftId, '
        'startDate: $startDate, '
        'endDate: $endDate, '
        'workingTime: $workingTime'
        ')';
  }
}