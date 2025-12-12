import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext, WatchContext;
import 'package:sws/providers/providers.dart'
    show
        CreateSchedulePageProvider,
        ScheduleItemViewModel,
        ShiftSequenceItemViewModel,
        SnackBarMessageProvider,
        WorkShiftItemViewModel,
        WorkingTimeViewModel;
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
  ScheduleItemViewModel? _selectedSchedule;
  DateTime? _firstWorkingDay;
  final List<ShiftRowData> _rows = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadScheduleData());
  }

  void _loadScheduleData() {
    final pageProvider = context.read<CreateSchedulePageProvider>();

    if (pageProvider.hasSchedules()) {
      _selectedSchedule = pageProvider.getActiveSchedule();
      _firstWorkingDay = _selectedSchedule?.startDate;

      final sequences = pageProvider.getShiftSequencesForSchedule(_selectedSchedule);

      if (sequences.isNotEmpty) {
        _loadSequences(sequences);
      } else {
        _loadDefaults();
      }
    } else {
      _loadDefaults();
    }
  }

  void _loadSequences(List<ShiftSequenceItemViewModel> sequences) {
    final pageProvider = context.read<CreateSchedulePageProvider>();
    setState(() {
      _rows.clear();

      for (final seq in sequences) {
        final workShift = pageProvider.getWorkShiftFromScheduleSequence(seq);
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

  void _loadDefaults() {
    final pageProvider = context.read<CreateSchedulePageProvider>();
    setState(() {
      _firstWorkingDay = _selectedSchedule?.startDate ?? DateTime.now();
      _rows.clear();

      for (int i = 0; i < 2; i++) {
        _rows.add(
          ShiftRowData(
            selectedShift:
                i < pageProvider.workShifts.length ? pageProvider.workShifts[i] : pageProvider.workShifts.firstOrNull,
            daysCount: '1',
            workingTime: const WorkingTimeViewModel(),
          ),
        );
      }
    });
  }

  void _addRow() => setState(() => _rows.add(ShiftRowData(daysCount: '1', workingTime: const WorkingTimeViewModel())));

  void _removeRow(int rowIndex) {
    if (_rows.length > 2) {
      _rows[rowIndex].dispose();
      setState(() => _rows.removeAt(rowIndex));
    }
  }

  void _saveSchedule() {
    if (_selectedSchedule == null || _firstWorkingDay == null) {
      context.read<SnackBarMessageProvider>().showError('Заполните все обязательные* поля');
      return;
    }

    for (int i = 0; i < _rows.length; i++) {
      final row = _rows[i];
      if (row.selectedShift == null) {
        context.read<SnackBarMessageProvider>().showError('Выберите смену в строке ${i + 1}');
        return;
      }
      final days = int.tryParse(row.daysCount);
      if (days == null || days < 1 || days > 99) {
        context.read<SnackBarMessageProvider>().showError('Некорректное количество дней в строке ${i + 1}');
        return;
      }
    }

    final pageProvider = context.read<CreateSchedulePageProvider>();

    pageProvider.updateSchedule(_selectedSchedule!.copyWith(startDate: _firstWorkingDay));

    final old = pageProvider.shiftSequences.where((s) => s.scheduleId == _selectedSchedule!.id);
    for (final s in old) {
      pageProvider.removeShiftSequence(s.id);
    }

    for (int i = 0; i < _rows.length; i++) {
      final row = _rows[i];
      final days = int.parse(row.daysCount);

      final seq = ShiftSequenceItemViewModel(
        id: const Uuid().v4(),
        scheduleId: _selectedSchedule!.id,
        workShiftId: row.selectedShift!.id,
        consecutiveDays: days,
        orderIndex: i,
        workingTime: row.workingTime,
      );

      pageProvider.addShiftSequence(seq);
    }

    context.read<SnackBarMessageProvider>().showSuccess('График сохранён');
  }

  void _onScheduleChanged(String newValue) {
    final pageProvider = context.read<CreateSchedulePageProvider>();

    setState(() {
      _selectedSchedule = pageProvider.getScheduleById(newValue);
      _firstWorkingDay = _selectedSchedule?.startDate;
    });
    final savedSequences = pageProvider.getShiftSequencesForSchedule(_selectedSchedule);

    if (savedSequences.isNotEmpty) {
      _loadSequences(savedSequences);
    } else {
      _loadDefaults();
    }
  }

  void _onShiftChanged(WorkShiftItemViewModel? newValue, int index) {
    setState(() {
      _rows[index].selectedShift = newValue;
    });
  }

  void _onDaysChanged(String newValue, int index) {
    setState(() {
      _rows[index].daysCount = newValue;
    });
  }

  void _onTimeChanged(WorkingTimeViewModel newValue, int index) {
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
    final pageProvider = context.watch<CreateSchedulePageProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Создать график')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScheduleSelectorWidget(
              schedules: pageProvider.schedules,
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
              availableShifts: pageProvider.workShifts,
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
