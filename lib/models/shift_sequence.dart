class ShiftSequence {
  String id;
  String scheduleId;
  String workShiftId;
  int consecutiveDays;
  int orderIndex;
  DateTime startDate;
  DateTime endDate;

  ShiftSequence({
    required this.id,
    required this.scheduleId,
    required this.workShiftId,
    required this.consecutiveDays,
    required this.orderIndex,
    required this.startDate,
    required this.endDate,
  });

  ShiftSequence.copy(ShiftSequence other)
    : this(
      id: other.id,
      scheduleId: other.scheduleId,
      workShiftId: other.workShiftId,
      consecutiveDays: other.consecutiveDays,
      orderIndex: other.orderIndex,
      startDate: other.startDate,
      endDate: other.endDate,
    );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'workShiftId': workShiftId,
      'consecutiveDays': consecutiveDays,
      'orderIndex': orderIndex,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  static ShiftSequence fromJson(Map<String, dynamic> json) {
    return ShiftSequence(
      id: json['id'] as String,
      scheduleId: json['scheduleId'] as String,
      workShiftId: json['workShiftId'] as String,
      consecutiveDays: json['consecutiveDays'] as int,
      orderIndex: json['orderIndex'] as int,
      startDate: DateTime.parse((json['startDate'] as String)),
      endDate: DateTime.parse((json['endDate'] as String)),
    );
  }
}