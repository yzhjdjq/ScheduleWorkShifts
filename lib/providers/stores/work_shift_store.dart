import 'dart:ui' show Color;

import 'package:flutter/material.dart' show ChangeNotifier, Colors;
import 'package:sws/models/models.dart' show ShiftCategory, WorkShift;
import 'package:sws/services/services.dart' show StorageService;
import 'package:uuid/uuid.dart' show Uuid;

class WorkShiftStore with ChangeNotifier {
  static WorkShiftStore? _instance;
  static WorkShiftStore get instance {
    if (_instance == null) {
      throw Exception('WorkShiftStore not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<WorkShiftStore> initialize() async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = WorkShiftStore();
    await _instance!._loadFromStorage();
    return _instance!;
  }

  WorkShiftStore() {
    if (_instance != null) {
      throw Exception('WorkShiftStore is already initialized.');
    }
  }

  static bool get isInitialized => _instance != null;

  static const String _workShiftsKey = 'workShifts';
  static const String _vacationShiftKey = 'vacationShift';
  static const String _sickLeaveShiftKey = 'sickLeaveShift';
  static List<WorkShift> _workShifts = [];
  static WorkShift _vacationShift = WorkShift.vacation();
  static WorkShift _sickLeaveShift = WorkShift.sickLeave();

  void _ensureMinimumWorkShifts() {
    _workShifts.add(WorkShift.createDefault());
    _workShifts.add(
      WorkShift(id: const Uuid().v4(), name: 'Выходной', category: ShiftCategory.dayOff, color: Colors.green),
    );
  }

  Future<void> _loadFromStorage() async {
    if (!StorageService.containsKey(_workShiftsKey) ||
        (StorageService.getObjectList<WorkShift>(_workShiftsKey, fromJson: WorkShift.fromJson)?.isEmpty ?? true)) {
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
      _vacationShift = _vacationShift.copyWith(color: Color(vacationColorValue));
    }

    if (sickLeaveColorValue != null) {
      _sickLeaveShift = _sickLeaveShift.copyWith(color: Color(sickLeaveColorValue));
    }
  }

  List<WorkShift> get workShifts => List.unmodifiable(_workShifts);

  List<WorkShift> get allWorkShifts => List.unmodifiable([..._workShifts, _vacationShift, _sickLeaveShift]);

  WorkShift get vacationShift => _vacationShift;

  WorkShift get sickLeaveShift => _sickLeaveShift;

  void addWorkShift(WorkShift shift) {
    _workShifts.add(shift);
    StorageService.setObject(_workShiftsKey, _workShifts);
    notifyListeners();
  }

  void updateWorkShift(WorkShift newShift) {
    final int index = _workShifts.indexWhere((shift) => shift.id == newShift.id);

    if (index != -1) {
      _workShifts[index] = newShift;
      StorageService.setObject(_workShiftsKey, _workShifts);
      notifyListeners();
    }
  }

  void updateStaticShiftColor(String id, Color newColor) {
    if (id == _sickLeaveShift.id) {
      _sickLeaveShift = _sickLeaveShift.copyWith(color: newColor);
      StorageService.setInt(_sickLeaveShiftKey, _sickLeaveShift.color.toARGB32());
    } else if (id == _vacationShift.id) {
      _vacationShift = _vacationShift.copyWith(color: newColor);
      StorageService.setInt(_vacationShiftKey, _vacationShift.color.toARGB32());
    }
    notifyListeners();
  }

  void removeWorkShift(String id) {
    _workShifts.removeWhere((shift) => shift.id == id);
    StorageService.setObject(_workShiftsKey, _workShifts);
    notifyListeners();
  }
}
