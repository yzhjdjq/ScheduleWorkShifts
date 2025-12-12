import 'package:sws/models/models.dart' show ScheduleException;
import 'package:sws/services/services.dart' show StorageService;

class ScheduleExceptionRepository {
  static const String _key = 'scheduleExceptions';

  Future<List<ScheduleException>> loadAll({List<ScheduleException> defaultValue = const []}) async {
    if (!StorageService.containsKey(_key)) {
      await StorageService.setObject(_key, defaultValue);
    }

    final loaded = StorageService.getObjectList<ScheduleException>(_key, fromJson: ScheduleException.fromJson);
    return loaded ?? defaultValue;
  }

  Future<void> saveAll(List<ScheduleException> scheduleExceptions) async {
    await StorageService.setObject(_key, scheduleExceptions);
  }

  Future<void> clear() async {
    await StorageService.remove(_key);
  }
}