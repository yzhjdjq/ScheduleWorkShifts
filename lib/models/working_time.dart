import 'package:flutter/material.dart' show BuildContext, MaterialLocalizations, TimeOfDay;

class WorkingTime {
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  const WorkingTime({this.startTime, this.endTime});

  Duration? get duration {
    if (startTime == null || endTime == null) return null;

    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;

    if (endMinutes >= startMinutes) {
      return Duration(minutes: endMinutes - startMinutes);
    } else {
      return Duration(minutes: (24 * 60 - startMinutes) + endMinutes);
    }
  }

  String get durationText {
    if (duration != null) {
      final hours = duration!.inHours;
      final minutes = duration!.inMinutes % 60;
      return '$hoursч $minutesм';
    }
    return '0ч 0м';
  }

  String getWorkingTimeText(BuildContext context) {
    if (startTime != null && endTime != null) {
      return '${formatTimeOfDay(startTime!, context)} - ${formatTimeOfDay(endTime!, context)}';
    }
    return 'Выберите время';
  }

  static String formatTimeOfDay(TimeOfDay? time, BuildContext context) {
    if (time == null) {
      return '--:--';
    }
    return MaterialLocalizations.of(context).formatTimeOfDay(time, alwaysUse24HourFormat: true);
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime != null ? {'hour': startTime!.hour, 'minute': startTime!.minute} : null,
      'endTime': endTime != null ? {'hour': endTime!.hour, 'minute': endTime!.minute} : null,
    };
  }

  static WorkingTime fromJson(Map<String, dynamic> json) {
    TimeOfDay? start, end;

    final startJson = json['startTime'];
    if (startJson != null) {
      start = TimeOfDay(hour: startJson['hour'], minute: startJson['minute']);
    }

    final endJson = json['endTime'];
    if (endJson != null) {
      end = TimeOfDay(hour: endJson['hour'], minute: endJson['minute']);
    }

    return WorkingTime(startTime: start, endTime: end);
  }

  WorkingTime copyWith({TimeOfDay? startTime, TimeOfDay? endTime}) {
    return WorkingTime(startTime: startTime ?? this.startTime, endTime: endTime ?? this.endTime);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkingTime &&
          runtimeType == other.runtimeType &&
          startTime == other.startTime &&
          endTime == other.endTime;

  @override
  int get hashCode => Object.hash(startTime, endTime);

  @override
  String toString() {
    return 'WorkingTime(startTime: $startTime, endTime: $endTime, duration: $duration)';
  }
}
