import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:uuid/uuid.dart' show Uuid;
import 'package:sws/models/models.dart' show ScheduleException, WorkShift, WorkingTime;
import 'package:sws/providers/providers.dart' show ScheduleProvider;
import 'package:sws/widgets/widgets.dart' show WorkingTimeEditWidget;

void showDaySettingsDialog({
  required BuildContext context,
  required DateTime day,
  required ScheduleProvider scheduleProvider,
  required String scheduleId,
  ScheduleException? existingException,
}) {
  final format = DateFormat('E, d MMMM yyyy', 'ru');

  WorkShift? selectedShift;
  var workingTime = WorkingTime();

  if (existingException != null) {
    selectedShift = scheduleProvider.allWorkShifts.firstWhere(
      (shift) => shift.id == existingException.workShiftId,
      orElse: () => scheduleProvider.workShifts.first,
    );
    workingTime = existingException.workingTime ?? WorkingTime();
  } else {
    selectedShift = _getCurrentShiftForDay(day, scheduleProvider);
  }

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(format.format(day), textAlign: TextAlign.center),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<WorkShift>(
                  decoration: const InputDecoration(labelText: 'Смена', border: OutlineInputBorder()),
                  value: selectedShift,
                  items: scheduleProvider.workShifts
                      .where((shift) => !shift.isStatic())
                      .map((shift) => DropdownMenuItem(
                            value: shift,
                            child: Row(
                              children: [
                                Container(width: 12, height: 12, decoration: BoxDecoration(color: shift.color, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                Text(shift.name),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedShift = value),
                ),
                const SizedBox(height: 16),
                WorkingTimeEditWidget(
                  workingTime: workingTime,
                  onTimeChanged: (updated) => setState(() => workingTime = updated),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                if (existingException != null)
                  TextButton(
                    onPressed: () {
                      scheduleProvider.removeScheduleException(existingException.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Настройки для ${day.day}.${day.month} удалены')),
                      );
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Удалить'),
                  ),
                TextButton(
                  onPressed: selectedShift != null
                      ? () {
                          final newException = ScheduleException(
                            id: existingException?.id ?? const Uuid().v4(),
                            scheduleId: scheduleId,
                            workShiftId: selectedShift!.id,
                            startDate: day,
                            endDate: day,
                            workingTime: workingTime,
                          );

                          if (existingException != null) {
                            scheduleProvider.removeScheduleException(existingException.id);
                          }
                          scheduleProvider.addScheduleException(newException);

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Настройки для ${day.day}.${day.month} ${existingException != null ? 'обновлены' : 'добавлены'}')),
                          );
                        }
                      : null,
                  child: Text(existingException != null ? 'Сохранить' : 'Добавить'),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

WorkShift _getCurrentShiftForDay(DateTime day, ScheduleProvider scheduleProvider) {
  final activeScheduleId = scheduleProvider.getActiveScheduleId();
  if (activeScheduleId == null) return scheduleProvider.workShifts.first;

  final totalCycleDays = scheduleProvider.getTotalCycleDaysForSchedule(activeScheduleId);
  if (totalCycleDays == 0) return scheduleProvider.workShifts.first;

  final dayOffset = scheduleProvider.getDayOffsetForActiveSchedule(day);
  if (dayOffset < 0) return scheduleProvider.workShifts.first;

  final cyclePosition = dayOffset % totalCycleDays;
  final sequences = scheduleProvider.shiftSequences.where((seq) => seq.scheduleId == activeScheduleId).toList()
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

  int currentDay = 0;
  for (final sequence in sequences) {
    if (cyclePosition < currentDay + sequence.consecutiveDays) {
      return scheduleProvider.allWorkShifts.firstWhere(
        (shift) => shift.id == sequence.workShiftId,
        orElse: () => scheduleProvider.workShifts.first,
      );
    }
    currentDay += sequence.consecutiveDays;
  }

  return scheduleProvider.workShifts.first;
}