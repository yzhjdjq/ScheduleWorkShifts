import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sws/providers/settings_provider.dart';
import 'package:sws/models/work_shift.dart';

class SettingsShiftsPage extends StatelessWidget {
  const SettingsShiftsPage({super.key});

  void _addNewShift(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final newShift = WorkShift.createDefault();

    _editShift(
      context,
      newShift,
      isNewShift: true,
      onSave: (savedShift)
        => settings.addWorkShift(savedShift),
    );
  }

  void _editStaticShiftColor(BuildContext context, WorkShift shift) {
    final settings = context.read<SettingsProvider>();
    WorkShift editedShift = WorkShift.copy(shift);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Цвет для ${editedShift.name}'),
            content: _buildColorPicker(context, editedShift, setState),
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
                child: Text(isNewShift ? 'Создать' : 'Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editShift(
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
                padding: EdgeInsets.all(8),
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

                    _buildColorPicker(context, editedShift, setState),
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
          children: [
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

  Widget _buildColorPicker(BuildContext context, WorkShift shift, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Цвет смены:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Предпросмотр выбранного цвета
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: shift.color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              shift.category == ShiftCategory.workingDay ? 'Рабочий день' : 'Выходной',
              style: TextStyle(
                color: shift.color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Градиент для выбора цвета
        Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: GestureDetector(
            onTapDown: (details) {
              final renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final localPosition = renderBox.globalToLocal(details.globalPosition);
                final relativeX = localPosition.dx / renderBox.size.width;

                // Преобразование позиции в цвет
                final newColor = _getColorFromPosition(relativeX);
                setState(() {
                  shift.color = newColor;
                });
              }
            },
            onPanUpdate: (details) {
              final renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final localPosition = renderBox.globalToLocal(details.globalPosition);
                final relativeX = localPosition.dx.clamp(0.0, renderBox.size.width) / renderBox.size.width;

                // Преобразование позиции в цвет
                final newColor = _getColorFromPosition(relativeX);
                setState(() {
                  shift.color = newColor;
                });
              }
            },
            child: Container(),
          ),
        ),
        const SizedBox(height: 8),

        // Точный выбор через HSLColor
        _buildHslColorPicker(shift, setState),
      ],
    );
  }

  // Точный выбор цвета через HSL
  Widget _buildHslColorPicker(WorkShift shift, StateSetter setState) {
    final hslColor = HSLColor.fromColor(shift.color);

    return Column(
      children: [
        // Ползунок для оттенка (Hue)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Цвет:'),
            Slider(
              value: hslColor.hue,
              min: 0,
              max: 360,
              onChanged: (value) {
                setState(() {
                  shift.color = hslColor.withHue(value).toColor();
                });
              },
              activeColor: shift.color,
            ),
          ],
        ),

        // Ползунок для насыщенности (Saturation)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Насыщенность:'),
            Slider(
              value: hslColor.saturation,
              min: 0,
              max: 1,
              onChanged: (value) {
                setState(() {
                  shift.color = hslColor.withSaturation(value).toColor();
                });
              },
              activeColor: shift.color,
            ),
          ],
        ),

        // Ползунок для светлоты (Lightness)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Яркость:'),
            Slider(
              value: hslColor.lightness,
              min: 0,
              max: 1,
              onChanged: (value) {
                setState(() {
                  shift.color = hslColor.withLightness(value).toColor();
                });
              },
              activeColor: shift.color,
            ),
          ],
        ),
      ],
    );
  }

  // Преобразование позиции в цвет из градиента
  Color _getColorFromPosition(double position) {
    const colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    final segment = 1.0 / (colors.length - 1);
    final index = (position / segment).clamp(0, colors.length - 2).floor();
    final localPosition = (position - index * segment) / segment;

    return Color.lerp(colors[index], colors[index + 1], localPosition)!;
  }

  void _deleteShift(BuildContext context, WorkShift shift) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить смену?'),
        content: Text('Вы уверены, что хотите удалить "${shift.name}"?'),
        actions: [
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
  void _editExistingShift(BuildContext context, WorkShift shift) {
    if (shift.isStatic()) {
      _editStaticShiftColor(context, shift);
      return;
    }
    _editShift(context, shift, isNewShift: false);
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
                  onTap: () => _editExistingShift(context, shift),
                  onLongPress:
                    shift.isStatic()
                      ? null
                      : settings.workShifts.length <=2
                        ? null
                        : () => _deleteShift(context, shift),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewShift(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}