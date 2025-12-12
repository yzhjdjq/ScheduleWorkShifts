import 'package:sws/models/working_time.dart' show WorkingTime;

class ShiftSequence {
  final String id;
  final String scheduleId;
  final String workShiftId;
  final int consecutiveDays;
  final int orderIndex;
  final WorkingTime workingTime;

  const ShiftSequence({
    required this.id,
    required this.scheduleId,
    required this.workShiftId,
    required this.consecutiveDays,
    required this.orderIndex,
    required this.workingTime,
  });

  ShiftSequence copyWith({
    String? scheduleId,
    String? workShiftId,
    int? consecutiveDays,
    int? orderIndex,
    WorkingTime? workingTime,
  }) {
    return ShiftSequence(
      id: id,
      scheduleId: scheduleId ?? this.scheduleId,
      workShiftId: workShiftId ?? this.workShiftId,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      orderIndex: orderIndex ?? this.orderIndex,
      workingTime: workingTime ?? this.workingTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'workShiftId': workShiftId,
      'consecutiveDays': consecutiveDays,
      'orderIndex': orderIndex,
      'workingTime': workingTime.toJson(),
    };
  }

  static ShiftSequence fromJson(Map<String, dynamic> json) {
    return ShiftSequence(
      id: json['id'] as String,
      scheduleId: json['scheduleId'] as String,
      workShiftId: json['workShiftId'] as String,
      consecutiveDays: json['consecutiveDays'] as int,
      orderIndex: json['orderIndex'] as int,
      workingTime: WorkingTime.fromJson(json['workingTime'] as Map<String, dynamic>),
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ShiftSequence &&
    runtimeType == other.runtimeType &&
    id == other.id &&
    scheduleId == other.scheduleId &&
    workShiftId == other.workShiftId &&
    consecutiveDays == other.consecutiveDays &&
    orderIndex == other.orderIndex &&
    workingTime == other.workingTime;

  @override
  int get hashCode => Object.hash(id, scheduleId, workShiftId, consecutiveDays, orderIndex, workingTime);

  @override
  String toString() {
    return 'ShiftSequence('
        'id: $id, '
        'scheduleId: $scheduleId, '
        'workShiftId: $workShiftId, '
        'consecutiveDays: $consecutiveDays, '
        'orderIndex: $orderIndex, '
        'workingTime: $workingTime'
        ')';
  }
}