import 'dart:ui' show Color;

import 'package:collection/collection.dart' show IterableExtension;
import 'package:sws/providers/model_providers/model_providers.dart'
    show
        ActiveSchedulesProvider,
        ScheduleExceptionItemViewModel,
        ScheduleExceptionProvider,
        ScheduleItemViewModel,
        ScheduleProvider,
        ShiftSequenceProvider,
        WorkShiftItemViewModel,
        WorkShiftProvider,
        WorkingTimeViewModel;
import 'package:uuid/uuid.dart' show Uuid;

/// A centralized business logic service responsible for coordinating operations across multiple data providers
/// related to work schedules. It encapsulates cross-cutting concerns such as managing dependencies between
/// schedules, shift sequences, exceptions, and active schedule state.
///
/// This service acts as a facade to simplify interactions between UI components and underlying providers,
/// ensuring consistency and integrity when performing operations that affect multiple models (e.g., removing
/// a schedule and automatically cleaning up related shift sequences and exceptions).
class ScheduleService {
  static ScheduleService? _instance;
  static ScheduleService get instance {
    if (_instance == null) {
      throw Exception(
        'ScheduleService is not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  static Future<ScheduleService> initialize({
    required ActiveSchedulesProvider activeSchedulesProvider,
    required ScheduleExceptionProvider scheduleExceptionProvider,
    required ScheduleProvider scheduleProvider,
    required ShiftSequenceProvider shiftSequenceProvider,
    required WorkShiftProvider workShiftProvider,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = ScheduleService._internal(
      activeSchedulesProvider,
      scheduleExceptionProvider,
      scheduleProvider,
      shiftSequenceProvider,
      workShiftProvider,
    );
    return _instance!;
  }

  ScheduleService._internal(
    this._activeSchedulesProvider,
    this._scheduleExceptionProvider,
    this._scheduleProvider,
    this._shiftSequenceProvider,
    this._workShiftProvider,
  ) {
    if (_instance != null) {
      throw Exception('ScheduleService is already initialized.');
    }
  }

  static bool get isInitialized => _instance != null;

  final ActiveSchedulesProvider _activeSchedulesProvider;
  final ScheduleExceptionProvider _scheduleExceptionProvider;
  final ScheduleProvider _scheduleProvider;
  final ShiftSequenceProvider _shiftSequenceProvider;
  final WorkShiftProvider _workShiftProvider;

  ScheduleItemViewModel? get activeSchedule {
    if (!_activeSchedulesProvider.hasActiveSchedule) {
      return null;
    }

    final activeScheduleId = _activeSchedulesProvider.activeScheduleId!;

    if (!_scheduleProvider.hasSchedule(activeScheduleId)) {
      final firstSchedule = _scheduleProvider.schedules.firstOrNull;

      if (firstSchedule != null &&
          _shiftSequenceProvider.hasShiftSequencesForSchedule(
            firstSchedule.id,
          )) {
        _activeSchedulesProvider.setActiveScheduleId(firstSchedule.id);
      }

      return firstSchedule;
    }

    return _scheduleProvider.getScheduleById(activeScheduleId);
  }

  List<ScheduleItemViewModel> get comparedSchedules {
    if (!_activeSchedulesProvider.hasComparedSchedule) return [];
    if (activeSchedule == null) return [];

    final comparedScheduleId = _activeSchedulesProvider.comparedScheduleId!;

    if (_scheduleProvider.hasSchedule(comparedScheduleId)) {
      return [
        activeSchedule!,
        _scheduleProvider.getScheduleById(comparedScheduleId),
      ];
    }

    return [activeSchedule!];
  }

  List<ScheduleItemViewModel> get configuredSchedules {
    return _scheduleProvider.schedules.where((s) {
      return _shiftSequenceProvider.shiftSequences.any(
        (ss) => ss.scheduleId == s.id,
      );
    }).toList();
  }

  bool hasExceptionForDateByActiveSchedule(DateTime date) {
    final activeSchedule = this.activeSchedule;
    if (activeSchedule == null) return false;
    return _scheduleExceptionProvider.hasExceptionForDate(
      date,
      activeSchedule.id,
    );
  }

  bool isNotStaticShiftScheduleException(
    ScheduleExceptionItemViewModel scheduleException,
  ) {
    final workShift = _workShiftProvider.allWorkShifts.firstWhere(
      (ws) => ws.id == scheduleException.workShiftId,
    );
    if (!workShift.isStatic()) return true;
    return false;
  }

  ScheduleExceptionItemViewModel? getExceptionForDateByActiveSchedule(
    DateTime date,
  ) {
    final activeSchedule = this.activeSchedule;
    if (activeSchedule == null) return null;
    return _scheduleExceptionProvider.getExceptionForDate(
      date,
      activeSchedule.id,
    );
  }

  List<Color> getColorsForActiveSchedule(DateTime forMonth) {
    if (activeSchedule == null) {
      return [];
    }

    return _shiftSequenceProvider.getColorsForSchedule(
      activeSchedule!.id,
      _workShiftProvider.workShifts,
      forMonth,
    );
  }

  List<List<Color>> getColorsForComparison(DateTime forMonth) {
    if (comparedSchedules.isEmpty) {
      return [[], []];
    }
    final comparedScheduleIds = comparedSchedules.map((e) => e.id).toList();
    final firstColors = _shiftSequenceProvider.getColorsForSchedule(
      comparedScheduleIds[0],
      _workShiftProvider.workShifts,
      forMonth,
    );
    final secondColors = _shiftSequenceProvider.getColorsForSchedule(
      comparedScheduleIds[1],
      _workShiftProvider.workShifts,
      forMonth,
    );

    return [firstColors, secondColors];
  }

  List<WorkShiftItemViewModel> getUsedShiftsInSchedule(String scheduleId) {
    final usedShiftIds =
        _shiftSequenceProvider.shiftSequences
            .where((seq) => seq.scheduleId == scheduleId)
            .map((seq) => seq.workShiftId)
            .toSet();

    return _workShiftProvider.workShifts
        .where((shift) => usedShiftIds.contains(shift.id))
        .toList();
  }

  WorkingTimeViewModel getWorkingTimeForWorkShiftInActiveSchedule(
    WorkShiftItemViewModel workShift,
  ) {
    final activeSchedule = this.activeSchedule;
    if (activeSchedule == null) return WorkingTimeViewModel();
    return _shiftSequenceProvider.shiftSequences
            .firstWhereOrNull((ss) => ss.workShiftId == workShift.id)
            ?.workingTime ??
        WorkingTimeViewModel();
  }

  void addScheduleExceptionForDay(
    WorkShiftItemViewModel workShift,
    DateTime date,
    WorkingTimeViewModel workingTime,
  ) {
    final activeSchedule = this.activeSchedule;
    if (activeSchedule == null) return;
    final scheduleException = ScheduleExceptionItemViewModel(
      id: Uuid().v4(),
      scheduleId: activeSchedule.id,
      workShiftId: workShift.id,
      startDate: date,
      endDate: date,
      workingTime: workingTime,
    );
    _scheduleExceptionProvider.addScheduleException(scheduleException);
  }

  void addVacation(String scheduleId, DateTime startDate, DateTime endDate) {
    if (!_scheduleProvider.hasSchedule(scheduleId)) return;
    final vacationException = ScheduleExceptionItemViewModel(
      id: Uuid().v4(),
      scheduleId: scheduleId,
      workShiftId: _workShiftProvider.vacationShift.id,
      startDate: startDate,
      endDate: endDate,
      workingTime: WorkingTimeViewModel(),
    );
    _scheduleExceptionProvider.addScheduleException(vacationException);
  }

  void addSickLeave(String scheduleId, DateTime startDate, DateTime endDate) {
    if (!_scheduleProvider.hasSchedule(scheduleId)) return;
    final sickLeaveException = ScheduleExceptionItemViewModel(
      id: Uuid().v4(),
      scheduleId: scheduleId,
      workShiftId: _workShiftProvider.sickLeaveShift.id,
      startDate: startDate,
      endDate: endDate,
      workingTime: WorkingTimeViewModel(),
    );
    _scheduleExceptionProvider.addScheduleException(sickLeaveException);
  }

  void removeSchedule(String scheduleId) {
    if (_activeSchedulesProvider.hasActiveSchedule &&
        _activeSchedulesProvider.activeScheduleId == scheduleId) {
      if (_activeSchedulesProvider.hasComparedSchedule) {
        _activeSchedulesProvider.setActiveScheduleId(
          _activeSchedulesProvider.comparedScheduleId!,
        );
      } else {
        final activeSchedule = _scheduleProvider.schedules.firstWhereOrNull(
          (s) => s.id != scheduleId,
        );
        if (activeSchedule == null) {
          _activeSchedulesProvider.resetActiveSchedules();
        } else {
          _activeSchedulesProvider.setActiveScheduleId(activeSchedule.id);
        }
      }
    }
    if (_activeSchedulesProvider.hasComparedSchedule &&
        _activeSchedulesProvider.comparedScheduleId == scheduleId) {
      _activeSchedulesProvider.setActiveScheduleId(
        _activeSchedulesProvider.activeScheduleId!,
      );
    }
    _scheduleProvider.removeSchedule(scheduleId);
    _shiftSequenceProvider.removeSequencesForSchedule(scheduleId);
    _scheduleExceptionProvider.removeExceptionsForSchedule(scheduleId);
  }

  void removeWorkShift(String shiftId) {
    _workShiftProvider.removeWorkShift(shiftId);
    _shiftSequenceProvider.removeSequencesForShift(shiftId);
    _scheduleExceptionProvider.removeExceptionsForShift(shiftId);
  }
}
