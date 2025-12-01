import 'package:flutter/material.dart' show ChangeNotifier, Color;
import 'package:sws/models/models.dart' show Schedule, WorkShift;
import 'package:sws/providers/base_provider_mixin.dart' show BaseProviderMixin;
import 'package:sws/providers/stores/stores.dart'
    show ScheduleExceptionStore, ScheduleStore, ShiftSequenceStore, WorkShiftStore;
import 'package:sws/services/services.dart' show StorageService, WidgetService;

mixin _ShiftNameLegendSettingsMixin on BaseProviderMixin {
  static const String _shiftNameLegendKey = 'showShiftNameLegend';
  static bool _showShiftNameLegend = true;

  Future<void> _loadShiftNameLegendFromStorage() async {
    if (!StorageService.containsKey(_shiftNameLegendKey)) {
      await StorageService.setBool(_shiftNameLegendKey, _showShiftNameLegend);
    }

    _showShiftNameLegend = StorageService.getBool(_shiftNameLegendKey)!;
  }

  bool get showShiftNameLegend => _showShiftNameLegend;
  set showShiftNameLegend(bool value) {
    if (_showShiftNameLegend != value) {
      _showShiftNameLegend = value;
      StorageService.setBool(_shiftNameLegendKey, _showShiftNameLegend);
      notify();
    }
  }
}

mixin _ShiftNameSettingsMixin on BaseProviderMixin {
  static const String _shiftNameKey = 'showShiftName';
  static bool _showShiftName = true;

  Future<void> _loadShiftNameFromStorage() async {
    if (!StorageService.containsKey(_shiftNameKey)) {
      await StorageService.setBool(_shiftNameKey, _showShiftName);
    }

    _showShiftName = StorageService.getBool(_shiftNameKey)!;
  }

  bool get showShiftName => _showShiftName;
  set showShiftName(bool value) {
    if (_showShiftName != value) {
      _showShiftName = value;
      StorageService.setBool(_shiftNameKey, _showShiftName);
      notify();
    }
  }
}

class SettingsProvider extends BaseProviderMixin
    with ChangeNotifier, _ShiftNameLegendSettingsMixin, _ShiftNameSettingsMixin {
  static SettingsProvider? _instance;
  static SettingsProvider get instance {
    if (_instance == null) {
      throw Exception('SettingsProvider not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<SettingsProvider> initialize({
    required ScheduleStore scheduleStore,
    required WorkShiftStore workShiftStore,
    required ShiftSequenceStore shiftSequenceStore,
    required ScheduleExceptionStore scheduleExceptionStore,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = SettingsProvider._(scheduleStore, workShiftStore, shiftSequenceStore, scheduleExceptionStore);
    await _instance!._loadFromStorage();
    return _instance!;
  }

  SettingsProvider._(
    this._scheduleStore,
    this._workShiftStore,
    this._shiftSequenceStore,
    this._scheduleExceptionStore,
  ) {
    if (_instance != null) {
      throw Exception('SettingsProvider already initialized.');
    }

    _scheduleStore.addListener(notify);
    _workShiftStore.addListener(notify);
    _shiftSequenceStore.addListener(notify);
    _scheduleExceptionStore.addListener(notify);
  }

  static bool get isInitialized => _instance != null;

  late final ScheduleStore _scheduleStore;
  late final WorkShiftStore _workShiftStore;
  late final ShiftSequenceStore _shiftSequenceStore;
  late final ScheduleExceptionStore _scheduleExceptionStore;

  @override
  void notify() {
    notifyListeners();
    WidgetService.updateWidget();
  }

  Future<void> _loadFromStorage() async {
    await _loadShiftNameLegendFromStorage();
    await _loadShiftNameFromStorage();
  }

  List<Schedule> get schedules => _scheduleStore.schedules;

  void addSchedule(Schedule schedule) => _scheduleStore.addSchedule(schedule);

  void updateSchedule(Schedule newSchedule) => _scheduleStore.updateSchedule(newSchedule);

  void removeSchedule(String scheduleId) {
    _scheduleStore.removeSchedule(scheduleId);
    _shiftSequenceStore.removeSequencesForSchedule(scheduleId);
    _scheduleExceptionStore.removeExceptionsForSchedule(scheduleId);
  }

  void addWorkShift(WorkShift shift) => _workShiftStore.addWorkShift(shift);

  void updateWorkShift(WorkShift newShift) => _workShiftStore.updateWorkShift(newShift);

  void updateStaticShiftColor(String id, Color newColor) => _workShiftStore.updateStaticShiftColor(id, newColor);

  void removeWorkShift(String shiftId) {
    _workShiftStore.removeWorkShift(shiftId);
    _shiftSequenceStore.removeSequencesForShift(shiftId);
    _scheduleExceptionStore.removeExceptionsForShift(shiftId);
  }

  List<WorkShift> get workShifts => _workShiftStore.workShifts;

  List<WorkShift> get allWorkShifts => _workShiftStore.allWorkShifts;
}
