import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider, ReadContext;
import 'package:sws/models/models.dart' show Schedule, ShiftSequence, WorkShift, WorkingTime;
import 'package:sws/providers/providers.dart' show ScheduleProvider;
import 'package:sws/widgets/widgets.dart'
    show
        CreateScheduleActionsWidget,
        FirstDayPickerWidget,
        ScheduleSelectorWidget,
        ShiftSequenceListWidget,
        ShiftRowData;
import 'package:uuid/uuid.dart' show Uuid;

class CreateSchedulePage extends StatefulWidget {
  const CreateSchedulePage({super.key});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  Schedule? _selectedSchedule;
  DateTime? _firstWorkingDay;
  final List<ShiftRowData> _rows = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadScheduleData());
  }

  void _loadScheduleData() {
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);

    if (scheduleProvider.schedules.isNotEmpty) {
      final activeId = scheduleProvider.getActiveScheduleId() ?? '';
      _selectedSchedule = scheduleProvider.schedules.firstWhere(
        (s) => s.id == activeId,
        orElse: () => scheduleProvider.schedules.first,
      );
      _firstWorkingDay = _selectedSchedule!.startDate;

      final sequences =
          scheduleProvider.shiftSequences.where((s) => s.scheduleId == _selectedSchedule!.id).toList()
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      if (sequences.isNotEmpty) {
        _loadSequences(sequences, scheduleProvider);
      } else {
        _loadDefaults(scheduleProvider);
      }
    } else {
      _loadDefaults(scheduleProvider);
    }
  }

  void _loadSequences(List<ShiftSequence> sequences, ScheduleProvider provider) {
    setState(() {
      _rows.clear();

      for (final seq in sequences) {
        final workShift = provider.workShifts.firstWhere(
          (s) => s.id == seq.workShiftId,
          orElse: () => provider.workShifts.first,
        );

        _rows.add(
          ShiftRowData(
            selectedShift: workShift,
            daysCount: seq.consecutiveDays.toString(),
            workingTime: seq.workingTime,
          ),
        );
      }
    });
  }

  void _loadDefaults(ScheduleProvider provider) {
    setState(() {
      _firstWorkingDay = _selectedSchedule?.startDate ?? DateTime.now();
      _rows.clear();

      for (int i = 0; i < 2; i++) {
        _rows.add(
          ShiftRowData(
            selectedShift: i < provider.workShifts.length ? provider.workShifts[i] : provider.workShifts.firstOrNull,
            daysCount: '1',
            workingTime: const WorkingTime(),
          ),
        );
      }
    });
  }

  void _addRow() => setState(() => _rows.add(ShiftRowData(daysCount: '1', workingTime: const WorkingTime())));

  void _removeRow() {
    if (_rows.length > 2) {
      _rows.last.dispose();
      setState(() => _rows.removeLast());
    }
  }

  void _saveSchedule() {
    if (_selectedSchedule == null || _firstWorkingDay == null) {
      _showError('Заполните все обязательные поля');
      return;
    }

    for (int i = 0; i < _rows.length; i++) {
      final row = _rows[i];
      if (row.selectedShift == null) {
        _showError('Выберите смену в строке ${i + 1}');
        return;
      }
      final days = int.tryParse(row.daysCount);
      if (days == null || days < 1 || days > 99) {
        _showError('Некорректное количество дней в строке ${i + 1}');
        return;
      }
    }

    final provider = Provider.of<ScheduleProvider>(context, listen: false);

    provider.updateSchedule(_selectedSchedule!.copyWith(startDate: _firstWorkingDay));

    // Удаляем старые
    final old = provider.shiftSequences.where((s) => s.scheduleId == _selectedSchedule!.id);
    for (final s in old) {
      provider.removeShiftSequence(s.id);
    }

    // Добавляем новые
    for (int i = 0; i < _rows.length; i++) {
      final row = _rows[i];
      final days = int.parse(row.daysCount);

      final seq = ShiftSequence(
        id: const Uuid().v4(),
        scheduleId: _selectedSchedule!.id,
        workShiftId: row.selectedShift!.id,
        consecutiveDays: days,
        orderIndex: i,
        workingTime: row.workingTime,
      );

      provider.addShiftSequence(seq);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('График сохранён'),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15), bottom: Radius.circular(15)),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15), bottom: Radius.circular(15)),
        ),
      ),
    );
  }

  void _onScheduleChanged(Schedule? newValue) {
    final scheduleProvider = context.read<ScheduleProvider>();

    setState(() {
      _selectedSchedule = newValue;
      _firstWorkingDay = newValue?.startDate;

      final savedSequences = scheduleProvider.shiftSequences.where((seq) => seq.scheduleId == newValue?.id).toList();

      if (savedSequences.isNotEmpty) {
        _loadSequences(savedSequences, scheduleProvider);
      } else {
        _loadDefaults(scheduleProvider);
      }
    });
  }

  void _onShiftChanged(WorkShift? newValue, int index) {
    setState(() {
      _rows[index].selectedShift = newValue;
    });
  }

  void _onDaysChanged(String newValue, int index) {
    setState(() {
      _rows[index].daysCount = newValue;
    });
  }

  void _onTimeChanged(WorkingTime newValue, int index) {
    setState(() {
      _rows[index].workingTime = newValue;
    });
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScheduleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Создать график')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScheduleSelectorWidget(
              schedules: provider.schedules,
              selectedSchedule: _selectedSchedule,
              onChanged: _onScheduleChanged,
            ),
            const SizedBox(height: 20),
            FirstDayPickerWidget(
              firstWorkingDay: _firstWorkingDay,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _firstWorkingDay ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() => _firstWorkingDay = date);
                }
              },
            ),
            const SizedBox(height: 20),
            ShiftSequenceListWidget(
              rows: _rows,
              availableShifts: provider.workShifts,
              onShiftChanged: _onShiftChanged,
              onDaysChanged: _onDaysChanged,
              onTimeChanged: _onTimeChanged,
              onAdd: _addRow,
              onRemove: _removeRow,
            ),
            const SizedBox(height: 20),
            CreateScheduleActionsWidget(onAddShift: _addRow, onSave: _saveSchedule),
          ],
        ),
      ),
    );
  }
}
