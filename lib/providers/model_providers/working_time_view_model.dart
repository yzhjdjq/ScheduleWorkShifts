import 'package:flutter/material.dart' show BuildContext, MaterialLocalizations, TimeOfDay;
import 'package:sws/models/models.dart' show WorkingTime;

class WorkingTimeViewModel {
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  const WorkingTimeViewModel({this.startTime, this.endTime});

  static WorkingTimeViewModel fromWorkingTime(WorkingTime workingTime) => WorkingTimeViewModel(
    startTime: workingTime.startTime != null ? TimeOfDay.fromDateTime(workingTime.startTime!) : null,
    endTime: workingTime.endTime != null ? TimeOfDay.fromDateTime(workingTime.endTime!) : null,
  );

  toWorkingTime() {
    final DateTime? startTime =
        this.startTime != null
            ? DateTime.now().copyWith(hour: this.startTime?.hour, minute: this.startTime?.minute)
            : null;
    final DateTime? endTime =
        this.endTime != null ? DateTime.now().copyWith(hour: this.endTime?.hour, minute: this.endTime?.minute) : null;
    return WorkingTime(startTime: startTime, endTime: endTime);
  }

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

  WorkingTimeViewModel copyWith({TimeOfDay? startTime, TimeOfDay? endTime}) {
    return WorkingTimeViewModel(startTime: startTime ?? this.startTime, endTime: endTime ?? this.endTime);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkingTimeViewModel &&
          runtimeType == other.runtimeType &&
          startTime?.hour == other.startTime?.hour &&
          startTime?.minute == other.startTime?.minute &&
          endTime?.hour == other.endTime?.hour &&
          endTime?.minute == other.endTime?.minute;

  @override
  int get hashCode => Object.hash(startTime, endTime);

  @override
  String toString() {
    return 'WorkingTime(startTime: $startTime, endTime: $endTime, duration: $duration)';
  }
}
