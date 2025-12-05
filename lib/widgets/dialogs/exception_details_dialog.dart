import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart' show ReadContext;
import 'package:sws/providers/providers.dart'
    show ScheduleExceptionItemViewModel, SnackBarMessageProvider, WorkShiftItemViewModel;

void showExceptionDetailsDialog({
  required BuildContext context,
  required DateTime day,
  required ScheduleExceptionItemViewModel scheduleException,
  required WorkShiftItemViewModel workShift,
  required bool isNotStaticShiftScheduleException,
  required void Function(ScheduleExceptionItemViewModel, DateTime, WorkShiftItemViewModel) onEditBtnClick,
  required void Function(ScheduleExceptionItemViewModel) onDeleteBtnClick,
}) {
  final format = DateFormat('d MMMM yyyy', 'ru');

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
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
              if (scheduleException.startDate != scheduleException.endDate) ...[
                const Text('Период:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  '${scheduleException.startDate.day}.${scheduleException.startDate.month}.${scheduleException.startDate.year} - '
                  '${scheduleException.endDate.day}.${scheduleException.endDate.month}.${scheduleException.endDate.year}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              if (scheduleException.startDate == scheduleException.endDate &&
                  scheduleException.workingTime?.startTime != null &&
                  scheduleException.workingTime?.endTime != null) ...[
                const Text('Рабочее время:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(scheduleException.workingTime?.getWorkingTimeText(context) ?? ''),
                const SizedBox(height: 8),
                Text('Продолжительность: ${scheduleException.workingTime?.durationText}'),
              ],
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isNotStaticShiftScheduleException)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onEditBtnClick(scheduleException, day, workShift);
                    },
                    child: const Text('Изменить'),
                  )
                else
                  const SizedBox(),
                TextButton(
                  onPressed: () {
                    onDeleteBtnClick(scheduleException);
                    Navigator.pop(context);
                    context.read<SnackBarMessageProvider>().showSuccess('${workShift.name} удалён');
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
