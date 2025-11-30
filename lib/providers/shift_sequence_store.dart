import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart' show ChangeNotifier, Color;
import 'package:sws/models/shift_sequence.dart' show ShiftSequence;
import 'package:sws/models/work_shift.dart' show WorkShift;
import 'package:sws/providers/schedule_store.dart' show ScheduleStore;
import 'package:sws/services/storage_service.dart' show StorageService;

class ShiftSequenceStore with ChangeNotifier {
  static ShiftSequenceStore? _instance;
  static ShiftSequenceStore get instance {
    if (_instance == null) {
      throw Exception('ShiftSequenceStore not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<ShiftSequenceStore> initialize({required ScheduleStore scheduleStore}) async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = ShiftSequenceStore._(scheduleStore);
    await _instance!._loadFromStorage();
    return _instance!;
  }

  ShiftSequenceStore._(this._scheduleStore) {
    if (_instance != null) {
      throw Exception('ShiftSequenceStore is already initialized.');
    }
  }

  static bool get isInitialized => _instance != null;

  late final ScheduleStore _scheduleStore;

  static const String _shiftSequenceKey = 'shiftSequence';
  static const String _activeScheduleIdKey = 'activeScheduleId';
  static List<ShiftSequence> _shiftSequences = [];
  static String? _activeScheduleId;

  Future<void> _loadFromStorage() async {
    if (!StorageService.containsKey(_shiftSequenceKey)) {
      await StorageService.setObject(_shiftSequenceKey, _shiftSequences);
    }

    _shiftSequences =
        StorageService.getObjectList<ShiftSequence>(_shiftSequenceKey, fromJson: ShiftSequence.fromJson) ?? [];

    _activeScheduleId = StorageService.getString(_activeScheduleIdKey);
  }

  List<ShiftSequence> get shiftSequences => List<ShiftSequence>.unmodifiable(_shiftSequences);

  List<ShiftSequence> getSequencesForSchedule(String scheduleId) {
    return _shiftSequences.where((seq) => seq.scheduleId == scheduleId).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  void addShiftSequence(ShiftSequence newSequence) {
    _shiftSequences.add(newSequence);
    _saveShiftSequences();
  }

  void updateShiftSequence(String id, ShiftSequence newSequence) {
    final int index = _shiftSequences.indexWhere((sequence) => sequence.id == id);
    if (index != -1) {
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
    StorageService.setObject(_shiftSequenceKey, _shiftSequences);
    notifyListeners();
  }

  void setActiveSchedule(String scheduleId) {
    _activeScheduleId = scheduleId;
    StorageService.setString(_activeScheduleIdKey, scheduleId);
    notifyListeners();
  }

  String? getActiveScheduleId() {
    if (_activeScheduleId != null) {
      final hasSequences = _shiftSequences.any((seq) => seq.scheduleId == _activeScheduleId);
      if (hasSequences) {
        return _activeScheduleId;
      }
    }

    if (_shiftSequences.isNotEmpty) {
      final firstScheduleId = _shiftSequences.first.scheduleId;
      _activeScheduleId = firstScheduleId;
      StorageService.setString(_activeScheduleIdKey, firstScheduleId);
      return firstScheduleId;
    }

    return null;
  }

  bool isScheduleActive(String scheduleId) => getActiveScheduleId() == scheduleId;

  List<Color> getColorsForSchedule(String scheduleId, List<WorkShift> workShifts, DateTime forMonth) {
    final sequences = getSequencesForSchedule(scheduleId);
    if (sequences.isEmpty) return [];

    final totalCycleDays = sequences.fold(0, (sum, seq) => sum + seq.consecutiveDays);
    if (totalCycleDays == 0) return [];

    final cycleColors = <Color>[];
    for (final sequence in sequences) {
      final workShift = workShifts.firstWhere(
        (shift) => shift.id == sequence.workShiftId,
        orElse: () => workShifts.isNotEmpty ? workShifts.first : WorkShift.createDefault(),
      );

      for (int i = 0; i < sequence.consecutiveDays; i++) {
        cycleColors.add(workShift.color);
      }
    }

    return cycleColors;
  }

  int getDayOffsetForSchedule(String scheduleId, DateTime day) {
    final firstDay = getFirstDayOfSchedule(scheduleId);
    if (firstDay == null) return day.day - 1;

    final difference = day.difference(firstDay).inDays;
    return difference;
  }

  DateTime? getFirstDayOfSchedule(String scheduleId) {
    final schedule = _scheduleStore.schedules.firstWhereOrNull((s) => s.id == scheduleId);
    return schedule?.startDate;
  }

  int getTotalCycleDaysForSchedule(String scheduleId) {
    final sequences = getSequencesForSchedule(scheduleId);
    return sequences.fold(0, (sum, seq) => sum + seq.consecutiveDays);
  }

  bool get hasSchedules => _shiftSequences.isNotEmpty;
}
