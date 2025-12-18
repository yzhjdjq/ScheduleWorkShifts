import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext, Consumer;

import 'package:sws/providers/providers.dart'
    show SettingsShiftsPageProvider, ShiftCategoryViewModel, WorkShiftItemViewModel;
import 'package:sws/services/services.dart' show S;
import 'package:sws/widgets/widgets.dart' show ColorPickerWidget;

class SettingsShiftsPage extends StatelessWidget {
  const SettingsShiftsPage({super.key});

  void _addNewShiftBtnHandler(BuildContext context) {
    final newShift = WorkShiftItemViewModel.createDefault();
    _editShiftDialogWidget(
      context,
      newShift,
      isNewShift: true,
      onSave: (savedShift) {
        context.read<SettingsShiftsPageProvider>().addWorkShift(savedShift);
      },
    );
  }

  void _editStaticShiftDialogWidget(BuildContext context, WorkShiftItemViewModel shift) {
    var selectedColor = shift.color;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(S.of(context).colorForShift(shift.name)),
            content: ColorPickerWidget(
              shift: shift.copyWith(color: selectedColor),
              onColorChanged: (color) {
                selectedColor = color;
              },
            ),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).cancel)),
              TextButton(
                onPressed: () {
                  context.read<SettingsShiftsPageProvider>().updateStaticShiftColor(shift.id, selectedColor);
                  Navigator.pop(context);
                },
                child: Text(S.of(context).save),
              ),
            ],
          ),
    );
  }

  void _editShiftDialogWidget(
    BuildContext context,
    WorkShiftItemViewModel shift, {
    bool isNewShift = false,
    void Function(WorkShiftItemViewModel)? onSave,
  }) {
    final textController = TextEditingController(text: shift.name);
    var editedShift = shift;
    var selectedColor = shift.color;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(isNewShift ? S.of(context).createShiftTitle : S.of(context).editShiftTitle),
                content: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          controller: textController,
                          decoration: InputDecoration(labelText: S.of(context).shiftName, border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 20),
                        _buildCategoryRadioButtons(editedShift, (updatedShift) {
                          setState(() {
                            editedShift = updatedShift;
                          });
                        }, context),
                        const SizedBox(height: 20),
                        ColorPickerWidget(
                          shift: editedShift.copyWith(color: selectedColor),
                          onColorChanged: (color) {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).cancel)),
                  TextButton(
                    onPressed: () {
                      final finalShift = editedShift.copyWith(
                        name: textController.text.isEmpty ? S.of(context).newShiftName : textController.text,
                        color: selectedColor,
                      );
                      if (isNewShift && onSave != null) {
                        onSave(finalShift);
                      } else {
                        context.read<SettingsShiftsPageProvider>().updateWorkShift(finalShift);
                      }
                      Navigator.pop(context);
                    },
                    child: Text(isNewShift ? S.of(context).create : S.of(context).save),
                  ),
                ],
              );
            },
          ),
    );
  }

  Widget _buildCategoryRadioButtons(
    WorkShiftItemViewModel shift,
    void Function(WorkShiftItemViewModel) onShiftUpdated,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(S.of(context).shiftCategory, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: RadioListTile<ShiftCategoryViewModel>(
                title: Text(S.of(context).workingDay),
                value: ShiftCategoryViewModel.workingDay,
                groupValue: shift.category,
                onChanged: (value) {
                  if (value != null) {
                    final updated = shift.copyWith(category: value);
                    onShiftUpdated(updated);
                  }
                },
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<ShiftCategoryViewModel>(
                title: Text(S.of(context).dayOff),
                value: ShiftCategoryViewModel.dayOff,
                groupValue: shift.category,
                onChanged: (value) {
                  if (value != null) {
                    final updated = shift.copyWith(category: value);
                    onShiftUpdated(updated);
                  }
                },
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _deleteShiftBtnHandler(BuildContext context, WorkShiftItemViewModel shift) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(S.of(context).deleteShiftQuestion),
            content: Text(S.of(context).confirmDeleteShift(shift.name)),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).cancel)),
              TextButton(
                onPressed: () {
                  context.read<SettingsShiftsPageProvider>().removeWorkShift(shift.id);
                  Navigator.pop(context);
                },
                child: Text(S.of(context).cancel),
              ),
            ],
          ),
    );
  }

  void _editExistingShiftBtnHandler(BuildContext context, WorkShiftItemViewModel shift) {
    if (shift.isStatic()) {
      _editStaticShiftDialogWidget(context, shift);
      return;
    }
    _editShiftDialogWidget(context, shift, isNewShift: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).settingsShiftsBarTitle)),
      body: Consumer<SettingsShiftsPageProvider>(
        builder: (context, provider, child) {
          final workShifts = provider.allWorkShifts;
          const int minimumNumberShifts = 2;

          if (workShifts.isEmpty) {
            return Center(
              child: Text(S.of(context).addFirstShiftHint, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: workShifts.length,
            itemBuilder: (context, index) {
              final shift = workShifts[index];
              return Card(
                key: ValueKey('shift-${shift.id}-color-${shift.color.toARGB32()}'),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: shift.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  title: Text(shift.name),
                  subtitle:
                      shift.isStatic()
                          ? null
                          : Text(
                            shift.category == ShiftCategoryViewModel.workingDay
                                ? S.of(context).workingDay
                                : S.of(context).dayOff,
                            style: TextStyle(
                              color: shift.category == ShiftCategoryViewModel.workingDay ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  onTap: () => _editExistingShiftBtnHandler(context, shift),
                  onLongPress:
                      shift.isStatic()
                          ? null
                          : workShifts.where((s) => !s.isStatic()).length <= minimumNumberShifts
                          ? null
                          : () => _deleteShiftBtnHandler(context, shift),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewShiftBtnHandler(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
