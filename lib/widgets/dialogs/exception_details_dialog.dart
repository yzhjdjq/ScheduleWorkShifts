import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sws/models/models.dart' show WorkShift;
import 'package:sws/providers/providers.dart' show ScheduleProvider;
import 'package:sws/widgets/widgets.dart' show showDaySettingsDialog;

void showExceptionDetailsDialog({
  required BuildContext context,
  required DateTime day,
  required ScheduleProvider scheduleProvider,
  required String scheduleId,
}) {
  final exception = scheduleProvider.getExceptionForDate(day, scheduleId);
  if (exception == null) return;

  final workShift = scheduleProvider.allWorkShifts.firstWhere(
    (shift) => shift.id == exception.workShiftId,
    orElse: () => WorkShift.createDefault(),
  );

  final format = DateFormat('d MMMM yyyy', 'ru');

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        format.format(day),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(workShift.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 16),
          if (exception.startDate != exception.endDate) ...[
            const Text('Период:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(
              '${exception.startDate.day}.${exception.startDate.month}.${exception.startDate.year} - '
              '${exception.endDate.day}.${exception.endDate.month}.${exception.endDate.year}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
          if (exception.startDate == exception.endDate &&
              exception.workingTime?.startTime != null &&
              exception.workingTime?.endTime != null) ...[
            const Text('Рабочее время:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(exception.workingTime?.getWorkingTimeText(context) ?? ''),
            const SizedBox(height: 8),
            Text('Продолжительность: ${exception.workingTime?.durationText}'),
          ],
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (exception.startDate == exception.endDate &&
                exception.workShiftId != 'vacation' &&
                exception.workShiftId != 'sickLeave')
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  showDaySettingsDialog(
                    context: context,
                    day: day,
                    scheduleProvider: scheduleProvider,
                    scheduleId: scheduleId,
                    existingException: exception,
                  );
                },
                child: const Text('Изменить'),
              )
            else
              const SizedBox(),
            TextButton(
              onPressed: () {
                scheduleProvider.removeScheduleException(exception.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${workShift.name} удалён'),
                    behavior: SnackBarBehavior.floating,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Удалить'),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ],
        ),
      ],
    ),
  );
}