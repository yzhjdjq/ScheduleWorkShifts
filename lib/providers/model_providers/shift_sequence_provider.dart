import 'package:flutter/material.dart' show ChangeNotifier, Color;
import 'package:sws/models/models.dart' show ShiftSequence;
import 'package:sws/providers/model_providers/model_providers.dart'
    show ScheduleItemViewModel, WorkShiftItemViewModel, WorkingTimeViewModel;
import 'package:sws/repositories/repositories.dart' show ShiftSequenceRepository;

class ShiftSequenceProvider with ChangeNotifier {
  static ShiftSequenceProvider? _instance;
  static ShiftSequenceProvider get instance {
    if (_instance == null) {
      throw Exception('ShiftSequenceProvider not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<ShiftSequenceProvider> initialize() async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = ShiftSequenceProvider._internal();
    await _instance!._loadDataFromRepository();
    return _instance!;
  }

  ShiftSequenceProvider._internal() {
    if (_instance != null) {
      throw Exception('ShiftSequenceProvider is already initialized.');
    }
  }

  static bool get isInitialized => _instance != null;

  static final ShiftSequenceRepository _shiftSequenceRepository = ShiftSequenceRepository();
  static List<ShiftSequence> _shiftSequences = [];

  Future<void> _loadDataFromRepository() async {
    _shiftSequences = await _shiftSequenceRepository.loadAll(defaultValue: _shiftSequences);
  }

  List<ShiftSequenceItemViewModel> get shiftSequences =>
      List<ShiftSequence>.unmodifiable(
        _shiftSequences,
      ).map((ss) => ShiftSequenceItemViewModel.fromShiftSequence(ss)).toList();

  bool hasShiftSequencesForSchedule(String scheduleId) => _shiftSequences.any((ss) => ss.scheduleId == scheduleId);

  List<ShiftSequenceItemViewModel> getShiftSequencesForSchedule(String scheduleId) {
    final List<ShiftSequence> sequences =
        _shiftSequences.where((seq) => seq.scheduleId == scheduleId).toList()
          ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return sequences.map((ss) => ShiftSequenceItemViewModel.fromShiftSequence(ss)).toList();
  }

  void addShiftSequence(ShiftSequenceItemViewModel newSequenceItem) {
    final newSequence = ShiftSequence(
      id: newSequenceItem.id,
      scheduleId: newSequenceItem.scheduleId,
      workShiftId: newSequenceItem.workShiftId,
      consecutiveDays: newSequenceItem.consecutiveDays,
      orderIndex: newSequenceItem.orderIndex,
      workingTime: newSequenceItem.workingTime.toWorkingTime(),
    );
    _shiftSequences.add(newSequence);
    _saveShiftSequences();
  }

  void updateShiftSequence(ShiftSequenceItemViewModel newSequenceItem) {
    final int index = _shiftSequences.indexWhere((sequence) => sequence.id == newSequenceItem.id);

    if (index != -1) {
      final newSequence = ShiftSequence(
        id: newSequenceItem.id,
        scheduleId: newSequenceItem.scheduleId,
        workShiftId: newSequenceItem.workShiftId,
        consecutiveDays: newSequenceItem.consecutiveDays,
        orderIndex: newSequenceItem.orderIndex,
        workingTime: newSequenceItem.workingTime.toWorkingTime(),
      );
      _shiftSequences[index] = newSequence;
      _saveShiftSequences();
    }
  }

  void removeShiftSequence(String id) {
    _shiftSequences.removeWhere((sequence) => sequence.id == id);
    _saveShiftSequences();
  }

  void removeSequencesForSchedule(String scheduleId) {
    _shiftSequences.removeWhere((seq) => seq.scheduleId == scheduleId);
    _saveShiftSequences();
  }

  void removeSequencesForShift(String shiftId) {
    _shiftSequences.removeWhere((seq) => seq.workShiftId == shiftId);
    _saveShiftSequences();
  }

  void _saveShiftSequences() {
    _shiftSequenceRepository.saveAll(_shiftSequences);
    notifyListeners();
  }

  List<Color> getColorsForSchedule(String scheduleId, List<WorkShiftItemViewModel> workShifts, DateTime forMonth) {
    final sequences = getShiftSequencesForSchedule(scheduleId);
    if (sequences.isEmpty) return [];

    final totalCycleDays = sequences.fold(0, (sum, seq) => sum + seq.consecutiveDays);
    if (totalCycleDays == 0) return [];

    final cycleColors = <Color>[];
    for (final sequence in sequences) {
      final workShift = workShifts.firstWhere(
        (shift) => shift.id == sequence.workShiftId,
        orElse: () => workShifts.isNotEmpty ? workShifts.first : WorkShiftItemViewModel.createDefault(),
      );

      for (int i = 0; i < sequence.consecutiveDays; i++) {
        cycleColors.add(workShift.color);
      }
    }

    return cycleColors;
  }

  int getTotalCycleDaysForSchedule(String scheduleId) {
    final sequences = getShiftSequencesForSchedule(scheduleId);
    return sequences.fold(0, (sum, seq) => sum + seq.consecutiveDays);
  }

  int getDayOffsetForSchedule(ScheduleItemViewModel schedule, DateTime day) {
    final firstDay = schedule.startDate;
    final difference = day.difference(firstDay).inDays;
    return difference;
  }

  bool get hasSequences => _shiftSequences.isNotEmpty;
}

class ShiftSequenceItemViewModel {
  final String id;
  final String scheduleId;
  final String workShiftId;
  final int consecutiveDays;
  final int orderIndex;
  final WorkingTimeViewModel workingTime;

  ShiftSequenceItemViewModel({
    required this.id,
    required this.scheduleId,
    required this.workShiftId,
    required this.consecutiveDays,
    required this.orderIndex,
    required this.workingTime,
  });

  static ShiftSequenceItemViewModel fromShiftSequence(ShiftSequence shiftSequence) {
    return ShiftSequenceItemViewModel(
      id: shiftSequence.id,
      scheduleId: shiftSequence.scheduleId,
      workShiftId: shiftSequence.workShiftId,
      consecutiveDays: shiftSequence.consecutiveDays,
      orderIndex: shiftSequence.orderIndex,
      workingTime: WorkingTimeViewModel.fromWorkingTime(shiftSequence.workingTime),
    );
  }

  ShiftSequenceItemViewModel copyWith({
    String? scheduleId,
    String? workShiftId,
    int? consecutiveDays,
    int? orderIndex,
    WorkingTimeViewModel? workingTime,
  }) {
    return ShiftSequenceItemViewModel(
      id: id,
      scheduleId: scheduleId ?? this.scheduleId,
      workShiftId: workShiftId ?? this.workShiftId,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      orderIndex: orderIndex ?? this.orderIndex,
      workingTime: workingTime ?? this.workingTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ShiftSequenceItemViewModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              scheduleId == other.scheduleId &&
              workShiftId == other.workShiftId &&
              consecutiveDays == other.consecutiveDays &&
              orderIndex == other.orderIndex &&
              workingTime == other.workingTime;

  @override
  int get hashCode => Object.hash(id, scheduleId, workShiftId, consecutiveDays, orderIndex, workingTime);
}
