import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:sws/providers/model_providers/model_providers.dart'
    show
        ActiveSchedulesProvider,
        ScheduleExceptionProvider,
        ScheduleProvider,
        WorkShiftProvider;
import 'package:sws/services/services.dart' show ScheduleService, WidgetService;

class ScheduleExceptionDialogsProvider with ChangeNotifier {
  static ScheduleExceptionDialogsProvider? _instance;
  static ScheduleExceptionDialogsProvider get instance {
    if (_instance == null) {
      throw Exception(
        'ScheduleExceptionDialogsProvider not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  static Future<ScheduleExceptionDialogsProvider> initialize({
    required ActiveSchedulesProvider activeSchedulesProvider,
    required ScheduleProvider scheduleProvider,
    required ScheduleService scheduleService,
    required ScheduleExceptionProvider scheduleExceptionProvider,
    required WorkShiftProvider workShiftProvider,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = ScheduleExceptionDialogsProvider._internal(
      activeSchedulesProvider,
      scheduleProvider,
      scheduleService,
      scheduleExceptionProvider,
      workShiftProvider,
    );
    return _instance!;
  }

  ScheduleExceptionDialogsProvider._internal(
    this._activeSchedulesProvider,
    this._scheduleProvider,
    this._scheduleService,
    this._scheduleExceptionProvider,
    this._workShiftProvider,
  ) {
    if (_instance != null) {
      throw Exception('ScheduleExceptionDialogsProvider already initialized.');
    }

    _activeSchedulesProvider.addListener(notify);
    _scheduleProvider.addListener(notify);
    _scheduleExceptionProvider.addListener(notify);
    _workShiftProvider.addListener(notify);
  }

  static bool get isInitialized => _instance != null;

  late final ActiveSchedulesProvider _activeSchedulesProvider;
  late final ScheduleProvider _scheduleProvider;
  late final ScheduleService _scheduleService;
  late final ScheduleExceptionProvider _scheduleExceptionProvider;
  late final WorkShiftProvider _workShiftProvider;

  void notify() {
    notifyListeners();
    WidgetService.updateWidget();
  }

  String? getActiveScheduleId() => _activeSchedulesProvider.activeScheduleId;

  bool isComparisonMode() => _activeSchedulesProvider.hasComparedSchedule;

  void addVacation(String scheduleId, DateTime startDate, DateTime endDate) =>
      _scheduleService.addVacation(scheduleId, startDate, endDate);

  void addSickLeave(String scheduleId, DateTime startDate, DateTime endDate) =>
      _scheduleService.addSickLeave(scheduleId, startDate, endDate);
}
