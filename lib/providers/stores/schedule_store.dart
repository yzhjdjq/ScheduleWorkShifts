import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:sws/models/models.dart' show Schedule;
import 'package:sws/services/services.dart' show StorageService;

class ScheduleStore with ChangeNotifier {
  static ScheduleStore? _instance;
  static ScheduleStore get instance {
    if (_instance == null) {
      throw Exception('ScheduleStore is not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<ScheduleStore> initialize() async {
  if (_instance != null) {
  return _instance!;
  }

  _instance = ScheduleStore();
  await _instance!._loadFromStorage();
  return _instance!;
  }

  ScheduleStore() {
    if (_instance != null) {
      throw Exception('ScheduleStore is already initialized.');
    }
  }

  static bool get isInitialized => _instance != null;

  static const String _scheduleKey = 'schedules';
  static List<Schedule> _schedules = [];

  Future<void> _loadFromStorage() async {
    if (!StorageService.containsKey(_scheduleKey)) {
      await StorageService.setObject(_scheduleKey, _schedules);
    }

    _schedules = StorageService.getObjectList<Schedule>(_scheduleKey, fromJson: Schedule.fromJson) ?? [];
  }

  List<Schedule> get schedules => List.unmodifiable(_schedules);

  void addSchedule(Schedule schedule) {
    _schedules.add(schedule);
    StorageService.setObject(_scheduleKey, _schedules);
    notifyListeners();
  }

  void updateSchedule(Schedule newSchedule) {
    final int index = _schedules.indexWhere((schedule) => schedule.id == newSchedule.id);

    if (index != -1) {
      _schedules[index] = newSchedule;
      StorageService.setObject(_scheduleKey, _schedules);
      notifyListeners();
    }
  }

  void removeSchedule(String id) {
    _schedules.removeWhere((schedule) => schedule.id == id);
    StorageService.setObject(_scheduleKey, _schedules);
    notifyListeners();
  }
}
