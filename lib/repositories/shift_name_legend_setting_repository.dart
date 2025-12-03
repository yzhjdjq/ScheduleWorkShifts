import 'package:sws/services/services.dart' show StorageService;

class ShiftNameLegendSettingRepository {
  static const String _key = 'showShiftNameLegend';

  Future<bool> load({bool defaultValue = true}) async {
    if (!StorageService.containsKey(_key)) {
      await StorageService.setBool(_key, defaultValue);
    }

    final loaded = StorageService.getBool(_key);
    return loaded ?? defaultValue;
  }

  Future<void> save(bool value) async {
    await StorageService.setBool(_key, value);
  }

  Future<void> clear() async {
    await StorageService.remove(_key);
  }
}