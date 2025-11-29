import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext;
import 'package:sws/providers/schedule_provider.dart' show ScheduleProvider;

void vacationDialogWidget(BuildContext context) {
  final scheduleProvider = context.read<ScheduleProvider>();
  final activeScheduleId = scheduleProvider.getActiveScheduleId();

  if (scheduleProvider.isComparisonMode) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Нельзя добавить отпуск в режиме сравнения графиков. Сначала выберите один график.'),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15), bottom: Radius.circular(15)),
        ),
      ),
    );
    return;
  }

  if (activeScheduleId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Сначала выберите активный график'),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15), bottom: Radius.circular(15)),
        ),
      ),
    );
    return;
  }

  _exceptionDialogWidget(context, 'Добавить отпуск', activeScheduleId, scheduleProvider.addVacation);
}

void sickLeaveDialogWidget(BuildContext context) {
  final scheduleProvider = context.read<ScheduleProvider>();
  final activeScheduleId = scheduleProvider.getActiveScheduleId();

  if (scheduleProvider.isComparisonMode) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Нельзя добавить больничный в режиме сравнения графиков. Сначала выберите один график.'),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15), bottom: Radius.circular(15)),
        ),
      ),
    );
    return;
  }

  if (activeScheduleId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Сначала выберите активный график'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15), bottom: Radius.circular(15)),
        ),
      ),
    );
    return;
  }

  _exceptionDialogWidget(context, 'Добавить больничный', activeScheduleId, scheduleProvider.addSickLeave);
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
                    // Поле выбора даты начала
                    GestureDetector(
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
                    const SizedBox(height: 16),

                    // Поле выбора даты окончания
                    GestureDetector(
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Дата окончания не может быть раньше даты начала'),
                                  duration: Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15),
                                      bottom: Radius.circular(15),
                                    ),
                                  ),
                                ),
                              );
                              return;
                            }

                            onSave(scheduleId, startDate!, endDate!);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$title добавлен'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(15),
                                    bottom: Radius.circular(15),
                                  ),
                                ),
                              ),
                            );
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
