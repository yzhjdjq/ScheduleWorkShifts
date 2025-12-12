import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:sws/repositories/repositories.dart' show ShiftNameLegendSettingRepository;

class ShiftNameLegendSettingProvider with ChangeNotifier {
  static ShiftNameLegendSettingProvider? _instance;
  static ShiftNameLegendSettingProvider get instance {
    if (_instance == null) {
      throw Exception('ShiftNameLegendSettingProvider is not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<ShiftNameLegendSettingProvider> initialize() async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = ShiftNameLegendSettingProvider();
    await _instance!._loadDataFromRepository();
    return _instance!;
  }

  ShiftNameLegendSettingProvider() {
    if (_instance != null) {
      throw Exception('ShiftNameLegendSettingProvider is already initialized.');
    }
  }

  static bool get isInitialized => _instance != null;

  static final ShiftNameLegendSettingRepository _shiftNameLegendSettingRepo = ShiftNameLegendSettingRepository();
  static bool _showShiftNameLegend = true;

  Future<void> _loadDataFromRepository() async {
    _showShiftNameLegend = await _shiftNameLegendSettingRepo.load(defaultValue: _showShiftNameLegend);
  }

  bool get showShiftNameLegend => _showShiftNameLegend;
  set showShiftNameLegend(bool value) {
    if (_showShiftNameLegend != value) {
      _showShiftNameLegend = value;
      _shiftNameLegendSettingRepo.save(_showShiftNameLegend);
      notifyListeners();
    }
  }
}