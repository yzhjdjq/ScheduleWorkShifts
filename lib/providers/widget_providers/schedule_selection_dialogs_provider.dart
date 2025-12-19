import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:sws/providers/model_providers/model_providers.dart'
    show
        ActiveSchedulesProvider,
        ScheduleItemViewModel,
        ScheduleProvider,
        ShiftSequenceProvider;
import 'package:sws/services/services.dart' show ScheduleService, WidgetService;

class ScheduleSelectionDialogsProvider with ChangeNotifier {
  static ScheduleSelectionDialogsProvider? _instance;

  static ScheduleSelectionDialogsProvider get instance {
    if (_instance == null) {
      throw Exception(
        'ScheduleSelectionDialogsProvider not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  static Future<ScheduleSelectionDialogsProvider> initialize({
    required ActiveSchedulesProvider activeSchedulesProvider,
    required ScheduleProvider scheduleProvider,
    required ScheduleService scheduleService,
    required ShiftSequenceProvider shiftSequenceProvider,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = ScheduleSelectionDialogsProvider._internal(
      activeSchedulesProvider,
      scheduleProvider,
      scheduleService,
      shiftSequenceProvider,
    );
    return _instance!;
  }

  ScheduleSelectionDialogsProvider._internal(
    this._activeSchedulesProvider,
    this._scheduleProvider,
    this._scheduleService,
    this._shiftSequenceProvider,
  ) {
    if (_instance != null) {
      throw Exception('ScheduleSelectionDialogsProvider already initialized.');
    }

    _activeSchedulesProvider.addListener(notify);
    _scheduleProvider.addListener(notify);
    _shiftSequenceProvider.addListener(notify);
  }

  static bool get isInitialized => _instance != null;

  late final ActiveSchedulesProvider _activeSchedulesProvider;
  late final ScheduleProvider _scheduleProvider;
  late final ScheduleService _scheduleService;
  late final ShiftSequenceProvider _shiftSequenceProvider;

  void notify() {
    notifyListeners();
    WidgetService.updateWidget();
  }

  ScheduleItemViewModel? get _activeSchedule => _scheduleService.activeSchedule;

  List<ScheduleItemViewModel> get schedules => _scheduleProvider.schedules;

  bool isScheduleActive(ScheduleItemViewModel schedule) =>
      _activeSchedule?.id == schedule.id;

  bool isScheduleHasSequences(ScheduleItemViewModel schedule) =>
      _shiftSequenceProvider.hasShiftSequencesForSchedule(schedule.id);

  ScheduleItemViewModel? getScheduleById(String id) =>
      _scheduleProvider.getScheduleById(id);

  bool get isComparisonMode => _activeSchedulesProvider.hasComparedSchedule;

  List<ScheduleItemViewModel> get _comparedSchedules =>
      _scheduleService.comparedSchedules;

  void enableComparisonMode(
    ScheduleItemViewModel activeSchedule,
    ScheduleItemViewModel comparedSchedule,
  ) => _activeSchedulesProvider.setComparedScheduleIds(
    activeSchedule.id,
    comparedSchedule.id,
  );

  void onActiveScheduleChange(ScheduleItemViewModel activeSchedule) =>
      _activeSchedulesProvider.setActiveScheduleId(activeSchedule.id);

  (ScheduleItemViewModel, ScheduleItemViewModel)
  getSchedulesForComparisonSetting() {
    if (isComparisonMode) {
      final List<ScheduleItemViewModel> comparedSchedules = _comparedSchedules;
      return (comparedSchedules.first, comparedSchedules.last);
    } else {
      final configuredSchedules = _scheduleService.configuredSchedules;

      if (configuredSchedules.length >= 2) {
        return (configuredSchedules.first, configuredSchedules[1]);
      } else if (configuredSchedules.length == 1 &&
          _scheduleProvider.schedules.length >= 2) {
        final ScheduleItemViewModel secondScheduleId = _scheduleProvider
            .firstWithout(configuredSchedules.first);
        return (configuredSchedules.first, secondScheduleId);
      } else if (_scheduleProvider.schedules.length >= 2) {
        return (
          _scheduleProvider.schedules.first,
          _scheduleProvider.schedules[1],
        );
      } else if (_scheduleProvider.schedules.length == 1) {
        return (
          _scheduleProvider.schedules.first,
          _scheduleProvider.schedules.first,
        );
      }
    }
    final schedule = ScheduleItemViewModel.createDefault();
    return (schedule, schedule);
  }

  List<ScheduleItemViewModel> getAvailableSchedulesForComparison(
    ScheduleItemViewModel firstSchedule,
  ) => _scheduleProvider.schedulesWithout(firstSchedule);
}
