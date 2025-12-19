import 'package:flutter/material.dart' show ChangeNotifier, Color;
import 'package:sws/services/services.dart' show ScheduleService, WidgetService;
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

class HomePageProvider with ChangeNotifier {
  static HomePageProvider? _instance;
  static HomePageProvider get instance {
    if (_instance == null) {
      throw Exception(
        'HomePageProvider not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  static Future<HomePageProvider> initialize({
    required ActiveSchedulesProvider activeSchedulesProvider,
    required ShiftNameLegendSettingProvider shiftNameLegendSettingProvider,
    required ShiftNameSettingProvider shiftNameSettingProvider,
    required ScheduleProvider scheduleProvider,
    required ScheduleService scheduleService,
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
      scheduleService,
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
    this._scheduleService,
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
  late final ScheduleService _scheduleService;
  late final ShiftSequenceProvider _shiftSequenceProvider;
  late final ScheduleExceptionProvider _scheduleExceptionProvider;
  late final WorkShiftProvider _workShiftProvider;

  void notify() {
    notifyListeners();
    WidgetService.updateWidget();
  }

  List<ScheduleItemViewModel> get schedules => _scheduleProvider.schedules;

  bool hasSchedules() => _scheduleProvider.hasSchedules();

  ScheduleItemViewModel? get activeSchedule => _scheduleService.activeSchedule;

  bool get isComparisonMode => _activeSchedulesProvider.hasComparedSchedule;

  List<ScheduleItemViewModel> get comparedSchedules =>
      _scheduleService.comparedSchedules;

  bool hasExceptionForDateByActiveSchedule(DateTime date) =>
      _scheduleService.hasExceptionForDateByActiveSchedule(date);

  bool isNotStaticShiftScheduleException(
    ScheduleExceptionItemViewModel scheduleException,
  ) => _scheduleService.isNotStaticShiftScheduleException(scheduleException);

  ScheduleExceptionItemViewModel? getExceptionForDateByActiveSchedule(
    DateTime date,
  ) => _scheduleService.getExceptionForDateByActiveSchedule(date);

  void addScheduleExceptionForDay(
    WorkShiftItemViewModel workShift,
    DateTime date,
    WorkingTimeViewModel workingTime,
  ) =>
      _scheduleService.addScheduleExceptionForDay(workShift, date, workingTime);

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

  List<Color> getColorsForActiveSchedule(DateTime forMonth) =>
      _scheduleService.getColorsForActiveSchedule(forMonth);

  List<List<Color>> getColorsForComparison(DateTime forMonth) =>
      _scheduleService.getColorsForComparison(forMonth);

  WorkingTimeViewModel getWorkingTimeForWorkShiftInActiveSchedule(
    WorkShiftItemViewModel workShift,
  ) => _scheduleService.getWorkingTimeForWorkShiftInActiveSchedule(workShift);

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
}
