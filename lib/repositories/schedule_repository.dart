import 'package:sws/models/models.dart' show Schedule;
import 'package:sws/services/services.dart' show StorageService;

class ScheduleRepository {
  static const String _key = 'schedules';

  Future<List<Schedule>> loadAll({List<Schedule> defaultValue = const []}) async {
    if (!StorageService.containsKey(_key)) {
      await StorageService.setObject(_key, defaultValue);
    }

    final loaded = StorageService.getObjectList<Schedule>(_key, fromJson: Schedule.fromJson);
    return loaded ?? defaultValue;
  }

  Future<void> saveAll(List<Schedule> schedules) async {
    await StorageService.setObject(_key, schedules);
  }

  Future<void> clear() async {
    await StorageService.remove(_key);
  }
}