import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext;
import 'package:sws/providers/providers.dart' show ScheduleExceptionDialogsProvider, SnackBarMessageProvider;

void vacationDialogWidget(BuildContext context) {
  final widgetProvider = context.read<ScheduleExceptionDialogsProvider>();
  final activeScheduleId = widgetProvider.getActiveScheduleId();

  if (widgetProvider.isComparisonMode()) {
    context.read<SnackBarMessageProvider>().showWarning(
      'Нельзя добавить отпуск в режиме сравнения графиков. Сначала выберите один график.',
    );
    return;
  }

  if (activeScheduleId == null) {
    context.read<SnackBarMessageProvider>().showWarning('Сначала выберите активный график');
    return;
  }

  _exceptionDialogWidget(context, 'Добавить отпуск', activeScheduleId, widgetProvider.addVacation);
}

void sickLeaveDialogWidget(BuildContext context) {
  final widgetProvider = context.read<ScheduleExceptionDialogsProvider>();
  final activeScheduleId = widgetProvider.getActiveScheduleId();

  if (widgetProvider.isComparisonMode()) {
    context.read<SnackBarMessageProvider>().showWarning(
      'Нельзя добавить больничный в режиме сравнения графиков. Сначала выберите один график.',
    );
    return;
  }

  if (activeScheduleId == null) {
    context.read<SnackBarMessageProvider>().showWarning('Сначала выберите активный график');
    return;
  }

  _exceptionDialogWidget(context, 'Добавить больничный', activeScheduleId, widgetProvider.addSickLeave);
}

void _exceptionDialogWidget(
  BuildContext context,
  String title,
  String scheduleId,
  Function(String, DateTime, DateTime) onSave,
) {
  DateTime? startDate;
  DateTime? endDate;

  showDialog(
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              startDate = selectedDate;
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Дата начала',
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.calendar_today),
                              hintText:
                                  startDate == null
                                      ? 'Выберите дату'
                                      : '${startDate!.day}.${startDate!.month}.${startDate!.year}',
                            ),
                            controller: TextEditingController(
                              text: startDate == null ? '' : '${startDate!.day}.${startDate!.month}.${startDate!.year}',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: endDate ?? (startDate ?? DateTime.now()),
                            firstDate: startDate ?? DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              endDate = selectedDate;
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Дата окончания',
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.calendar_today),
                              hintText:
                                  endDate == null
                                      ? 'Выберите дату'
                                      : '${endDate!.day}.${endDate!.month}.${endDate!.year}',
                            ),
                            controller: TextEditingController(
                              text: endDate == null ? '' : '${endDate!.day}.${endDate!.month}.${endDate!.year}',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                TextButton(
                  onPressed:
                      startDate != null && endDate != null
                          ? () {
                            if (endDate!.isBefore(startDate!)) {
                              context.read<SnackBarMessageProvider>().showWarning(
                                'Дата окончания не может быть раньше даты начала',
                              );
                              return;
                            }

                            onSave(scheduleId, startDate!, endDate!);
                            Navigator.pop(context);
                            context.read<SnackBarMessageProvider>().showSuccess('$title - был добавлен');
                          }
                          : null,
                  child: const Text('Добавить'),
                ),
              ],
            );
          },
        ),
  );
}
