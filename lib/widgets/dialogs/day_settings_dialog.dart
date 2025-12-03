import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sws/providers/model_providers/model_providers.dart' show WorkShiftItemViewModel, WorkingTimeViewModel;
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
  final format = DateFormat('E, d MMMM yyyy', 'ru');

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
                      decoration: const InputDecoration(labelText: 'Смена', border: OutlineInputBorder()),
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
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                    if (selectedShiftIsException)
                      TextButton(
                        onPressed: () {
                          onDeleteExceptionBtnClick();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Настройки для ${day.day}.${day.month} удалены'),
                              behavior: SnackBarBehavior.floating,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(15), bottom: Radius.circular(15)),
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Удалить'),
                      ),
                    TextButton(
                      onPressed:
                          selectedShiftState != selectedShift || workingTimeState != workingTime
                              ? () {
                                onSaveExceptionBtnClick(selectedShiftState, day, workingTimeState);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Настройки для ${day.day}.${day.month} '
                                      '${selectedShiftIsException ? 'обновлены' : 'добавлены'}',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(15), bottom: Radius.circular(15)),
                                    ),
                                  ),
                                );
                              }
                              : null,
                      child: Text(selectedShiftIsException ? 'Сохранить' : 'Добавить'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
  );
}
