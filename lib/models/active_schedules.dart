class ActiveSchedules {
  final String? activeScheduleId;
  final String? comparedScheduleId;

  const ActiveSchedules({required this.activeScheduleId, this.comparedScheduleId});

  ActiveSchedules copyWith({String? activeScheduleId, String? comparedScheduleId}) {
    return ActiveSchedules(
      activeScheduleId: activeScheduleId ?? this.activeScheduleId,
      comparedScheduleId: comparedScheduleId,
    );
  }

  Map<String, dynamic> toJson() {
    return {'activeScheduleId': activeScheduleId, 'comparedScheduleId': comparedScheduleId};
  }

  static ActiveSchedules fromJson(Map<String, dynamic> json) {
    return ActiveSchedules(
      activeScheduleId: json['activeScheduleId'] != null ? json['activeScheduleId'] as String : null,
      comparedScheduleId: json['comparedScheduleId'] != null ? json['comparedScheduleId'] as String : null,
    );
  }

  @override
  String toString() {
    return 'ActiveSchedules(activeScheduleId: $activeScheduleId, comparedScheduleId: $comparedScheduleId)';
  }
}
