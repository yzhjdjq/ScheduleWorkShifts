import 'package:flutter/material.dart' show BuildContext, MaterialLocalizations, TimeOfDay;

class WorkingTime {
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Duration? duration;

  WorkingTime();

  String getDisplayText(BuildContext context) {
    if (startTime != null && endTime != null) {
      return '${_formatTimeOfDay(startTime!, context)} - ${_formatTimeOfDay(endTime!, context)}';
    }
    return 'Выберите время';
  }

  String _formatTimeOfDay(TimeOfDay time, BuildContext context) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time, alwaysUse24HourFormat: true);
  }

  void calculateDuration() {
    if (startTime != null && endTime != null) {
      final startMinutes = startTime!.hour * 60 + startTime!.minute;
      final endMinutes = endTime!.hour * 60 + endTime!.minute;

      int totalMinutes;
      if (endMinutes >= startMinutes) {
        totalMinutes = endMinutes - startMinutes;
      } else {
        totalMinutes = (24 * 60 - startMinutes) + endMinutes;
      }

      duration = Duration(minutes: totalMinutes);
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

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime != null ? {'hour': startTime!.hour, 'minute': startTime!.minute} : null,
      'endTime': endTime != null ? {'hour': endTime!.hour, 'minute': endTime!.minute} : null,
      'durationInMinutes': duration?.inMinutes,
    };
  }

  static WorkingTime fromJson(Map<String, dynamic> json) {
    final workingTime = WorkingTime();

    if (json['startTime'] != null) {
      workingTime.startTime = TimeOfDay(
        hour: json['startTime']['hour'] as int,
        minute: json['startTime']['minute'] as int,
      );
    }

    if (json['endTime'] != null) {
      workingTime.endTime = TimeOfDay(hour: json['endTime']['hour'] as int, minute: json['endTime']['minute'] as int);
    }

    if (json['durationInMinutes'] != null) {
      workingTime.duration = Duration(minutes: json['durationInMinutes'] as int);
    }

    return workingTime;
  }
}
