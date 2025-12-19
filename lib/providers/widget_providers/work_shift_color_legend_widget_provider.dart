import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:sws/providers/model_providers/model_providers.dart'
    show
        ActiveSchedulesProvider,
        ScheduleItemViewModel,
        ScheduleProvider,
        ShiftNameLegendSettingProvider,
        WorkShiftItemViewModel;
import 'package:sws/services/services.dart' show ScheduleService;

class WorkShiftColorLegendWidgetProvider with ChangeNotifier {
  static WorkShiftColorLegendWidgetProvider? _instance;

  static WorkShiftColorLegendWidgetProvider get instance {
    if (_instance == null) {
      throw Exception(
        'WorkShiftColorLegendWidgetProvider not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  static Future<WorkShiftColorLegendWidgetProvider> initialize({
    required ActiveSchedulesProvider activeSchedulesProvider,
    required ShiftNameLegendSettingProvider shiftNameLegendSettingProvider,
    required ScheduleProvider scheduleProvider,
    required ScheduleService scheduleService,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = WorkShiftColorLegendWidgetProvider._internal(
      activeSchedulesProvider,
      shiftNameLegendSettingProvider,
      scheduleProvider,
      scheduleService,
    );
    return _instance!;
  }

  WorkShiftColorLegendWidgetProvider._internal(
    this._activeSchedulesProvider,
    this._shiftNameLegendSettingProvider,
    this._scheduleProvider,
    this._scheduleService,
  ) {
    if (_instance != null) {
      throw Exception(
        'WorkShiftColorLegendWidgetProvider already initialized.',
      );
    }
  }

  static bool get isInitialized => _instance != null;

  late final ActiveSchedulesProvider _activeSchedulesProvider;
  late final ShiftNameLegendSettingProvider _shiftNameLegendSettingProvider;
  late final ScheduleProvider _scheduleProvider;
  late final ScheduleService _scheduleService;

  bool showShiftNameLegend() =>
      _shiftNameLegendSettingProvider.showShiftNameLegend;

  bool hasSchedules() => _scheduleProvider.hasSchedules();

  bool get isComparisonMode => _activeSchedulesProvider.hasComparedSchedule;

  List<WorkShiftItemViewModel> getUsedShiftsInSchedule(String scheduleId) =>
      _scheduleService.getUsedShiftsInSchedule(scheduleId);

  List<ScheduleItemViewModel> get comparedSchedules =>
      _scheduleService.comparedSchedules;

  (List<WorkShiftItemViewModel>, List<WorkShiftItemViewModel>)
  getUsedShiftsInComparedSchedules() {
    final firstUsedShifts = getUsedShiftsInSchedule(comparedSchedules.first.id);
    final secondUsedShifts = getUsedShiftsInSchedule(comparedSchedules.last.id);
    return (firstUsedShifts, secondUsedShifts);
  }
}
