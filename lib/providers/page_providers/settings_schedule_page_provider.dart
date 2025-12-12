import 'package:collection/collection.dart';
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:sws/providers/model_providers/active_schedules_provider.dart';
import 'package:sws/services/services.dart' show WidgetService;
import 'package:sws/providers/model_providers/model_providers.dart'
    show ScheduleExceptionProvider, ScheduleProvider, ScheduleItemViewModel, ShiftSequenceProvider;

class SettingsSchedulePageProvider with ChangeNotifier {
  static SettingsSchedulePageProvider? _instance;
  static SettingsSchedulePageProvider get instance {
    if (_instance == null) {
      throw Exception('SettingsSchedulePageProvider not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<SettingsSchedulePageProvider> initialize({
    required ActiveSchedulesProvider activeSchedulesProvider,
    required ScheduleProvider scheduleProvider,
    required ShiftSequenceProvider shiftSequenceProvider,
    required ScheduleExceptionProvider scheduleExceptionProvider,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = SettingsSchedulePageProvider._internal(
      activeSchedulesProvider,
      scheduleProvider,
      shiftSequenceProvider,
      scheduleExceptionProvider,
    );
    return _instance!;
  }

  SettingsSchedulePageProvider._internal(
    this._activeSchedulesProvider,
    this._scheduleProvider,
    this._shiftSequenceProvider,
    this._scheduleExceptionProvider,
  ) {
    if (_instance != null) {
      throw Exception('SettingsSchedulePageProvider already initialized.');
    }

    _activeSchedulesProvider.addListener(notify);
    _scheduleProvider.addListener(notify);
    _shiftSequenceProvider.addListener(notify);
    _scheduleExceptionProvider.addListener(notify);
  }

  static bool get isInitialized => _instance != null;

  late final ActiveSchedulesProvider _activeSchedulesProvider;
  late final ScheduleProvider _scheduleProvider;
  late final ShiftSequenceProvider _shiftSequenceProvider;
  late final ScheduleExceptionProvider _scheduleExceptionProvider;

  void notify() {
    notifyListeners();
    WidgetService.updateWidget();
  }

  List<ScheduleItemViewModel> get schedules => _scheduleProvider.schedules;

  void addSchedule(ScheduleItemViewModel schedule) => _scheduleProvider.addSchedule(schedule);

  void updateSchedule(ScheduleItemViewModel newSchedule) => _scheduleProvider.updateSchedule(newSchedule);

  void removeSchedule(String scheduleId) {
    if (_activeSchedulesProvider.hasActiveSchedule && _activeSchedulesProvider.activeScheduleId == scheduleId) {
      if (_activeSchedulesProvider.hasComparedSchedule) {
        _activeSchedulesProvider.setActiveScheduleId(_activeSchedulesProvider.comparedScheduleId!);
      } else {
        final activeSchedule = _scheduleProvider.schedules.firstWhereOrNull((s) => s.id != scheduleId);
        if (activeSchedule == null) {
          _activeSchedulesProvider.resetActiveSchedules();
        } else {
          _activeSchedulesProvider.setActiveScheduleId(activeSchedule.id);
        }
      }
    }
    if (_activeSchedulesProvider.hasComparedSchedule && _activeSchedulesProvider.comparedScheduleId == scheduleId) {
      _activeSchedulesProvider.setActiveScheduleId(_activeSchedulesProvider.activeScheduleId!);
    }
    _scheduleProvider.removeSchedule(scheduleId);
    _shiftSequenceProvider.removeSequencesForSchedule(scheduleId);
    _scheduleExceptionProvider.removeExceptionsForSchedule(scheduleId);
  }
}
