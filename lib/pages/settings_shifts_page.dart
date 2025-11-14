import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sws/providers/settings_provider.dart';
import 'package:sws/models/work_shift.dart';
import 'package:sws/widgets/color_picker_widget.dart';

class SettingsShiftsPage extends StatelessWidget {
  const SettingsShiftsPage({super.key});

  void _addNewShiftBtnHandler(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final newShift = WorkShift.createDefault();

    _editShiftDialogWidget(
      context,
      newShift,
      isNewShift: true,
      onSave: (savedShift)
        => settings.addWorkShift(savedShift),
    );
  }

  void _editStaticShiftDialogWidget(BuildContext context, WorkShift shift) {
    final settings = context.read<SettingsProvider>();
    WorkShift editedShift = WorkShift.copy(shift);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Цвет для ${editedShift.name}'),
            content: ColorPickerWidget(shift: editedShift, setState: setState),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  final savedShift = WorkShift.copy(editedShift);
                  settings.updateStaticShiftColor(shift.id, savedShift.color);
                  Navigator.pop(context);
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editShiftDialogWidget(
      BuildContext context,
      WorkShift shift, {
        bool isNewShift = false,
        Function(WorkShift)? onSave,
      }) {
    final settings = context.read<SettingsProvider>();
    final textController = TextEditingController(text: shift.name);
    WorkShift editedShift = WorkShift.copy(shift);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
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
                      decoration: const InputDecoration(
                        labelText: 'Название смены',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildCategoryRadioButtons(editedShift, setState),
                    const SizedBox(height: 20),

                    ColorPickerWidget(shift: editedShift, setState: setState),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  final savedShift = WorkShift.copy(editedShift);
                  savedShift.name = textController.text.isEmpty
                    ? 'Новая смена'
                    : textController.text;

                  if (isNewShift && onSave != null) {
                    onSave(savedShift);
                  } else {
                    settings.updateWorkShift(shift.id, savedShift);
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

  Widget _buildCategoryRadioButtons(WorkShift shift, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Категория:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: RadioListTile<ShiftCategory>(
                title: const Text('Рабочий день'),
                value: ShiftCategory.workingDay,
                groupValue: shift.category,
                onChanged: (value) {
                  setState(() {
                    shift.category = value!;
                  });
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
                  setState(() {
                    shift.category = value!;
                  });
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
      builder: (context) => AlertDialog(
        title: const Text('Удалить смену?'),
        content: Text('Вы уверены, что хотите удалить "${shift.name}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
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

  // Редактирование существующей смены
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
      appBar: AppBar(
        title: const Text('Настройка смен'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          if (settings.workShifts.isEmpty) {
            return const Center(
              child: Text(
                'Нажмите + чтобы добавить первую смену',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: settings.allWorkShifts.length,
            itemBuilder: (context, index) {
              final shift = settings.allWorkShifts[index];
              return Card(
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
                  subtitle: shift.isStatic() ? null : Text(
                    shift.category == ShiftCategory.workingDay
                        ? 'Рабочий день'
                        : 'Выходной',
                    style: TextStyle(
                      color: shift.category == ShiftCategory.workingDay
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => _editExistingShiftBtnHandler(context, shift),
                  onLongPress:
                    shift.isStatic()
                      ? null
                      : settings.workShifts.length <=2
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