import 'package:flutter/material.dart';

import 'package:sws/models/schedule.dart';
import 'package:sws/models/work_shift.dart';
import 'package:sws/services/storage_service.dart';
import 'package:uuid/uuid.dart' show Uuid;

abstract class BaseSettingsMixin {
  void notify();
}

mixin ShiftNameSettingsMixin on BaseSettingsMixin {
  static const String _shiftNameKey = 'showShiftName';
  bool _showShiftName = true;

  Future<void> _loadShiftNameFromStorage() async {
    if (!StorageService.containsKey(_shiftNameKey)) {
      StorageService.setBool(_shiftNameKey, _showShiftName);
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

mixin ScheduleSettingsMixin on BaseSettingsMixin {
  static const String _scheduleKey = 'schedules';
  List<Schedule> _schedules = [];

  Future<void> _loadSchedulesFromStorage() async {
    if (!StorageService.containsKey(_scheduleKey)) {
      StorageService.setObject(_scheduleKey, _schedules);
    }

    _schedules = StorageService
      .getObjectList<Schedule>(_scheduleKey, fromJson: Schedule.fromJson) ?? [];
  }

  List<Schedule> get schedules => List.unmodifiable(_schedules);

  void addSchedule(Schedule schedule) {
    _schedules.add(schedule);
    StorageService.setObject(_scheduleKey, _schedules);
    notify();
  }

  void updateSchedule(String id, Schedule newSchedule) {
    final int index = _schedules.indexWhere((schedule) => schedule.id == id);

    if (index != -1) {
      _schedules[index] = newSchedule;
      StorageService.setObject(_scheduleKey, _schedules);
      notify();
    }
  }

  void removeSchedule(String id) {
    _schedules.removeWhere((schedule) => schedule.id == id);
    StorageService.setObject(_scheduleKey, _schedules);
    notify();
  }
}

mixin WorkShiftSettingsMixin on BaseSettingsMixin {
  static const String _workShiftsKey = 'workShifts';
  static const String _vacationShiftKey = 'vacationShift';
  static const String _sickLeaveShiftKey = 'sickLeaveShift';
  List<WorkShift> _workShifts = [];
  WorkShift _vacationShift = WorkShift.createStatic();
  WorkShift _sickLeaveShift = WorkShift.createStatic(
    name: 'Больничный',
    color: Colors.red,
  );

  void _ensureMinimumWorkShifts() {
    _workShifts.add(WorkShift.createDefault());
    _workShifts.add(WorkShift(
      id: const Uuid().v4(),
      name: 'Выходной',
      category: ShiftCategory.dayOff,
      color: Colors.green,
    ));
  }

  Future<void> _loadShiftsSettingsFromStorage() async {
    if (!StorageService.containsKey(_workShiftsKey)
      || ( StorageService.getObjectList<WorkShift>(_workShiftsKey,
        fromJson: WorkShift.fromJson)?.isEmpty ?? true )
    ) {
      _ensureMinimumWorkShifts();
      StorageService.setObject(_workShiftsKey, _workShifts);
    }

    if (!StorageService.containsKey(_vacationShiftKey)) {
      StorageService.setInt(_vacationShiftKey, _vacationShift.color.toARGB32());
    }

    if (!StorageService.containsKey(_sickLeaveShiftKey)) {
      StorageService.setInt(_sickLeaveShiftKey, _sickLeaveShift.color.toARGB32());
    }

    _workShifts = StorageService.getObjectList<WorkShift>(_workShiftsKey, fromJson: WorkShift.fromJson) ?? [];
    final vacationColorValue = StorageService.getInt(_vacationShiftKey);
    final sickLeaveColorValue = StorageService.getInt(_sickLeaveShiftKey);

    if (vacationColorValue != null) {
      _vacationShift = WorkShift.copy(_vacationShift)
        ..color = Color(vacationColorValue);
    }

    if (sickLeaveColorValue != null) {
      _sickLeaveShift = WorkShift.copy(_sickLeaveShift)
        ..color = Color(sickLeaveColorValue);
    }
  }

  List<WorkShift> get workShifts
    => List.unmodifiable(_workShifts);

  List<WorkShift> get allWorkShifts
    => List.unmodifiable([
      ..._workShifts,
      _vacationShift,
      _sickLeaveShift,
    ]);

  WorkShift get sickLeaveShift => _sickLeaveShift;

  WorkShift get vacationShift => _vacationShift;

  void addWorkShift(WorkShift shift) {
    _workShifts.add(shift);
    StorageService.setObject(_workShiftsKey, _workShifts);
    notify();
  }

  void updateWorkShift(String id, WorkShift newShift) {
    final int index = _workShifts.indexWhere((shift) => shift.id == id);

    if (index != -1) {
      _workShifts[index] = newShift;
      StorageService.setObject(_workShiftsKey, _workShifts);
      notify();
    }
  }

  void updateStaticShiftColor(String id, Color newColor) {
    if (id == _sickLeaveShift.id) {
      _sickLeaveShift = WorkShift.copy(_sickLeaveShift)..color = newColor;
      StorageService.setInt(_sickLeaveShiftKey, _sickLeaveShift.color.toARGB32());
    } else if (id == _vacationShift.id) {
      _vacationShift = WorkShift.copy(_vacationShift)..color = newColor;
      StorageService.setInt(_vacationShiftKey, _vacationShift.color.toARGB32());
    }
    notify();
  }

  void removeWorkShift(String id) {
    _workShifts.removeWhere((shift) => shift.id == id);
    StorageService.setObject(_workShiftsKey, _workShifts);
    notify();
  }
}

class SettingsProvider
  extends BaseSettingsMixin
  with ChangeNotifier,
    ShiftNameSettingsMixin,
    ScheduleSettingsMixin,
    WorkShiftSettingsMixin
{
  static SettingsProvider? _instance;
  static SettingsProvider get instance {
    if (_instance == null) {
      throw Exception('SettingsProvider not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<SettingsProvider> initialize() async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = SettingsProvider();
    await _instance!._loadFromStorage();
    return _instance!;
  }

  SettingsProvider() {
    if (_instance != null) {
      throw Exception('SettingsProvider already initialized.');
    }
  }

  static bool get isInitialized => _instance != null;

  @override
  void notify() {
    notifyListeners();
  }

  Future<void> _loadFromStorage() async {
    await _loadShiftNameFromStorage();
    await _loadSchedulesFromStorage();
    await _loadShiftsSettingsFromStorage();
  }
}