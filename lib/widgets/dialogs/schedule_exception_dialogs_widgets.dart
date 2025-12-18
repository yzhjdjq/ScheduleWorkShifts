import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext;
import 'package:sws/providers/providers.dart' show ScheduleExceptionDialogsProvider, SnackBarMessageProvider;
import 'package:sws/services/services.dart' show S;

void vacationDialogWidget(BuildContext context) {
  final widgetProvider = context.read<ScheduleExceptionDialogsProvider>();
  final activeScheduleId = widgetProvider.getActiveScheduleId();

  if (widgetProvider.isComparisonMode()) {
    context.read<SnackBarMessageProvider>().showWarning(
      S.of(context).comparisonModeWarningForVacation,
    );
    return;
  }

  if (activeScheduleId == null) {
    context.read<SnackBarMessageProvider>().showWarning(S.of(context).noActiveSchedule);
    return;
  }

  _exceptionDialogWidget(context, S.of(context).addVacation, activeScheduleId, widgetProvider.addVacation);
}

void sickLeaveDialogWidget(BuildContext context) {
  final widgetProvider = context.read<ScheduleExceptionDialogsProvider>();
  final activeScheduleId = widgetProvider.getActiveScheduleId();

  if (widgetProvider.isComparisonMode()) {
    context.read<SnackBarMessageProvider>().showWarning(
      S.of(context).comparisonModeWarningForSickLeave,
    );
    return;
  }

  if (activeScheduleId == null) {
    context.read<SnackBarMessageProvider>().showWarning(S.of(context).noActiveSchedule);
    return;
  }

  _exceptionDialogWidget(context, S.of(context).addSickLeave, activeScheduleId, widgetProvider.addSickLeave);
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
                              labelText: S.of(context).startDateTitleName,
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.calendar_today),
                              hintText:
                                  startDate == null
                                      ? S.of(context).selectDateHint
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
                              labelText: S.of(context).endDateTitleName,
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.calendar_today),
                              hintText:
                                  endDate == null
                                      ? S.of(context).selectDateHint
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
                TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).cancel)),
                TextButton(
                  onPressed:
                      startDate != null && endDate != null
                          ? () {
                            if (endDate!.isBefore(startDate!)) {
                              context.read<SnackBarMessageProvider>().showWarning(
                                S.of(context).endDateBeforeStartWarning,
                              );
                              return;
                            }

                            onSave(scheduleId, startDate!, endDate!);
                            Navigator.pop(context);
                            context.read<SnackBarMessageProvider>().showSuccess(S.of(context).objectAdded(title));
                          }
                          : null,
                  child: Text(S.of(context).add),
                ),
              ],
            );
          },
        ),
  );
}
