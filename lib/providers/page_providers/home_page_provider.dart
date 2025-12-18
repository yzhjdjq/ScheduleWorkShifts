import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart' show ChangeNotifier, Color;
import 'package:sws/services/services.dart' show WidgetService;
import 'package:sws/providers/model_providers/model_providers.dart'
    show
        ActiveSchedulesProvider,
        ScheduleExceptionItemViewModel,
        ScheduleExceptionProvider,
        ScheduleItemViewModel,
        ScheduleProvider,
        ShiftNameLegendSettingProvider,
        ShiftNameSettingProvider,
        ShiftSequenceProvider,
        WorkShiftItemViewModel,
        WorkShiftProvider,
        WorkingTimeViewModel;
import 'package:uuid/uuid.dart' show Uuid;

class HomePageProvider with ChangeNotifier {
  static HomePageProvider? _instance;
  static HomePageProvider get instance {
    if (_instance == null) {
      throw Exception('HomePageProvider not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<HomePageProvider> initialize({
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

    _instance = HomePageProvider._internal(
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

  HomePageProvider._internal(
    this._activeSchedulesProvider,
    this._shiftNameLegendSettingProvider,
    this._shiftNameSettingProvider,
    this._scheduleProvider,
    this._shiftSequenceProvider,
    this._scheduleExceptionProvider,
    this._workShiftProvider,
  ) {
    if (_instance != null) {
      throw Exception('HomePageProvider already initialized.');
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

  List<ScheduleItemViewModel> get schedules => _scheduleProvider.schedules;

  bool hasSchedules() => _scheduleProvider.hasSchedules();

  ScheduleItemViewModel? get activeSchedule {
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

    return _scheduleProvider.getScheduleById(activeScheduleId);
  }

  ScheduleItemViewModel? getScheduleById(String id) => _scheduleProvider.getScheduleById(id);

  bool isScheduleActive(ScheduleItemViewModel schedule) => activeSchedule?.id == schedule.id;

  bool get isComparisonMode => _activeSchedulesProvider.hasComparedSchedule;

  List<ScheduleItemViewModel> get comparedSchedules {
    if (!_activeSchedulesProvider.hasComparedSchedule) return [];
    if (activeSchedule == null) return [];

    final comparedScheduleId = _activeSchedulesProvider.comparedScheduleId!;

    if (_scheduleProvider.hasSchedule(comparedScheduleId)) {
      return [activeSchedule!, _scheduleProvider.getScheduleById(comparedScheduleId)];
    }

    return [activeSchedule!];
  }

  void enableComparisonMode(ScheduleItemViewModel activeSchedule, ScheduleItemViewModel comparedSchedule) =>
      _activeSchedulesProvider.setComparedScheduleIds(activeSchedule.id, comparedSchedule.id);

  bool isScheduleHasSequences(ScheduleItemViewModel schedule) =>
      _shiftSequenceProvider.hasShiftSequencesForSchedule(schedule.id) ? true : false;

  (ScheduleItemViewModel, ScheduleItemViewModel) getSchedulesForComparisonSetting() {
    if (isComparisonMode) {
      final List<ScheduleItemViewModel> comparedSchedules = this.comparedSchedules;
      return (comparedSchedules.first, comparedSchedules.last);
    } else {
      final configuredSchedules =
          _scheduleProvider.schedules.where((s) {
            return _shiftSequenceProvider.shiftSequences.any((ss) => ss.scheduleId == s.id);
          }).toList();

      if (configuredSchedules.length >= 2) {
        return (configuredSchedules.first, configuredSchedules[1]);
      } else if (configuredSchedules.length == 1 && _scheduleProvider.schedules.length >= 2) {
        final ScheduleItemViewModel secondScheduleId =
            _scheduleProvider.schedules.where((s) => s.id != configuredSchedules.first.id).first;
        return (configuredSchedules.first, secondScheduleId);
      } else if (_scheduleProvider.schedules.length >= 2) {
        return (_scheduleProvider.schedules.first, _scheduleProvider.schedules[1]);
      } else if (_scheduleProvider.schedules.length == 1) {
        return (_scheduleProvider.schedules.first, _scheduleProvider.schedules.first);
      }
    }
    final schedule = ScheduleItemViewModel.createDefault();
    return (schedule, schedule);
  }

  List<ScheduleItemViewModel> getAvailableSchedulesForComparison(ScheduleItemViewModel firstSchedule) =>
      schedules.where((s) => s.id != firstSchedule.id).toList();

  void onActiveScheduleChange(ScheduleItemViewModel activeSchedule) =>
      _activeSchedulesProvider.setActiveScheduleId(activeSchedule.id);

  bool hasExceptionForDateByActiveSchedule(DateTime date) {
    final activeSchedule = this.activeSchedule;
    if (activeSchedule == null) return false;
    return _scheduleExceptionProvider.hasExceptionForDate(date, activeSchedule.id);
  }

  bool isNotStaticShiftScheduleException(ScheduleExceptionItemViewModel scheduleException) {
    final workShift = _workShiftProvider.allWorkShifts.firstWhere((ws) => ws.id == scheduleException.workShiftId);
    if (!workShift.isStatic()) return true;
    return false;
  }

  ScheduleExceptionItemViewModel? getExceptionForDateByActiveSchedule(DateTime date) {
    final activeSchedule = this.activeSchedule;
    if (activeSchedule == null) return null;
    return _scheduleExceptionProvider.getExceptionForDate(date, activeSchedule.id);
  }

  void addScheduleExceptionForDay(WorkShiftItemViewModel workShift, DateTime date, WorkingTimeViewModel workingTime) {
    final activeSchedule = this.activeSchedule;
    if (activeSchedule == null) return;
    final scheduleException = ScheduleExceptionItemViewModel(
      id: Uuid().v4(),
      scheduleId: activeSchedule.id,
      workShiftId: workShift.id,
      startDate: date,
      endDate: date,
      workingTime: workingTime,
    );
    _scheduleExceptionProvider.addScheduleException(scheduleException);
  }

  void updateScheduleException(
    ScheduleExceptionItemViewModel scheduleException,
    WorkShiftItemViewModel workShift,
    DateTime date,
    WorkingTimeViewModel workingTime,
  ) {
    final scheduleExceptionNew = ScheduleExceptionItemViewModel(
      id: scheduleException.id,
      scheduleId: scheduleException.scheduleId,
      workShiftId: workShift.id,
      startDate: date,
      endDate: date,
      workingTime: workingTime,
    );
    _scheduleExceptionProvider.updateScheduleException(scheduleExceptionNew);
  }

  void removeScheduleException(String scheduleExceptionId) =>
      _scheduleExceptionProvider.removeScheduleException(scheduleExceptionId);

  List<Color> getColorsForActiveSchedule(DateTime forMonth) {
    if (activeSchedule == null) {
      return [];
    }

    return _shiftSequenceProvider.getColorsForSchedule(activeSchedule!.id, workShifts, forMonth);
  }

  List<List<Color>> getColorsForComparison(DateTime forMonth) {
    if (comparedSchedules.isEmpty) {
      return [[], []];
    }
    final comparedScheduleIds = comparedSchedules.map((e) => e.id).toList();
    final firstColors = _shiftSequenceProvider.getColorsForSchedule(comparedScheduleIds[0], workShifts, forMonth);
    final secondColors = _shiftSequenceProvider.getColorsForSchedule(comparedScheduleIds[1], workShifts, forMonth);

    return [firstColors, secondColors];
  }

  List<WorkShiftItemViewModel> getUsedShiftsInSchedule(String scheduleId) {
    final usedShiftIds =
        _shiftSequenceProvider.shiftSequences
            .where((seq) => seq.scheduleId == scheduleId)
            .map((seq) => seq.workShiftId)
            .toSet();

    return _workShiftProvider.workShifts.where((shift) => usedShiftIds.contains(shift.id)).toList();
  }

  (List<WorkShiftItemViewModel>, List<WorkShiftItemViewModel>) getUsedShiftsInComparedSchedules() {
    final firstUsedShifts = getUsedShiftsInSchedule(comparedSchedules.first.id);
    final secondUsedShifts = getUsedShiftsInSchedule(comparedSchedules.last.id);
    return (firstUsedShifts, secondUsedShifts);
  }

  WorkingTimeViewModel getWorkingTimeForWorkShift(WorkShiftItemViewModel workShift) {
    final activeSchedule = this.activeSchedule;
    if (activeSchedule == null) return WorkingTimeViewModel();
    return _shiftSequenceProvider.shiftSequences
            .firstWhereOrNull((ss) => ss.workShiftId == workShift.id)
            ?.workingTime ??
        WorkingTimeViewModel();
  }

  List<WorkShiftItemViewModel> get workShifts => _workShiftProvider.workShifts;

  String getAppBarTitleText({required String defaultValue}) {
    if (isComparisonMode) {
      final comparedSchedules = this.comparedSchedules;
      return '${comparedSchedules.first.name} / ${comparedSchedules.last.name}';
    }

    if (activeSchedule != null) {
      return activeSchedule!.name;
    }

    return defaultValue;
  }

  bool showShiftNameLegend() => _shiftNameLegendSettingProvider.showShiftNameLegend;
}
