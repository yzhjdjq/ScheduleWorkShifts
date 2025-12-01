import 'package:flutter/material.dart' show ChangeNotifier, Color, Colors;
import 'package:sws/models/models.dart' show Schedule, ScheduleException, ShiftSequence, WorkShift;
import 'package:sws/providers/base_provider_mixin.dart' show BaseProviderMixin;
import 'package:sws/providers/stores/stores.dart'
    show ScheduleExceptionStore, ScheduleStore, ShiftSequenceStore, WorkShiftStore;
import 'package:sws/services/services.dart' show StorageService, WidgetService;
import 'package:uuid/uuid.dart' show Uuid;

mixin _ComparedScheduleMixin on BaseProviderMixin {
  static const String _comparedSchedulesKey = 'comparedSchedules';
  static List<String> _comparedScheduleIds = [];
  static bool _isComparisonMode = false;

  Future<void> _loadComparisonSettingsFromStorage() async {
    if (!StorageService.containsKey(_comparedSchedulesKey)) {
      await StorageService.setObject(_comparedSchedulesKey, _comparedScheduleIds);
    }

    _comparedScheduleIds = StorageService.getObjectList<String>(_comparedSchedulesKey) ?? [];
    _isComparisonMode = _comparedScheduleIds.length == 2;
  }

  List<String> get comparedScheduleIds => List<String>.unmodifiable(_comparedScheduleIds);
  bool get isComparisonMode => _isComparisonMode;

  void enableComparisonMode(String firstScheduleId, String secondScheduleId) {
    _comparedScheduleIds = [firstScheduleId, secondScheduleId];
    _isComparisonMode = true;
    StorageService.setObject(_comparedSchedulesKey, _comparedScheduleIds);
    notify();
  }

  ShiftSequenceStore _getShiftSequenceStore();

  ScheduleExceptionStore _getScheduleExceptionStore();

  WorkShiftStore _getWorkShiftStore();

  void disableComparisonMode() {
    _comparedScheduleIds = [];
    _isComparisonMode = false;
    StorageService.setObject(_comparedSchedulesKey, _comparedScheduleIds);
    notify();
  }

  List<List<Color>> getColorsForComparison(List<WorkShift> workShifts, DateTime forMonth) {
    if (!_isComparisonMode || _comparedScheduleIds.length != 2) {
      return [[], []];
    }

    final ShiftSequenceStore shiftSequences = _getShiftSequenceStore();

    final firstColors = shiftSequences.getColorsForSchedule(_comparedScheduleIds[0], workShifts, forMonth);
    final secondColors = shiftSequences.getColorsForSchedule(_comparedScheduleIds[1], workShifts, forMonth);

    return [firstColors, secondColors];
  }

  List<Color> getComparisonColorsForDate(DateTime date, List<WorkShift> workShifts) {
    if (!_isComparisonMode || _comparedScheduleIds.length != 2) {
      return [Colors.grey, Colors.grey];
    }

    final ShiftSequenceStore shiftSequences = _getShiftSequenceStore();

    final firstColors = shiftSequences.getColorsForSchedule(_comparedScheduleIds[0], workShifts, date);
    final secondColors = shiftSequences.getColorsForSchedule(_comparedScheduleIds[1], workShifts, date);

    final firstOffset = shiftSequences.getDayOffsetForSchedule(_comparedScheduleIds[0], date);
    final secondOffset = shiftSequences.getDayOffsetForSchedule(_comparedScheduleIds[1], date);

    Color firstColor = _getColorWithExceptions(date, _comparedScheduleIds[0], firstColors, firstOffset);
    Color secondColor = _getColorWithExceptions(date, _comparedScheduleIds[1], secondColors, secondOffset);

    return [firstColor, secondColor];
  }

  Color _getColorWithExceptions(DateTime date, String scheduleId, List<Color> periodicColors, int dayOffset) {
    final ScheduleExceptionStore exceptionStore = _getScheduleExceptionStore();
    final WorkShiftStore workShiftStore = _getWorkShiftStore();

    if (exceptionStore.hasExceptionForDate(date, scheduleId)) {
      final exception = exceptionStore.getExceptionForDate(date, scheduleId);
      final workShift = workShiftStore.allWorkShifts.firstWhere(
        (shift) => shift.id == exception!.workShiftId,
        orElse: () => WorkShift.createDefault(),
      );
      return workShift.color;
    }

    if (dayOffset < 0) {
      return Colors.grey.withValues(alpha: 0.3);
    }

    if (periodicColors.isEmpty) {
      return Colors.grey;
    }

    final int colorIndex = dayOffset % periodicColors.length;
    return periodicColors[colorIndex];
  }

  List<int> getDayOffsetsForComparison(DateTime day) {
    if (!_isComparisonMode || _comparedScheduleIds.length != 2) {
      return [0, 0];
    }

    final ShiftSequenceStore shiftSequences = _getShiftSequenceStore();

    final firstOffset = shiftSequences.getDayOffsetForSchedule(_comparedScheduleIds[0], day);
    final secondOffset = shiftSequences.getDayOffsetForSchedule(_comparedScheduleIds[1], day);

    return [firstOffset, secondOffset];
  }
}

class ScheduleProvider extends BaseProviderMixin with ChangeNotifier, _ComparedScheduleMixin {
  static ScheduleProvider? _instance;
  static ScheduleProvider get instance {
    if (_instance == null) {
      throw Exception('ScheduleProvider not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<ScheduleProvider> initialize({
    required ScheduleStore scheduleStore,
    required WorkShiftStore workShiftStore,
    required ShiftSequenceStore shiftSequenceStore,
    required ScheduleExceptionStore scheduleExceptionStore,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = ScheduleProvider._(scheduleStore, workShiftStore, shiftSequenceStore, scheduleExceptionStore);
    await _instance!._loadFromStorage();
    return _instance!;
  }

  ScheduleProvider._(
    this._scheduleStore,
    this._workShiftStore,
    this._shiftSequenceStore,
    this._scheduleExceptionStore,
  ) {
    if (_instance != null) {
      throw Exception('ScheduleProvider already initialized.');
    }

    _scheduleStore.addListener(notify);
    _workShiftStore.addListener(notify);
    _shiftSequenceStore.addListener(notify);
    _scheduleExceptionStore.addListener(notify);
  }

  static bool get isInitialized => _instance != null;

  late final ScheduleStore _scheduleStore;
  late final WorkShiftStore _workShiftStore;
  late final ShiftSequenceStore _shiftSequenceStore;
  late final ScheduleExceptionStore _scheduleExceptionStore;

  @override
  ShiftSequenceStore _getShiftSequenceStore() => _shiftSequenceStore;

  @override
  ScheduleExceptionStore _getScheduleExceptionStore() => _scheduleExceptionStore;

  @override
  WorkShiftStore _getWorkShiftStore() => _workShiftStore;

  @override
  void notify() {
    notifyListeners();
    WidgetService.updateWidget();
  }

  Future<void> _loadFromStorage() async {
    await _loadComparisonSettingsFromStorage();
  }

  List<Color> getColorsForActiveSchedule(List<WorkShift> workShifts, DateTime forMonth) {
    final activeScheduleId = _shiftSequenceStore.getActiveScheduleId();
    if (activeScheduleId == null) return [];

    return _shiftSequenceStore.getColorsForSchedule(activeScheduleId, workShifts, forMonth);
  }

  int getDayOffsetForActiveSchedule(DateTime day) {
    final activeScheduleId = _shiftSequenceStore.getActiveScheduleId();
    if (activeScheduleId == null) return -1;

    return _shiftSequenceStore.getDayOffsetForSchedule(activeScheduleId, day);
  }

  int getTotalCycleDaysForActiveSchedule() {
    final activeScheduleId = _shiftSequenceStore.getActiveScheduleId();
    if (activeScheduleId == null) return 0;

    return _shiftSequenceStore.getTotalCycleDaysForSchedule(activeScheduleId);
  }

  void addVacation(String scheduleId, DateTime startDate, DateTime endDate) {
    final exception = ScheduleException(
      id: const Uuid().v4(),
      scheduleId: scheduleId,
      workShiftId: 'vacation',
      startDate: startDate,
      endDate: endDate,
    );
    _scheduleExceptionStore.addScheduleException(exception);
  }

  void addSickLeave(String scheduleId, DateTime startDate, DateTime endDate) {
    final exception = ScheduleException(
      id: const Uuid().v4(),
      scheduleId: scheduleId,
      workShiftId: 'sickLeave',
      startDate: startDate,
      endDate: endDate,
    );
    _scheduleExceptionStore.addScheduleException(exception);
  }

  void updateSchedule(Schedule schedule) => _scheduleStore.updateSchedule(schedule);

  String? getActiveScheduleId() => _shiftSequenceStore.getActiveScheduleId();

  bool get hasSchedules => _shiftSequenceStore.hasSchedules;

  List<WorkShift> get workShifts => _workShiftStore.workShifts;

  List<WorkShift> get allWorkShifts => _workShiftStore.allWorkShifts;

  List<Color> getColorsForSchedule(String scheduleId, List<WorkShift> workShifts, DateTime forMonth) =>
      _shiftSequenceStore.getColorsForSchedule(scheduleId, workShifts, forMonth);

  List<ShiftSequence> get shiftSequences => _shiftSequenceStore.shiftSequences;

  void setActiveSchedule(String scheduleId) => _shiftSequenceStore.setActiveSchedule(scheduleId);

  bool isScheduleActive(String scheduleId) => _shiftSequenceStore.isScheduleActive(scheduleId);

  void addShiftSequence(ShiftSequence newSequence) => _shiftSequenceStore.addShiftSequence(newSequence);

  int getTotalCycleDaysForSchedule(String scheduleId) => _shiftSequenceStore.getTotalCycleDaysForSchedule(scheduleId);

  void removeShiftSequence(String id) => _shiftSequenceStore.removeShiftSequence(id);

  List<Schedule> get schedules => _scheduleStore.schedules;

  int getDayOffsetForSchedule(String scheduleId, DateTime day) =>
      _shiftSequenceStore.getDayOffsetForSchedule(scheduleId, day);

  void addScheduleException(ScheduleException exception) => _scheduleExceptionStore.addScheduleException(exception);

  ScheduleException? getExceptionForDate(DateTime date, String scheduleId) =>
      _scheduleExceptionStore.getExceptionForDate(date, scheduleId);

  bool hasExceptionForDate(DateTime date, String scheduleId) =>
      _scheduleExceptionStore.hasExceptionForDate(date, scheduleId);

  void removeScheduleException(String scheduleId) => _scheduleExceptionStore.removeScheduleException(scheduleId);
}
