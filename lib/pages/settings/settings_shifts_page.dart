import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sws/models/models.dart' show WorkShift, ShiftCategory;
import 'package:sws/providers/providers.dart' show SettingsProvider;
import 'package:sws/widgets/widgets.dart' show ColorPickerWidget;

class SettingsShiftsPage extends StatelessWidget {
  const SettingsShiftsPage({super.key});

  void _addNewShiftBtnHandler(BuildContext context) {
    final newShift = WorkShift.createDefault();
    _editShiftDialogWidget(
      context,
      newShift,
      isNewShift: true,
      onSave: (savedShift) {
        context.read<SettingsProvider>().addWorkShift(savedShift);
      },
    );
  }

  void _editStaticShiftDialogWidget(BuildContext context, WorkShift shift) {
    var selectedColor = shift.color;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Цвет для ${shift.name}'),
            content: ColorPickerWidget(
              shift: shift.copyWith(color: selectedColor),
              onColorChanged: (color) {
                selectedColor = color;
              },
            ),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
              TextButton(
                onPressed: () {
                  // Сохраняем только при нажатии
                  context.read<SettingsProvider>().updateStaticShiftColor(shift.id, selectedColor);
                  Navigator.pop(context);
                },
                child: const Text('Сохранить'),
              ),
            ],
          ),
    );
  }

  void _editShiftDialogWidget(
    BuildContext context,
    WorkShift shift, {
    bool isNewShift = false,
    void Function(WorkShift)? onSave,
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
                title: Text(isNewShift ? 'Создание смены' : 'Редактировать смену'),
                content: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          controller: textController,
                          decoration: const InputDecoration(labelText: 'Название смены', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 20),
                        _buildCategoryRadioButtons(editedShift, (updatedShift) {
                          setState(() {
                            editedShift = updatedShift;
                          });
                        }),
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
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                  TextButton(
                    onPressed: () {
                      final finalShift = editedShift.copyWith(
                        name: textController.text.isEmpty ? 'Новая смена' : textController.text,
                        color: selectedColor,
                      );
                      if (isNewShift && onSave != null) {
                        onSave(finalShift);
                      } else {
                        context.read<SettingsProvider>().updateWorkShift(finalShift);
                      }
                      Navigator.pop(context);
                    },
                    child: Text(isNewShift ? 'Создать' : 'Сохранить'),
                  ),
                ],
              );
            },
          ),
    );
  }

  Widget _buildCategoryRadioButtons(WorkShift shift, void Function(WorkShift) onShiftUpdated) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Категория:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: RadioListTile<ShiftCategory>(
                title: const Text('Рабочий день'),
                value: ShiftCategory.workingDay,
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
              child: RadioListTile<ShiftCategory>(
                title: const Text('Выходной'),
                value: ShiftCategory.dayOff,
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

  void _deleteShiftBtnHandler(BuildContext context, WorkShift shift) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Удалить смену?'),
            content: Text('Вы уверены, что хотите удалить "${shift.name}"?'),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
              TextButton(
                onPressed: () {
                  context.read<SettingsProvider>().removeWorkShift(shift.id);
                  Navigator.pop(context);
                },
                child: const Text('Удалить'),
              ),
            ],
          ),
    );
  }

  void _editExistingShiftBtnHandler(BuildContext context, WorkShift shift) {
    if (shift.isStatic()) {
      _editStaticShiftDialogWidget(context, shift);
      return;
    }
    _editShiftDialogWidget(context, shift, isNewShift: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройка смен')),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          final workShifts = provider.allWorkShifts;

          if (workShifts.isEmpty) {
            return const Center(
              child: Text('Нажмите + чтобы добавить первую смену', style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                            shift.category == ShiftCategory.workingDay ? 'Рабочий день' : 'Выходной',
                            style: TextStyle(
                              color: shift.category == ShiftCategory.workingDay ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  onTap: () => _editExistingShiftBtnHandler(context, shift),
                  onLongPress:
                      shift.isStatic()
                          ? null
                          : workShifts.where((s) => !s.isStatic()).length <= 2
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
