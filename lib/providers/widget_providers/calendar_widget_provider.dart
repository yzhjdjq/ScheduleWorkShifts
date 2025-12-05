import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart' show ChangeNotifier, Color, Colors;
import 'package:sws/services/services.dart' show WidgetService;
import 'package:sws/providers/model_providers/model_providers.dart'
    show
        ActiveSchedulesProvider,
        ScheduleExceptionProvider,
        ScheduleItemViewModel,
        ScheduleProvider,
        ShiftCategoryViewModel,
        ShiftNameLegendSettingProvider,
        ShiftNameSettingProvider,
        ShiftSequenceProvider,
        WorkShiftItemViewModel,
        WorkShiftProvider;

class CalendarWidgetProvider with ChangeNotifier {
  static CalendarWidgetProvider? _instance;
  static CalendarWidgetProvider get instance {
    if (_instance == null) {
      throw Exception('CalendarWidgetProvider not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<CalendarWidgetProvider> initialize({
    required ActiveSchedulesProvider activeSchedulesProvider,
    required ShiftNameLegendSettingProvider shiftNameLegendSettingProvider,
    required ShiftNameSettingProvider shiftNameSettingProvider,
    required ScheduleProvider scheduleProvider,
    required ShiftSequenceProvider shiftSequenceProvider,
    required ScheduleExceptionProvider scheduleExceptionProvider,
    required WorkShiftProvider workShiftProvider,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = CalendarWidgetProvider._(
      activeSchedulesProvider,
      shiftNameLegendSettingProvider,
      shiftNameSettingProvider,
      scheduleProvider,
      shiftSequenceProvider,
      scheduleExceptionProvider,
      workShiftProvider,
    );
    return _instance!;
  }

  CalendarWidgetProvider._(
    this._activeSchedulesProvider,
    this._shiftNameLegendSettingProvider,
    this._shiftNameSettingProvider,
    this._scheduleProvider,
    this._shiftSequenceProvider,
    this._scheduleExceptionProvider,
    this._workShiftProvider,
  ) {
    if (_instance != null) {
      throw Exception('CalendarWidgetProvider already initialized.');
    }

    _activeSchedulesProvider.addListener(notify);
    _shiftNameLegendSettingProvider.addListener(notify);
    _shiftNameSettingProvider.addListener(notify);
    _scheduleProvider.addListener(notify);
    _shiftSequenceProvider.addListener(notify);
    _scheduleExceptionProvider.addListener(notify);
    _workShiftProvider.addListener(notify);
  }

  static bool get isInitialized => _instance != null;

  late final ActiveSchedulesProvider _activeSchedulesProvider;
  late final ShiftNameLegendSettingProvider _shiftNameLegendSettingProvider;
  late final ShiftNameSettingProvider _shiftNameSettingProvider;
  late final ScheduleProvider _scheduleProvider;
  late final ShiftSequenceProvider _shiftSequenceProvider;
  late final ScheduleExceptionProvider _scheduleExceptionProvider;
  late final WorkShiftProvider _workShiftProvider;

  void notify() {
    notifyListeners();
    WidgetService.updateWidget();
  }

  ScheduleItemViewModel? get _activeSchedule {
    if (!_activeSchedulesProvider.hasActiveSchedule) {
      return null;
    }

    final activeScheduleId = _activeSchedulesProvider.activeScheduleId!;

    if (!_scheduleProvider.hasSchedule(activeScheduleId)) {
      final firstSchedule = _scheduleProvider.schedules.firstOrNull;

      if (firstSchedule != null && _shiftSequenceProvider.hasShiftSequencesForSchedule(firstSchedule.id)) {
        _activeSchedulesProvider.setActiveScheduleId(firstSchedule.id);
      }

      return firstSchedule;
    }

    if (_shiftSequenceProvider.hasShiftSequencesForSchedule(activeScheduleId)) {
      return _scheduleProvider.getScheduleById(activeScheduleId);
    }

    return null;
  }

  bool get isComparisonMode => _comparedSchedules.length == 2;

  bool get isSimpleMode => _activeSchedule == null && _comparedSchedules.isEmpty;

  List<ScheduleItemViewModel> get _comparedSchedules {
    if (!_activeSchedulesProvider.hasComparedSchedule) return [];
    if (_activeSchedule == null) return [];

    final comparedScheduleId = _activeSchedulesProvider.comparedScheduleId!;

    if (_scheduleProvider.hasSchedule(comparedScheduleId)) {
      return [_activeSchedule!, _scheduleProvider.getScheduleById(comparedScheduleId)];
    }

    return [_activeSchedule!];
  }

  List<WorkShiftItemViewModel> get _workShifts => _workShiftProvider.workShifts;

  (List<Color>, List<Color>) _getColorsForComparison(DateTime date) {
    if (_comparedSchedules.isEmpty) {
      return ([], []);
    }
    final comparedScheduleIds = _comparedSchedules.map((e) => e.id).toList();
    final firstColors = _shiftSequenceProvider.getColorsForSchedule(comparedScheduleIds[0], _workShifts, date);
    final secondColors = _shiftSequenceProvider.getColorsForSchedule(comparedScheduleIds[1], _workShifts, date);

    return (firstColors, secondColors);
  }

  Color _getColorWithExceptions(DateTime date, String scheduleId, List<Color> periodicColors, int dayOffset) {
    if (_scheduleExceptionProvider.hasExceptionForDate(date, scheduleId)) {
      final exception = _scheduleExceptionProvider.getExceptionForDate(date, scheduleId);
      final workShift = _workShiftProvider.allWorkShifts.firstWhere(
        (shift) => shift.id == exception!.workShiftId,
        orElse: () => WorkShiftItemViewModel.createDefault(),
      );
      return workShift.color;
    }

    if (dayOffset < 0) {
      return Colors.grey.withValues(alpha: 0.3);
    }

    if (periodicColors.isEmpty) {
      return Colors.grey.withAlpha(77);
    }

    final int colorIndex = dayOffset % periodicColors.length;
    return periodicColors[colorIndex];
  }

  (Color, Color) getComparisonColorsForDate(DateTime date) {
    if (!isComparisonMode) {
      return (Colors.grey, Colors.grey);
    }

    final (firstColors, secondColors) = _getColorsForComparison(date);

    final firstOffset = _shiftSequenceProvider.getDayOffsetForSchedule(_comparedSchedules[0], date);
    final secondOffset = _shiftSequenceProvider.getDayOffsetForSchedule(_comparedSchedules[1], date);

    Color firstColor = _getColorWithExceptions(date, _comparedSchedules[0].id, firstColors, firstOffset);
    Color secondColor = _getColorWithExceptions(date, _comparedSchedules[1].id, secondColors, secondOffset);

    return (firstColor, secondColor);
  }

  bool isToday(int day, DateTime currentDate) {
    final now = DateTime.now();
    return day == now.day && currentDate.month == now.month && currentDate.year == now.year;
  }

  int _getDayOffsetForActiveSchedule(DateTime day) {
    final activeSchedule = _activeSchedule;
    if (activeSchedule == null) return -1;
    return _shiftSequenceProvider.getDayOffsetForSchedule(activeSchedule, day);
  }

  int _getTotalCycleDaysForActiveSchedule() {
    final activeSchedule = _activeSchedule;
    if (activeSchedule == null) return 0;
    return _shiftSequenceProvider.getTotalCycleDaysForSchedule(activeSchedule.id);
  }

  bool _hasExceptionForDate(DateTime day) {
    final activeSchedule = _activeSchedule;
    if (activeSchedule == null) return false;
    return _scheduleExceptionProvider.hasExceptionForDate(day, activeSchedule.id);
  }

  (Color?, WorkShiftItemViewModel?) getCellColorAndWorkShiftNameByActiveScheduleMode({
    required DateTime currentDay,
    (Color?, WorkShiftItemViewModel?) defaultValue = (
      const Color(0x4D757575),
      const WorkShiftItemViewModel(id: '', name: '', color: Color(0xFF000000), category: ShiftCategoryViewModel.dayOff),
    ),
  }) {
    final dayOffset = _getDayOffsetForActiveSchedule(currentDay);
    final bool hasValidCycle = _getTotalCycleDaysForActiveSchedule() > 0;
    final bool isWithinCycle = dayOffset >= 0;
    final activeSchedule = _activeSchedule;

    if (_hasExceptionForDate(currentDay) && activeSchedule != null) {
      final exception = _scheduleExceptionProvider.getExceptionForDate(currentDay, activeSchedule.id)!;
      final workShift = _workShiftProvider.allWorkShifts.firstWhere(
        (s) => s.id == exception.workShiftId,
        orElse: () => WorkShiftItemViewModel.createDefault(),
      );
      return (workShift.color, workShift);
    } else if (hasValidCycle && isWithinCycle && activeSchedule != null) {
      final periodicColors = _shiftSequenceProvider.getColorsForSchedule(
        activeSchedule.id,
        _workShiftProvider.workShifts,
        currentDay,
      );
      final colorIndex = dayOffset % periodicColors.length;
      final Color cellColor = periodicColors[colorIndex];

      final cyclePosition = dayOffset % _getTotalCycleDaysForActiveSchedule();
      final sequences =
          _shiftSequenceProvider.shiftSequences.where((seq) => seq.scheduleId == activeSchedule.id).toList()
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      int currentDayIndex = 0;
      for (final sequence in sequences) {
        if (cyclePosition < currentDayIndex + sequence.consecutiveDays) {
          final workShift = _workShiftProvider.allWorkShifts.firstWhere(
            (s) => s.id == sequence.workShiftId,
            orElse: () => WorkShiftItemViewModel.createDefault(),
          );
          return (cellColor, workShift);
        }
        currentDayIndex += sequence.consecutiveDays;
      }
    }
    return defaultValue;
  }

  bool showShiftName() => _shiftNameSettingProvider.showShiftName;
}
