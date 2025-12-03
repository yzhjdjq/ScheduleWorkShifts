import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:sws/providers/model_providers/model_providers.dart'
    show ActiveSchedulesProvider, ScheduleProvider, WorkShiftProvider, WorkingTimeViewModel;
import 'package:sws/providers/model_providers/schedule_exception_provider.dart';
import 'package:sws/services/services.dart' show WidgetService;
import 'package:uuid/uuid.dart' show Uuid;

class ScheduleExceptionDialogsProvider with ChangeNotifier {
  static ScheduleExceptionDialogsProvider? _instance;
  static ScheduleExceptionDialogsProvider get instance {
    if (_instance == null) {
      throw Exception('ScheduleExceptionDialogsProvider not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<ScheduleExceptionDialogsProvider> initialize({
    required ActiveSchedulesProvider activeSchedulesProvider,
    required ScheduleProvider scheduleProvider,
    required ScheduleExceptionProvider scheduleExceptionProvider,
    required WorkShiftProvider workShiftProvider,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = ScheduleExceptionDialogsProvider._internal(
      activeSchedulesProvider,
      scheduleProvider,
      scheduleExceptionProvider,
      workShiftProvider,
    );
    return _instance!;
  }

  ScheduleExceptionDialogsProvider._internal(
    this._activeSchedulesProvider,
    this._scheduleProvider,
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
  late final ScheduleExceptionProvider _scheduleExceptionProvider;
  late final WorkShiftProvider _workShiftProvider;

  void notify() {
    notifyListeners();
    WidgetService.updateWidget();
  }

  String? getActiveScheduleId() => _activeSchedulesProvider.activeScheduleId;

  bool isComparisonMode() => _activeSchedulesProvider.hasComparedSchedule;

  void addVacation(String scheduleId, DateTime startDate, DateTime endDate) {
    if (!_scheduleProvider.hasSchedule(scheduleId)) return;
    final vacationException = ScheduleExceptionItemViewModel(
      id: Uuid().v4(),
      scheduleId: scheduleId,
      workShiftId: _workShiftProvider.vacationShift.id,
      startDate: startDate,
      endDate: endDate,
      workingTime: WorkingTimeViewModel(),
    );
    _scheduleExceptionProvider.addScheduleException(vacationException);
  }

  void addSickLeave(String scheduleId, DateTime startDate, DateTime endDate) {
    if (!_scheduleProvider.hasSchedule(scheduleId)) return;
    final sickLeaveException = ScheduleExceptionItemViewModel(
      id: Uuid().v4(),
      scheduleId: scheduleId,
      workShiftId: _workShiftProvider.sickLeaveShift.id,
      startDate: startDate,
      endDate: endDate,
      workingTime: WorkingTimeViewModel(),
    );
    _scheduleExceptionProvider.addScheduleException(sickLeaveException);
  }
}
