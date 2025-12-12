import 'package:sws/models/models.dart' show WorkShift;
import 'package:sws/services/services.dart' show StorageService;

class WorkShiftRepository {
  static const String _key = 'workShifts';

  Future<List<WorkShift>> loadAll({List<WorkShift> defaultValue = const []}) async {
    if (!StorageService.containsKey(_key)) {
      await StorageService.setObject(_key, defaultValue);
    }

    final loaded = StorageService.getObjectList<WorkShift>(_key, fromJson: WorkShift.fromJson);
    return loaded ?? defaultValue;
  }

  Future<void> saveAll(List<WorkShift> workShifts) async {
    await StorageService.setObject(_key, workShifts);
  }

  Future<void> clear() async {
    await StorageService.remove(_key);
  }
}