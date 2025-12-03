import 'package:sws/models/models.dart' show ActiveSchedules;
import 'package:sws/services/services.dart' show StorageService;

class ActiveSchedulesRepository {
  static const String _key = 'activeSchedules';

  Future<ActiveSchedules> loadAll({ActiveSchedules defaultValue = const ActiveSchedules(activeScheduleId: null)}) async {
    if (!StorageService.containsKey(_key)) {
      await StorageService.setObject(_key, defaultValue);
    }

    final loaded = StorageService.getObject(_key, fromJson: ActiveSchedules.fromJson);
    return loaded ?? defaultValue;
  }

  Future<void> saveAll(ActiveSchedules value) async {
    await StorageService.setObject(_key, value);
  }

  Future<void> clear() async {
    await StorageService.remove(_key);
  }
}