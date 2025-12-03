import 'package:flutter/material.dart' show ChangeNotifier;
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
    required ScheduleProvider scheduleProvider,
    required ShiftSequenceProvider shiftSequenceProvider,
    required ScheduleExceptionProvider scheduleExceptionProvider,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = SettingsSchedulePageProvider._(scheduleProvider, shiftSequenceProvider, scheduleExceptionProvider);
    return _instance!;
  }

  SettingsSchedulePageProvider._(this._scheduleStore, this._shiftSequenceStore, this._scheduleExceptionStore) {
    if (_instance != null) {
      throw Exception('SettingsSchedulePageProvider already initialized.');
    }

    _scheduleStore.addListener(notify);
    _shiftSequenceStore.addListener(notify);
    _scheduleExceptionStore.addListener(notify);
  }

  static bool get isInitialized => _instance != null;

  late final ScheduleProvider _scheduleStore;
  late final ShiftSequenceProvider _shiftSequenceStore;
  late final ScheduleExceptionProvider _scheduleExceptionStore;

  void notify() {
    notifyListeners();
    WidgetService.updateWidget();
  }

  List<ScheduleItemViewModel> get schedules => _scheduleStore.schedules;

  void addSchedule(ScheduleItemViewModel schedule) => _scheduleStore.addSchedule(schedule);

  void updateSchedule(ScheduleItemViewModel newSchedule) => _scheduleStore.updateSchedule(newSchedule);

  void removeSchedule(String scheduleId) {
    _scheduleStore.removeSchedule(scheduleId);
    _shiftSequenceStore.removeSequencesForSchedule(scheduleId);
    _scheduleExceptionStore.removeExceptionsForSchedule(scheduleId);
  }
}
