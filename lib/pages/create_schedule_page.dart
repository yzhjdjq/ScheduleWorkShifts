import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sws/models/schedule.dart';
import 'package:sws/models/work_shift.dart';
import 'package:sws/providers/settings_provider.dart';
import 'package:sws/providers/schedule_provider.dart';
import 'package:sws/models/shift_sequence.dart';
import 'package:uuid/uuid.dart' show Uuid;

class CreateSchedulePage extends StatefulWidget {
  const CreateSchedulePage({super.key});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  Schedule? _selectedSchedule;
  DateTime? _firstWorkingDay;
  final List<ShiftRow> _shiftRows = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScheduleData();
    });
  }

  void _loadScheduleData() {
    final settings = context.read<SettingsProvider>();
    final scheduleProvider = context.read<ScheduleProvider>();

    // Устанавливаем первый график по умолчанию
    if (settings.schedules.isNotEmpty) {
      _selectedSchedule = settings.schedules.first;

      // Пытаемся загрузить сохраненные данные для выбранного графика
      final savedSequences =
          scheduleProvider.shiftSequences.where((seq) => seq.scheduleId == _selectedSchedule!.id).toList();

      if (savedSequences.isNotEmpty) {
        // Загружаем сохраненные данные
        _loadSavedSequences(savedSequences, settings);
      } else {
        // Используем настройки по умолчанию
        _loadDefaultSettings(settings);
      }
    } else {
      _loadDefaultSettings(settings);
    }
  }

  void _loadSavedSequences(List<ShiftSequence> sequences, SettingsProvider settings) {
    setState(() {
      _shiftRows.clear();

      // Сортируем последовательности по orderIndex
      sequences.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      // Устанавливаем первый рабочий день из первой последовательности
      _firstWorkingDay = sequences.first.startDate;

      // Заполняем строки сохраненными данными
      for (final sequence in sequences) {
        final row = ShiftRow();

        // Находим соответствующую смену
        final workShift = settings.workShifts.firstWhere(
          (shift) => shift.id == sequence.workShiftId,
          orElse: () => settings.workShifts.isNotEmpty ? settings.workShifts.first : WorkShift.createDefault(),
        );

        row.selectedShift = workShift;
        row.daysCount = sequence.consecutiveDays.toString();
        row.daysController.text = sequence.consecutiveDays.toString();

        _shiftRows.add(row);
      }
    });
  }

  void _loadDefaultSettings(SettingsProvider settings) {
    setState(() {
      _firstWorkingDay = _selectedSchedule?.startDate ?? DateTime.now();
      _shiftRows.clear();

      // Добавляем две строки по умолчанию
      for (int i = 0; i < 2; i++) {
        final row = ShiftRow();

        if (settings.workShifts.length > i) {
          row.selectedShift = settings.workShifts[i];
        } else if (settings.workShifts.isNotEmpty) {
          row.selectedShift = settings.workShifts.first;
        }

        row.daysCount = '1';
        row.daysController.text = '1';
        _shiftRows.add(row);
      }
    });
  }

  void _addShiftRow() {
    setState(() {
      _shiftRows.add(
        ShiftRow()
          ..daysCount = '1'
          ..daysController.text = '1',
      );
    });
  }

  void _removeShiftRow(int index) {
    if (_shiftRows.length > 2) {
      setState(() {
        _shiftRows.removeAt(index);
      });
    }
  }

  void _saveSchedule() async {
    if (_selectedSchedule == null || _firstWorkingDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заполните все обязательные поля')));
      return;
    }

    // Валидация всех строк
    for (int i = 0; i < _shiftRows.length; i++) {
      final row = _shiftRows[i];
      if (row.selectedShift == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Выберите смену в строке ${i + 1}')));
        return;
      }

      if (row.daysCount.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Введите количество дней в строке ${i + 1}')));
        return;
      }

      // Проверка валидности количества дней
      final days = int.tryParse(row.daysCount);
      if (days == null || days < 1 || days > 99) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Некорректное количество дней в строке ${i + 1} (1-99)')));
        return;
      }
    }

    // Сохранение в ScheduleProvider
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);

    // Удаляем старые последовательности для этого графика
    final oldSequences =
        scheduleProvider.shiftSequences.where((seq) => seq.scheduleId == _selectedSchedule!.id).toList();

    for (final sequence in oldSequences) {
      scheduleProvider.removeShiftSequence(sequence.id);
    }

    // Создаем новые последовательности смен
    for (int i = 0; i < _shiftRows.length; i++) {
      final row = _shiftRows[i];
      final days = int.parse(row.daysCount);

      final sequence = ShiftSequence(
        id: const Uuid().v4(),
        scheduleId: _selectedSchedule!.id,
        workShiftId: row.selectedShift!.id,
        consecutiveDays: days,
        orderIndex: i,
        startDate: _calculateStartDate(i),
        endDate: _calculateEndDate(i, days),
      );

      scheduleProvider.addShiftSequence(sequence);
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('График сохранен')));
  }

  DateTime _calculateStartDate(int orderIndex) {
    if (orderIndex == 0) return _firstWorkingDay!;

    // Вычисляем дату начала на основе предыдущих последовательностей
    DateTime startDate = _firstWorkingDay!;
    for (int i = 0; i < orderIndex; i++) {
      final row = _shiftRows[i];
      final days = int.parse(row.daysCount);
      startDate = startDate.add(Duration(days: days));
    }
    return startDate;
  }

  DateTime _calculateEndDate(int orderIndex, int days) {
    final startDate = _calculateStartDate(orderIndex);
    return startDate.add(Duration(days: days - 1));
  }

  void _onScheduleChanged(Schedule? newValue) {
    final settings = context.read<SettingsProvider>();
    final scheduleProvider = context.read<ScheduleProvider>();

    setState(() {
      _selectedSchedule = newValue;

      // Пытаемся загрузить сохраненные данные для нового графика
      final savedSequences = scheduleProvider.shiftSequences.where((seq) => seq.scheduleId == newValue?.id).toList();

      if (savedSequences.isNotEmpty) {
        // Загружаем сохраненные данные нового графика
        _loadSavedSequences(savedSequences, settings);
      } else {
        // Полный сброс к настройкам по умолчанию для нового графика
        _loadDefaultSettings(settings);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Создать график')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Выпадающий список графиков
            DropdownButtonFormField<Schedule>(
              decoration: const InputDecoration(labelText: 'График *', border: OutlineInputBorder()),
              value: _selectedSchedule,
              items:
                  settings.schedules.map((schedule) {
                    return DropdownMenuItem<Schedule>(value: schedule, child: Text(schedule.name));
                  }).toList(),
              onChanged: _onScheduleChanged,
            ),
            const SizedBox(height: 20),

            // Поле выбора даты
            GestureDetector(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _firstWorkingDay ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) {
                  setState(() {
                    _firstWorkingDay = selectedDate;
                  });
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Первый рабочий день *',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                    hintText:
                        _firstWorkingDay == null
                            ? 'Выберите дату'
                            : '${_firstWorkingDay!.day}.${_firstWorkingDay!.month}.${_firstWorkingDay!.year}',
                  ),
                  controller: TextEditingController(
                    text:
                        _firstWorkingDay == null
                            ? ''
                            : '${_firstWorkingDay!.day}.${_firstWorkingDay!.month}.${_firstWorkingDay!.year}',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Заголовок таблицы
            const Text('Последовательность смен:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Таблица смен
            Expanded(
              child:
                  _shiftRows.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(3), // Смена
                            1: FlexColumnWidth(1.5), // Кол-во дней
                            2: FlexColumnWidth(3), // Рабочее время
                            3: FixedColumnWidth(48), // Кнопка удаления (фиксированная ширина с отступами)
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: <TableRow>[
                            // Заголовок таблицы
                            TableRow(
                              decoration: BoxDecoration(color: Colors.grey.shade100),
                              children: [
                                _buildHeaderCell('Смена *'),
                                _buildHeaderCell('Кол-во дней *'),
                                _buildHeaderCell('Рабочее время'),
                                _buildHeaderCell(''),
                              ],
                            ),
                            // Строки с данными
                            ..._shiftRows.asMap().entries.map((entry) {
                              final index = entry.key;
                              final row = entry.value;

                              return TableRow(
                                children: <Widget>[
                                  _buildShiftCell(row, settings),
                                  _buildDaysCell(row, index),
                                  _buildTimeCell(row),
                                  _buildDeleteCell(index),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
            ),

            const SizedBox(height: 20),

            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить строку'),
                    onPressed: _addShiftRow,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Сохранить'),
                    onPressed: _saveSchedule,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildShiftCell(ShiftRow row, SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      child: DropdownButton<WorkShift>(
        isExpanded: true,
        value: row.selectedShift,
        hint: const Text('Выберите смену', style: TextStyle(fontSize: 14)),
        items:
            settings.workShifts.map((shift) {
              return DropdownMenuItem<WorkShift>(
                value: shift,
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: shift.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(shift.name, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              );
            }).toList(),
        onChanged: (WorkShift? newValue) {
          setState(() {
            row.selectedShift = newValue;
          });
        },
      ),
    );
  }

  Widget _buildDaysCell(ShiftRow row, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      child: TextField(
        maxLength: 2,
        textAlign: TextAlign.center,
        controller: row.daysController,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          counterText: '',
          hintText: '1',
          isDense: true,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            final number = int.tryParse(value);
            if (number == null || number < 1 || number > 99) {
              row.daysController.text = '1';
              row.daysCount = '1';
            } else {
              row.daysCount = value;
            }
          } else {
            row.daysCount = '1';
          }
        },
      ),
    );
  }

  Widget _buildTimeCell(ShiftRow row) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      child: WorkingTimeCell(
        workingTime: row.workingTime,
        onTimeChanged: (newTime) {
          setState(() {
            row.workingTime = newTime;
          });
        },
      ),
    );
  }

  Widget _buildDeleteCell(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child:
          (_shiftRows.length > 2)
              ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => _removeShiftRow(index),
              )
              : const SizedBox(width: 32, height: 32),
    );
  }
}

class ShiftRow {
  WorkShift? selectedShift;
  String daysCount = '1';
  final TextEditingController daysController = TextEditingController(text: '1');
  WorkingTime workingTime = WorkingTime();

  ShiftRow() {
    daysController.addListener(() {
      daysCount = daysController.text;
    });
  }
}

class WorkingTime {
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Duration? duration;

  WorkingTime();

  String getDisplayText(BuildContext context) {
    if (startTime != null && endTime != null) {
      return '${_formatTimeOfDay(startTime!, context)} - ${_formatTimeOfDay(endTime!, context)}';
    }
    return 'Выберите время';
  }

  // Форматирование TimeOfDay в строку
  String _formatTimeOfDay(TimeOfDay time, BuildContext context) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time, alwaysUse24HourFormat: true);
  }

  // Вычисление продолжительности
  void calculateDuration() {
    if (startTime != null && endTime != null) {
      final startMinutes = startTime!.hour * 60 + startTime!.minute;
      final endMinutes = endTime!.hour * 60 + endTime!.minute;

      int totalMinutes;
      if (endMinutes >= startMinutes) {
        totalMinutes = endMinutes - startMinutes;
      } else {
        totalMinutes = (24 * 60 - startMinutes) + endMinutes;
      }

      duration = Duration(minutes: totalMinutes);
    }
  }

  String get durationText {
    if (duration != null) {
      final hours = duration!.inHours;
      final minutes = duration!.inMinutes % 60;
      return '$hoursч $minutesм';
    }
    return '0ч 0м';
  }
}

/// Виджет ячейки рабочего времени для таблицы
class WorkingTimeCell extends StatelessWidget {
  final WorkingTime _workingTime;
  final Function(WorkingTime) _onTimeChanged;

  const WorkingTimeCell({super.key, required WorkingTime workingTime, required Function(WorkingTime) onTimeChanged})
    : _workingTime = workingTime,
      _onTimeChanged = onTimeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Компактное отображение выбранного времени
        _buildTimeSummary(context),
        const SizedBox(height: 4),

        // Кнопка для открытия диалога редактирования
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showWorkingTimeDialog(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            child: const Text('Настроить', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  /// Отображение сводки выбранного времени
  Widget _buildTimeSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_workingTime.startTime != null && _workingTime.endTime != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Время:', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                Text(
                  '${_formatTimeOfDay(_workingTime.startTime!, context)} - ${_formatTimeOfDay(_workingTime.endTime!, context)}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Длит:', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                Text(_workingTime.durationText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ] else ...[
            Text(
              'Время не настроено',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  /// Диалог для настройки рабочего времени
  void _showWorkingTimeDialog(BuildContext context) {
    WorkingTime tempWorkingTime =
        WorkingTime()
          ..startTime = _workingTime.startTime
          ..endTime = _workingTime.endTime
          ..duration = _workingTime.duration;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Настройка рабочего времени'),
            content: WorkingTimeEditor(
              workingTime: tempWorkingTime,
              onTimeChanged: (updatedTime) {
                tempWorkingTime = updatedTime;
              },
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
              TextButton(
                onPressed: () {
                  _workingTime.startTime = tempWorkingTime.startTime;
                  _workingTime.endTime = tempWorkingTime.endTime;
                  _workingTime.calculateDuration();
                  _onTimeChanged(_workingTime);
                  Navigator.pop(context);
                },
                child: const Text('Сохранить'),
              ),
            ],
          ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time, BuildContext context) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time, alwaysUse24HourFormat: true);
  }
}

/// Виджет редактора рабочего времени для диалога
class WorkingTimeEditor extends StatefulWidget {
  final WorkingTime workingTime;
  final Function(WorkingTime) onTimeChanged;

  const WorkingTimeEditor({super.key, required this.workingTime, required this.onTimeChanged});

  @override
  State<WorkingTimeEditor> createState() => _WorkingTimeEditorState();
}

class _WorkingTimeEditorState extends State<WorkingTimeEditor> {
  late WorkingTime _workingTime;

  @override
  void initState() {
    super.initState();
    _workingTime =
        WorkingTime()
          ..startTime = widget.workingTime.startTime
          ..endTime = widget.workingTime.endTime
          ..duration = widget.workingTime.duration;
  }

  Future<void> _selectStartTime() async {
    final selectedTime = await showTimePicker(context: context, initialTime: _workingTime.startTime ?? TimeOfDay.now());

    if (selectedTime != null) {
      setState(() {
        _workingTime.startTime = selectedTime;
        _workingTime.calculateDuration();
        widget.onTimeChanged(_workingTime);
      });
    }
  }

  Future<void> _selectEndTime() async {
    final selectedTime = await showTimePicker(context: context, initialTime: _workingTime.endTime ?? TimeOfDay.now());

    if (selectedTime != null) {
      setState(() {
        _workingTime.endTime = selectedTime;
        _workingTime.calculateDuration();
        widget.onTimeChanged(_workingTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Начало работы
          _buildTimeField(label: 'Начало работы', time: _workingTime.startTime, onTap: _selectStartTime),
          const SizedBox(height: 12),

          // Конец работы
          _buildTimeField(label: 'Конец работы', time: _workingTime.endTime, onTap: _selectEndTime),
          const SizedBox(height: 16),

          // Отображение продолжительности
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Общее рабочее время:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  _workingTime.durationText,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField({required String label, required TimeOfDay? time, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.access_time),
                hintText: time != null ? _formatTimeOfDay(time, context) : '--:--',
              ),
              controller: TextEditingController(text: time != null ? _formatTimeOfDay(time, context) : ''),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimeOfDay(TimeOfDay time, BuildContext context) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time, alwaysUse24HourFormat: true);
  }
}
