import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:sws/providers/model_providers/model_providers.dart'
    show
        ActiveSchedulesProvider,
        ScheduleItemViewModel,
        ScheduleProvider,
        ShiftSequenceItemViewModel,
        ShiftSequenceProvider,
        WorkShiftItemViewModel,
        WorkShiftProvider;
import 'package:sws/services/services.dart' show WidgetService;

class CreateSchedulePageProvider with ChangeNotifier {
  static CreateSchedulePageProvider? _instance;
  static CreateSchedulePageProvider get instance {
    if (_instance == null) {
      throw Exception('SchedulePageProvider not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<CreateSchedulePageProvider> initialize({
    required ActiveSchedulesProvider activeSchedulesProvider,
    required ScheduleProvider scheduleProvider,
    required WorkShiftProvider workShiftProvider,
    required ShiftSequenceProvider shiftSequenceProvider,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = CreateSchedulePageProvider._internal(
      activeSchedulesProvider,
      scheduleProvider,
      workShiftProvider,
      shiftSequenceProvider,
    );
    return _instance!;
  }

  CreateSchedulePageProvider._internal(
    this._activeSchedulesProvider,
    this._scheduleProvider,
    this._workShiftProvider,
    this._shiftSequenceProvider,
  ) {
    if (_instance != null) {
      throw Exception('SchedulePageProvider already initialized.');
    }

    _activeSchedulesProvider.addListener(notify);
    _scheduleProvider.addListener(notify);
    _workShiftProvider.addListener(notify);
    _shiftSequenceProvider.addListener(notify);
  }

  static bool get isInitialized => _instance != null;

  late final ActiveSchedulesProvider _activeSchedulesProvider;
  late final ScheduleProvider _scheduleProvider;
  late final WorkShiftProvider _workShiftProvider;
  late final ShiftSequenceProvider _shiftSequenceProvider;

  void notify() {
    notifyListeners();
    WidgetService.updateWidget();
  }

  bool hasSchedules() => _scheduleProvider.hasSchedules();

  ScheduleItemViewModel? getActiveSchedule() {
    if (!_activeSchedulesProvider.hasActiveSchedule) {
      final firstSchedule = _scheduleProvider.schedules.firstOrNull;

      if (firstSchedule != null) {
        _activeSchedulesProvider.setActiveScheduleId(firstSchedule.id);
      }

      return firstSchedule;
    }

    final activeScheduleId = _activeSchedulesProvider.activeScheduleId!;
    return _scheduleProvider.getScheduleById(activeScheduleId);
  }

  List<ScheduleItemViewModel> get schedules => _scheduleProvider.schedules;

  ScheduleItemViewModel? getScheduleById(String id) => _scheduleProvider.getScheduleById(id);

  void updateSchedule(ScheduleItemViewModel schedule) => _scheduleProvider.updateSchedule(schedule);

  List<ShiftSequenceItemViewModel> getShiftSequencesForSchedule(ScheduleItemViewModel? schedule) =>
      schedule == null ? [] : _shiftSequenceProvider.getShiftSequencesForSchedule(schedule.id);

  WorkShiftItemViewModel getWorkShiftFromScheduleSequence(ShiftSequenceItemViewModel sequence) =>
      workShifts.firstWhere((s) => s.id == sequence.workShiftId, orElse: () => workShifts.first);

  List<WorkShiftItemViewModel> get workShifts => _workShiftProvider.workShifts;

  List<ShiftSequenceItemViewModel> get shiftSequences => _shiftSequenceProvider.shiftSequences;

  void addShiftSequence(ShiftSequenceItemViewModel newSequence) => _shiftSequenceProvider.addShiftSequence(newSequence);

  void removeShiftSequence(String id) => _shiftSequenceProvider.removeShiftSequence(id);
}
