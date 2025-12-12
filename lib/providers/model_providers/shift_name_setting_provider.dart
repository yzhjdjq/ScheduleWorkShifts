import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:sws/repositories/repositories.dart' show ShiftNameSettingRepository;

class ShiftNameSettingProvider with ChangeNotifier {
  static ShiftNameSettingProvider? _instance;
  static ShiftNameSettingProvider get instance {
    if (_instance == null) {
      throw Exception('ShiftNameSettingProvider is not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<ShiftNameSettingProvider> initialize() async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = ShiftNameSettingProvider();
    await _instance!._loadDataFromRepository();
    return _instance!;
  }

  ShiftNameSettingProvider() {
    if (_instance != null) {
      throw Exception('ShiftNameSettingProvider is already initialized.');
    }
  }

  static bool get isInitialized => _instance != null;

  static final ShiftNameSettingRepository _shiftNameSettingRepo = ShiftNameSettingRepository();
  static bool _showShiftName = true;

  Future<void> _loadDataFromRepository() async {
    _showShiftName = await _shiftNameSettingRepo.load(defaultValue: _showShiftName);
  }

  bool get showShiftName => _showShiftName;
  set showShiftName(bool value) {
    if (_showShiftName != value) {
      _showShiftName = value;
      _shiftNameSettingRepo.save(value);
      notifyListeners();
    }
  }
}