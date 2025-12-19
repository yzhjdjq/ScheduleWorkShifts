import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:sws/services/services.dart' show ScheduleService;
import 'package:sws/services/services.dart' show WidgetService;
import 'package:sws/providers/model_providers/model_providers.dart'
    show
        ActiveSchedulesProvider,
        ScheduleExceptionProvider,
        ScheduleItemViewModel,
        ScheduleProvider,
        ShiftSequenceProvider;

class SettingsSchedulePageProvider with ChangeNotifier {
  static SettingsSchedulePageProvider? _instance;
  static SettingsSchedulePageProvider get instance {
    if (_instance == null) {
      throw Exception(
        'SettingsSchedulePageProvider not initialized. Call initialize() first.',
      );
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
    _scheduleExceptionProvider.addListener(notify);
    _scheduleProvider.addListener(notify);
    _shiftSequenceProvider.addListener(notify);
  }

  static bool get isInitialized => _instance != null;

  late final ActiveSchedulesProvider _activeSchedulesProvider;
  late final ScheduleExceptionProvider _scheduleExceptionProvider;
  late final ScheduleProvider _scheduleProvider;
  late final ScheduleService _scheduleService;
  late final ShiftSequenceProvider _shiftSequenceProvider;

  void notify() {
    notifyListeners();
    WidgetService.updateWidget();
  }

  List<ScheduleItemViewModel> get schedules => _scheduleProvider.schedules;

  void addSchedule(ScheduleItemViewModel schedule) =>
      _scheduleProvider.addSchedule(schedule);

  void updateSchedule(ScheduleItemViewModel newSchedule) =>
      _scheduleProvider.updateSchedule(newSchedule);

  void removeSchedule(String scheduleId) =>
      _scheduleService.removeSchedule(scheduleId);
}
