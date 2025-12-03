import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:sws/models/models.dart' show ActiveSchedules;
import 'package:sws/repositories/repositories.dart' show ActiveSchedulesRepository;

class ActiveSchedulesProvider with ChangeNotifier {
  static ActiveSchedulesProvider? _instance;
  static ActiveSchedulesProvider get instance {
    if (_instance == null) {
      throw Exception('ActiveSchedulesProvider is not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<ActiveSchedulesProvider> initialize() async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = ActiveSchedulesProvider._internal();
    await _instance!._loadDataFromRepository();
    return _instance!;
  }

  ActiveSchedulesProvider._internal() {
    if (_instance != null) {
      throw Exception('ActiveSchedulesProvider is already initialized.');
    }
  }

  static bool get isInitialized => _instance != null;

  final ActiveSchedulesRepository _activeSchedulesRepo = ActiveSchedulesRepository();
  static ActiveSchedules _activeSchedules = const ActiveSchedules(activeScheduleId: null);

  Future<void> _loadDataFromRepository() async {
    _activeSchedules = await _activeSchedulesRepo.loadAll(defaultValue: _activeSchedules);
  }

  void _saveDataToRepository() async {
    await _activeSchedulesRepo.saveAll(_activeSchedules);
    notifyListeners();
  }

  bool get hasActiveSchedule => _activeSchedules.activeScheduleId != null;

  bool get hasComparedSchedule => _activeSchedules.comparedScheduleId != null;

  String? get activeScheduleId => _activeSchedules.activeScheduleId;

  String? get comparedScheduleId => _activeSchedules.comparedScheduleId;

  void setActiveScheduleId(String activeScheduleId) {
    _activeSchedules = _activeSchedules.copyWith(activeScheduleId: activeScheduleId);
    _saveDataToRepository();
  }

  void setComparedScheduleIds(String activeScheduleId, String comparedScheduleId) {
    _activeSchedules = _activeSchedules.copyWith(activeScheduleId: activeScheduleId, comparedScheduleId: comparedScheduleId);
    _saveDataToRepository();
  }
}