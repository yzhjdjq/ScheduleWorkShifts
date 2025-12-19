import 'package:flutter/material.dart' show ChangeNotifier, Color;
import 'package:sws/providers/model_providers/model_providers.dart'
    show
        ScheduleExceptionProvider,
        ShiftSequenceProvider,
        WorkShiftItemViewModel,
        WorkShiftProvider;
import 'package:sws/services/services.dart' show ScheduleService, WidgetService;

class SettingsShiftsPageProvider with ChangeNotifier {
  static SettingsShiftsPageProvider? _instance;
  static SettingsShiftsPageProvider get instance {
    if (_instance == null) {
      throw Exception(
        'SettingsShiftsPageProvider not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  static Future<SettingsShiftsPageProvider> initialize({
    required ScheduleExceptionProvider scheduleExceptionProvider,
    required ScheduleService scheduleService,
    required ShiftSequenceProvider shiftSequenceProvider,
    required WorkShiftProvider workShiftProvider,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = SettingsShiftsPageProvider._internal(
      scheduleExceptionProvider,
      scheduleService,
      shiftSequenceProvider,
      workShiftProvider,
    );
    return _instance!;
  }

  SettingsShiftsPageProvider._internal(
    this._scheduleExceptionProvider,
    this._scheduleService,
    this._shiftSequenceProvider,
    this._workShiftProvider,
  ) {
    if (_instance != null) {
      throw Exception('SettingsShiftsPageProvider already initialized.');
    }

    _scheduleExceptionProvider.addListener(notify);
    _shiftSequenceProvider.addListener(notify);
    _workShiftProvider.addListener(notify);
  }

  static bool get isInitialized => _instance != null;

  late final ScheduleExceptionProvider _scheduleExceptionProvider;
  late final ScheduleService _scheduleService;
  late final ShiftSequenceProvider _shiftSequenceProvider;
  late final WorkShiftProvider _workShiftProvider;

  void notify() {
    notifyListeners();
    WidgetService.updateWidget();
  }

  void addWorkShift(WorkShiftItemViewModel shift) =>
      _workShiftProvider.addWorkShift(shift);

  void updateWorkShift(WorkShiftItemViewModel newShift) =>
      _workShiftProvider.updateWorkShift(newShift);

  void updateStaticShiftColor(String id, Color newColor) =>
      _workShiftProvider.updateStaticShiftColor(id, newColor);

  void removeWorkShift(String shiftId) =>
      _scheduleService.removeWorkShift(shiftId);

  List<WorkShiftItemViewModel> get workShifts => _workShiftProvider.workShifts;

  List<WorkShiftItemViewModel> get allWorkShifts =>
      _workShiftProvider.allWorkShifts;
}
