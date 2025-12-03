import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:sws/models/models.dart' show ScheduleException;
import 'package:sws/providers/model_providers/model_providers.dart' show WorkingTimeViewModel;
import 'package:sws/repositories/repositories.dart' show ScheduleExceptionRepository;

class ScheduleExceptionProvider with ChangeNotifier {
  static ScheduleExceptionProvider? _instance;
  static ScheduleExceptionProvider get instance {
    if (_instance == null) {
      throw Exception('ScheduleExceptionProvider not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<ScheduleExceptionProvider> initialize() async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = ScheduleExceptionProvider();
    await _instance!._loadDataFromRepository();
    return _instance!;
  }

  ScheduleExceptionProvider() {
    if (_instance != null) {
      throw Exception('ScheduleExceptionProvider is already initialized.');
    }
  }

  static bool get isInitialized => _instance != null;

  static final ScheduleExceptionRepository _scheduleExceptionRepository = ScheduleExceptionRepository();
  static List<ScheduleException> _scheduleExceptions = [];

  Future<void> _loadDataFromRepository() async {
    _scheduleExceptions = await _scheduleExceptionRepository.loadAll(defaultValue: _scheduleExceptions);
  }

  List<ScheduleExceptionItemViewModel> get scheduleExceptions =>
      List<ScheduleException>.unmodifiable(
        _scheduleExceptions,
      ).map((se) => ScheduleExceptionItemViewModel.fromScheduleException(se)).toList();

  List<ScheduleExceptionItemViewModel> getExceptionsForSchedule(String scheduleId) {
    final List<ScheduleException> exceptions = _scheduleExceptions.where((se) => se.scheduleId == scheduleId).toList();
    return exceptions.map((se) => ScheduleExceptionItemViewModel.fromScheduleException(se)).toList();
  }

  void addScheduleException(ScheduleExceptionItemViewModel exceptionItem) {
    final exception = ScheduleException(
      id: exceptionItem.id,
      scheduleId: exceptionItem.scheduleId,
      workShiftId: exceptionItem.workShiftId,
      startDate: exceptionItem.startDate,
      endDate: exceptionItem.endDate,
      workingTime: exceptionItem.workingTime?.toWorkingTime(),
    );
    _scheduleExceptions.add(exception);
    _saveScheduleExceptions();
  }

  void updateScheduleException(ScheduleExceptionItemViewModel exceptionItem) {
    final scheduleException = ScheduleException(
      id: exceptionItem.id,
      scheduleId: exceptionItem.scheduleId,
      workShiftId: exceptionItem.workShiftId,
      startDate: exceptionItem.startDate,
      endDate: exceptionItem.endDate,
      workingTime: exceptionItem.workingTime?.toWorkingTime(),
    );
    _scheduleExceptions.removeWhere((se) => se.id == exceptionItem.id);
    _scheduleExceptions.add(scheduleException);
    _saveScheduleExceptions();
  }

  void removeScheduleException(String id) {
    _scheduleExceptions.removeWhere((exception) => exception.id == id);
    _saveScheduleExceptions();
  }

  void removeExceptionsForSchedule(String scheduleId) {
    _scheduleExceptions.removeWhere((e) => e.scheduleId == scheduleId);
    _saveScheduleExceptions();
  }

  void removeExceptionsForShift(String shiftId) {
    _scheduleExceptions.removeWhere((e) => e.workShiftId == shiftId);
    _saveScheduleExceptions();
  }

  void _saveScheduleExceptions() {
    _scheduleExceptionRepository.saveAll(_scheduleExceptions);
    notifyListeners();
  }

  ScheduleExceptionItemViewModel? getExceptionForDate(DateTime date, String scheduleId) {
    final ScheduleException? exception = _scheduleExceptions.firstWhereOrNull(
      (exception) =>
          exception.scheduleId == scheduleId && !date.isBefore(exception.startDate) && !date.isAfter(exception.endDate),
    );
    return exception != null ? ScheduleExceptionItemViewModel.fromScheduleException(exception) : null;
  }

  bool hasExceptionForDate(DateTime date, String scheduleId) {
    return _scheduleExceptions.any(
      (exception) =>
          exception.scheduleId == scheduleId && !date.isBefore(exception.startDate) && !date.isAfter(exception.endDate),
    );
  }
}

class ScheduleExceptionItemViewModel {
  final String id;
  final String scheduleId;
  final String workShiftId;
  final DateTime startDate;
  final DateTime endDate;
  final WorkingTimeViewModel? workingTime;

  ScheduleExceptionItemViewModel({
    required this.id,
    required this.scheduleId,
    required this.workShiftId,
    required this.startDate,
    required this.endDate,
    this.workingTime,
  });

  static ScheduleExceptionItemViewModel fromScheduleException(ScheduleException scheduleException) {
    return ScheduleExceptionItemViewModel(
      id: scheduleException.id,
      scheduleId: scheduleException.scheduleId,
      workShiftId: scheduleException.workShiftId,
      startDate: scheduleException.startDate,
      endDate: scheduleException.endDate,
      workingTime:
          scheduleException.workingTime != null
              ? WorkingTimeViewModel.fromWorkingTime(scheduleException.workingTime!)
              : null,
    );
  }

  ScheduleExceptionItemViewModel copyWith({
    String? scheduleId,
    String? workShiftId,
    DateTime? startDate,
    DateTime? endDate,
    WorkingTimeViewModel? workingTime,
  }) {
    return ScheduleExceptionItemViewModel(
      id: id,
      scheduleId: scheduleId ?? this.scheduleId,
      workShiftId: workShiftId ?? this.workShiftId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      workingTime: workingTime ?? this.workingTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ScheduleExceptionItemViewModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              scheduleId == other.scheduleId &&
              workShiftId == other.workShiftId &&
              startDate.year == other.startDate.year &&
              startDate.month == other.startDate.month &&
              startDate.day == other.startDate.day &&
              endDate.year == other.endDate.year &&
              endDate.month == other.endDate.month &&
              endDate.day == other.endDate.day &&
              workingTime == other.workingTime;

  @override
  int get hashCode => Object.hash(
    id,
    scheduleId,
    workShiftId,
    startDate.year,
    startDate.month,
    startDate.day,
    endDate.year,
    endDate.month,
    endDate.day,
    workingTime,
  );
}
