import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:sws/models/models.dart' show Schedule;
import 'package:sws/repositories/repositories.dart' show ScheduleRepository;
import 'package:uuid/uuid.dart' show Uuid;

class ScheduleProvider with ChangeNotifier {
  static ScheduleProvider? _instance;
  static ScheduleProvider get instance {
    if (_instance == null) {
      throw Exception('ScheduleProvider is not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<ScheduleProvider> initialize() async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = ScheduleProvider();
    await _instance!._loadDataFromRepository();
    return _instance!;
  }

  ScheduleProvider() {
    if (_instance != null) {
      throw Exception('ScheduleProvider is already initialized.');
    }
  }

  static bool get isInitialized => _instance != null;

  final ScheduleRepository _scheduleRepo = ScheduleRepository();
  static List<Schedule> _schedules = [];

  Future<void> _loadDataFromRepository() async {
    _schedules = await _scheduleRepo.loadAll();
  }

  List<ScheduleItemViewModel> get schedules =>
      List.unmodifiable(_schedules).map((s) => ScheduleItemViewModel.fromSchedule(s)).toList();

  ScheduleItemViewModel getScheduleById(String id) =>
      ScheduleItemViewModel.fromSchedule(_schedules.firstWhere((s) => s.id == id));

  void addSchedule(ScheduleItemViewModel scheduleItem) {
    final schedule = Schedule(id: scheduleItem.id, name: scheduleItem.name, startDate: scheduleItem.startDate);
    _schedules.add(schedule);
    _scheduleRepo.saveAll(_schedules);
    notifyListeners();
  }

  void updateSchedule(ScheduleItemViewModel newScheduleItem) {
    final int index = _schedules.indexWhere((schedule) => schedule.id == newScheduleItem.id);

    if (index != -1) {
      final newSchedule = Schedule(
        id: newScheduleItem.id,
        name: newScheduleItem.name,
        startDate: newScheduleItem.startDate,
      );
      _schedules[index] = newSchedule;
      _scheduleRepo.saveAll(_schedules);
      notifyListeners();
    }
  }

  void removeSchedule(String id) {
    _schedules.removeWhere((schedule) => schedule.id == id);
    _scheduleRepo.saveAll(_schedules);
    notifyListeners();
  }

  bool hasSchedule(String scheduleId) => _schedules.any((s) => s.id == scheduleId);

  bool hasSchedules() => _schedules.isNotEmpty;

  DateTime? getFirstDayOfSchedule(String scheduleId) {
    final schedule = _schedules.firstWhereOrNull((s) => s.id == scheduleId);
    return schedule?.startDate;
  }

  int getDayOffsetForSchedule(String scheduleId, DateTime day) {
    final firstDay = getFirstDayOfSchedule(scheduleId);
    if (firstDay == null) return day.day - 1;

    final difference = day.difference(firstDay).inDays;
    return difference;
  }
}

class ScheduleItemViewModel {
  final String id;
  final String name;
  final DateTime startDate;

  ScheduleItemViewModel({required this.id, required this.name, required this.startDate});

  static ScheduleItemViewModel fromSchedule(Schedule schedule) {
    return ScheduleItemViewModel(id: schedule.id, name: schedule.name, startDate: schedule.startDate);
  }

  static ScheduleItemViewModel createDefault() {
    return ScheduleItemViewModel(
      id: const Uuid().v4(),
      name: 'График',
      startDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );
  }

  ScheduleItemViewModel copyWith({String? name, DateTime? startDate}) {
    return ScheduleItemViewModel(id: id, name: name ?? this.name, startDate: startDate ?? this.startDate);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleItemViewModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          startDate.year == other.startDate.year &&
          startDate.month == other.startDate.month &&
          startDate.day == other.startDate.day;

  @override
  int get hashCode => Object.hash(id, name, startDate.year, startDate.month, startDate.day);
}
