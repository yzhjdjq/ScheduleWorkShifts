import 'package:sws/models/models.dart' show ShiftSequence;
import 'package:sws/services/services.dart' show StorageService;

class ShiftSequenceRepository {
  static const String _key = 'shiftSequence';

  Future<List<ShiftSequence>> loadAll({List<ShiftSequence> defaultValue = const []}) async {
    if (!StorageService.containsKey(_key)) {
      await StorageService.setObject(_key, defaultValue);
    }

    final loaded = StorageService.getObjectList<ShiftSequence>(_key, fromJson: ShiftSequence.fromJson);
    return loaded ?? defaultValue;
  }

  Future<void> saveAll(List<ShiftSequence> shiftSequences) async {
    await StorageService.setObject(_key, shiftSequences);
  }

  Future<void> clear() async {
    await StorageService.remove(_key);
  }
}