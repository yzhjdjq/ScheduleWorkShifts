import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:sws/providers/model_providers/model_providers.dart'
    show ShiftNameLegendSettingProvider, ShiftNameSettingProvider;
import 'package:sws/services/services.dart' show WidgetService;

class SettingsPageProvider with ChangeNotifier {
  static SettingsPageProvider? _instance;
  static SettingsPageProvider get instance {
    if (_instance == null) {
      throw Exception(
        'SettingsPageProvider not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  static Future<SettingsPageProvider> initialize({
    required ShiftNameLegendSettingProvider shiftNameLegendSettingProvider,
    required ShiftNameSettingProvider shiftNameSettingProvider,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = SettingsPageProvider._internal(
      shiftNameLegendSettingProvider,
      shiftNameSettingProvider,
    );
    return _instance!;
  }

  SettingsPageProvider._internal(
    this._shiftNameLegendSettingProvider,
    this._shiftNameSettingProvider,
  ) {
    if (_instance != null) {
      throw Exception('SettingsPageProvider already initialized.');
    }

    _shiftNameLegendSettingProvider.addListener(notify);
    _shiftNameSettingProvider.addListener(notify);
  }

  void notify() {
    notifyListeners();
    WidgetService.updateWidget();
  }

  static bool get isInitialized => _instance != null;

  late final ShiftNameLegendSettingProvider _shiftNameLegendSettingProvider;
  late final ShiftNameSettingProvider _shiftNameSettingProvider;

  bool get showShiftNameLegend =>
      _shiftNameLegendSettingProvider.showShiftNameLegend;
  set showShiftNameLegend(bool value) =>
      _shiftNameLegendSettingProvider.showShiftNameLegend = value;

  bool get showShiftName => _shiftNameSettingProvider.showShiftName;
  set showShiftName(bool value) =>
      _shiftNameSettingProvider.showShiftName = value;
}
