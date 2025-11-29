import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:sws/models/schedule_exception.dart' show ScheduleException;
import 'package:sws/services/storage_service.dart' show StorageService;

class ScheduleExceptionStore with ChangeNotifier {
  static ScheduleExceptionStore? _instance;
  static ScheduleExceptionStore get instance {
    if (_instance == null) {
      throw Exception('ScheduleExceptionStore not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<ScheduleExceptionStore> initialize() async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = ScheduleExceptionStore();
    await _instance!._loadFromStorage();
    return _instance!;
  }

  ScheduleExceptionStore() {
    if (_instance != null) {
      throw Exception('ScheduleExceptionStore is already initialized.');
    }
  }

  static bool get isInitialized => _instance != null;

  static const String _scheduleExceptionsKey = 'scheduleExceptions';
  static List<ScheduleException> _scheduleExceptions = [];

  Future<void> _loadFromStorage() async {
    if (!StorageService.containsKey(_scheduleExceptionsKey)) {
      await StorageService.setObject(_scheduleExceptionsKey, _scheduleExceptions);
    }

    _scheduleExceptions =
        StorageService.getObjectList<ScheduleException>(_scheduleExceptionsKey, fromJson: ScheduleException.fromJson) ??
        [];
  }

  List<ScheduleException> get scheduleExceptions => List<ScheduleException>.unmodifiable(_scheduleExceptions);

  List<ScheduleException> getExceptionsForSchedule(String scheduleId) {
    return _scheduleExceptions.where((e) => e.scheduleId == scheduleId).toList();
  }

  void addScheduleException(ScheduleException exception) {
    _scheduleExceptions.add(exception);
    _saveScheduleExceptions();
  }

  void removeScheduleException(String id) {
    _scheduleExceptions.removeWhere((exception) => exception.id == id);
    _saveScheduleExceptions();
  }

  void removeExceptionsForSchedule(String scheduleId) {
    _scheduleExceptions.removeWhere((e) => e.scheduleId == scheduleId);
    _saveScheduleExceptions();
  }

  void removeExceptionsForShift(String shiftId) {
    _scheduleExceptions.removeWhere((e) => e.workShiftId == shiftId);
    _saveScheduleExceptions();
  }

  void _saveScheduleExceptions() {
    StorageService.setObject(_scheduleExceptionsKey, _scheduleExceptions);
    notifyListeners();
  }

  ScheduleException? getExceptionForDate(DateTime date, String scheduleId) {
    return _scheduleExceptions.firstWhereOrNull(
      (exception) =>
          exception.scheduleId == scheduleId && !date.isBefore(exception.startDate) && !date.isAfter(exception.endDate),
    );
  }

  bool hasExceptionForDate(DateTime date, String scheduleId) {
    return _scheduleExceptions.any(
      (exception) =>
          exception.scheduleId == scheduleId && !date.isBefore(exception.startDate) && !date.isAfter(exception.endDate),
    );
  }
}
