import 'package:flutter/material.dart' show ChangeNotifier, Color;

import 'package:sws/providers/model_providers/model_providers.dart'
    show ScheduleExceptionProvider, ShiftSequenceProvider, WorkShiftItemViewModel, WorkShiftProvider;
import 'package:sws/services/services.dart';

class SettingsShiftsPageProvider with ChangeNotifier {
  static SettingsShiftsPageProvider? _instance;
  static SettingsShiftsPageProvider get instance {
    if (_instance == null) {
      throw Exception('SettingsShiftsPageProvider not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<SettingsShiftsPageProvider> initialize({
    required WorkShiftProvider workShiftProvider,
    required ShiftSequenceProvider shiftSequenceProvider,
    required ScheduleExceptionProvider scheduleExceptionProvider,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = SettingsShiftsPageProvider._(workShiftProvider, shiftSequenceProvider, scheduleExceptionProvider);
    return _instance!;
  }

  SettingsShiftsPageProvider._(this._workShiftProvider, this._shiftSequenceStore, this._scheduleExceptionStore) {
    if (_instance != null) {
      throw Exception('SettingsShiftsPageProvider already initialized.');
    }

    _workShiftProvider.addListener(notify);
    _shiftSequenceStore.addListener(notify);
    _scheduleExceptionStore.addListener(notify);
  }

  static bool get isInitialized => _instance != null;

  late final WorkShiftProvider _workShiftProvider;
  late final ShiftSequenceProvider _shiftSequenceStore;
  late final ScheduleExceptionProvider _scheduleExceptionStore;

  void notify() {
    notifyListeners();
    WidgetService.updateWidget();
  }

  void addWorkShift(WorkShiftItemViewModel shift) => _workShiftProvider.addWorkShift(shift);

  void updateWorkShift(WorkShiftItemViewModel newShift) => _workShiftProvider.updateWorkShift(newShift);

  void updateStaticShiftColor(String id, Color newColor) => _workShiftProvider.updateStaticShiftColor(id, newColor);

  void removeWorkShift(String shiftId) {
    _workShiftProvider.removeWorkShift(shiftId);
    _shiftSequenceStore.removeSequencesForShift(shiftId);
    _scheduleExceptionStore.removeExceptionsForShift(shiftId);
  }

  List<WorkShiftItemViewModel> get workShifts => _workShiftProvider.workShifts;

  List<WorkShiftItemViewModel> get allWorkShifts => _workShiftProvider.allWorkShifts;
}
