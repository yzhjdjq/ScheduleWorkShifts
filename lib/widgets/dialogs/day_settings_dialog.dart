import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart' show ReadContext;
import 'package:sws/providers/providers.dart'
    show SnackBarMessageProvider, WorkShiftItemViewModel, WorkingTimeViewModel;
import 'package:sws/services/services.dart' show S;
import 'package:sws/widgets/widgets.dart' show WorkingTimeEditWidget;

void showDaySettingsDialog({
  required BuildContext context,
  required DateTime day,
  required WorkShiftItemViewModel selectedShift,
  required bool selectedShiftIsException,
  required List<WorkShiftItemViewModel> workShifts,
  required WorkingTimeViewModel workingTime,
  required VoidCallback onDeleteExceptionBtnClick,
  required void Function(WorkShiftItemViewModel, DateTime, WorkingTimeViewModel) onSaveExceptionBtnClick,
}) {
  final format = DateFormat('E, d MMMM yyyy', S.of(context).localeName);

  var workingTimeState = workingTime;
  var selectedShiftState = selectedShift;

  showDialog(
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(format.format(day), textAlign: TextAlign.center),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: S.of(context).shift, border: const OutlineInputBorder()),
                      value: selectedShiftState.id,
                      items:
                          workShifts
                              .where((shift) => !shift.isStatic())
                              .map(
                                (shift) => DropdownMenuItem<String>(
                                  value: shift.id,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(color: shift.color, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(shift.name),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() {
                            if (value == null) {
                              selectedShiftState = selectedShift;
                            } else {
                              selectedShiftState = workShifts.firstWhere((shift) => shift.id == value);
                            }
                          }),
                    ),
                    const SizedBox(height: 16),
                    WorkingTimeEditWidget(
                      workingTime: workingTimeState,
                      onTimeChanged: (updated) => setState(() => workingTimeState = updated),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).cancel)),
                    if (selectedShiftIsException)
                      TextButton(
                        onPressed: () {
                          onDeleteExceptionBtnClick();
                          Navigator.pop(context);
                          context.read<SnackBarMessageProvider>().showSuccess(
                            S.of(context).settingsForDayDeleted(day.day, day.month),
                          );
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: Text(S.of(context).delete),
                      ),
                    TextButton(
                      onPressed:
                          selectedShiftState != selectedShift || workingTimeState != workingTime
                              ? () {
                                onSaveExceptionBtnClick(selectedShiftState, day, workingTimeState);
                                Navigator.pop(context);
                                context.read<SnackBarMessageProvider>().showSuccess(
                                  selectedShiftIsException
                                      ? S.of(context).settingsForDayUpdated(day.day, day.month)
                                      : S.of(context).settingsForDayAdded(day.day, day.month),
                                );
                              }
                              : null,
                      child: Text(selectedShiftIsException ? S.of(context).save : S.of(context).add),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
  );
}
