class ScheduleException {
  String id;
  String scheduleId;
  String workShiftId;
  DateTime startDate;
  DateTime endDate;

  ScheduleException({
    required this.id,
    required this.scheduleId,
    required this.workShiftId,
    required this.startDate,
    required this.endDate,
  });

  ScheduleException.copy(ScheduleException other)
    : this(
      id: other.id,
      scheduleId: other.scheduleId,
      workShiftId: other.workShiftId,
      startDate: other.startDate,
      endDate: other.endDate,
    );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'workShiftId': workShiftId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  static ScheduleException fromJson(Map<String, dynamic> json) {
    return ScheduleException(
      id: json['id'] as String,
      scheduleId: json['scheduleId'] as String,
      workShiftId: json['workShiftId'] as String,
      startDate: DateTime.parse((json['startDate'] as String)),
      endDate: DateTime.parse((json['endDate'] as String)),
    );
  }
}