import 'package:flutter/material.dart';
import 'package:sws/models/schedule_exception.dart';
import 'package:sws/models/shift_sequence.dart';
import 'package:sws/models/work_shift.dart';
import 'package:sws/providers/settings_provider.dart' show SettingsProvider;
import 'package:sws/services/storage_service.dart';
import 'package:uuid/uuid.dart' show Uuid;

abstract class BaseScheduleMixin {
  void notify();
}

mixin ScheduleSequenceMixin on BaseScheduleMixin {
  static const String _shiftSequenceKey = 'shiftSequence';
  static const String _activeScheduleIdKey = 'activeScheduleId'; // Добавляем ключ для сохранения
  List<ShiftSequence> _shiftSequences = [];
  String? _activeScheduleId; // Добавляем поле для активного графика

  Future<void> _loadShiftSequencesFromStorage() async {
    if (!StorageService.containsKey(_shiftSequenceKey)) {
      await StorageService.setObject(_shiftSequenceKey, _shiftSequences);
    }

    _shiftSequences =
        StorageService.getObjectList<ShiftSequence>(_shiftSequenceKey, fromJson: ShiftSequence.fromJson) ?? [];

    // Загружаем активный график из хранилища
    _activeScheduleId = StorageService.getString(_activeScheduleIdKey);
  }

  List<ShiftSequence> get shiftSequences => List.unmodifiable(_shiftSequences);

  void addShiftSequence(ShiftSequence newSequence) {
    _shiftSequences.add(newSequence);
    StorageService.setObject(_shiftSequenceKey, _shiftSequences);
    notify();
  }

  void updateShiftSequence(String id, ShiftSequence newSequence) {
    final int index = _shiftSequences.indexWhere((sequence) => sequence.id == id);

    if (index != -1) {
      _shiftSequences[index] = newSequence;
      StorageService.setObject(_shiftSequenceKey, _shiftSequences);
      notify();
    }
  }

  void removeShiftSequence(String id) {
    _shiftSequences.removeWhere((sequence) => sequence.id == id);
    StorageService.setObject(_shiftSequenceKey, _shiftSequences);
    notify();
  }

  // Устанавливаем активный график
  void setActiveSchedule(String scheduleId) {
    _activeScheduleId = scheduleId;
    StorageService.setString(_activeScheduleIdKey, scheduleId);
    notify();
  }

  // Получаем ID активного графика
  String? getActiveScheduleId() {
    // Если есть сохраненный активный график, используем его
    if (_activeScheduleId != null) {
      // Проверяем, что для этого графика есть последовательности
      final hasSequences = _shiftSequences.any((seq) => seq.scheduleId == _activeScheduleId);
      if (hasSequences) {
        return _activeScheduleId;
      }
    }

    // Ищем первый график с последовательностями
    if (_shiftSequences.isNotEmpty) {
      final firstScheduleId = _shiftSequences.first.scheduleId;
      // Сохраняем найденный график как активный
      _activeScheduleId = firstScheduleId;
      StorageService.setString(_activeScheduleIdKey, firstScheduleId);
      return firstScheduleId;
    }

    return null;
  }

  // Проверить, является ли график активным
  bool isScheduleActive(String scheduleId) {
    return getActiveScheduleId() == scheduleId;
  }

  // Получить цвета для определенного графика и месяца
  List<Color> getColorsForSchedule(String scheduleId, List<WorkShift> workShifts, DateTime forMonth) {
    final sequences = _shiftSequences.where((seq) => seq.scheduleId == scheduleId).toList();

    if (sequences.isEmpty) return [];

    // Сортируем последовательности по orderIndex
    sequences.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    // Получаем общее количество дней в цикле
    final totalCycleDays = sequences.fold(0, (sum, seq) => sum + seq.consecutiveDays);
    if (totalCycleDays == 0) return [];

    // Создаем список цветов для всего цикла
    final cycleColors = <Color>[];
    for (final sequence in sequences) {
      final workShift = workShifts.firstWhere(
        (shift) => shift.id == sequence.workShiftId,
        orElse: () => workShifts.isNotEmpty ? workShifts.first : WorkShift.createDefault(),
      );

      // Добавляем цвет столько раз, сколько consecutiveDays
      for (int i = 0; i < sequence.consecutiveDays; i++) {
        cycleColors.add(workShift.color);
      }
    }

    return cycleColors;
  }

  // Получить первый день активного графика
  DateTime? getFirstDayOfActiveSchedule() {
    final activeScheduleId = getActiveScheduleId();
    if (activeScheduleId == null) return null;

    final sequences = _shiftSequences.where((seq) => seq.scheduleId == activeScheduleId).toList();
    if (sequences.isEmpty) return null;

    sequences.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return sequences.first.startDate;
  }

  // Получить смещение для определенного дня месяца относительно первого рабочего дня
  int getDayOffsetForSchedule(String scheduleId, DateTime day) {
    final firstDay = getFirstDayOfSchedule(scheduleId);
    if (firstDay == null) return day.day - 1; // fallback: начинаем с 1 числа

    // Вычисляем разницу в днях между текущим днем и первым рабочим днем
    final difference = day.difference(firstDay).inDays;
    return difference;
  }

  // Получить первый день для определенного графика
  DateTime? getFirstDayOfSchedule(String scheduleId) {
    final sequences = _shiftSequences.where((seq) => seq.scheduleId == scheduleId).toList();
    if (sequences.isEmpty) return null;

    sequences.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return sequences.first.startDate;
  }

  // Получить общее количество дней в цикле графика
  int getTotalCycleDaysForSchedule(String scheduleId) {
    final sequences = _shiftSequences.where((seq) => seq.scheduleId == scheduleId).toList();
    if (sequences.isEmpty) return 0;

    return sequences.fold(0, (sum, seq) => sum + seq.consecutiveDays);
  }

  // Проверить, есть ли сохраненные графики
  bool get hasSchedules => _shiftSequences.isNotEmpty;
}

mixin ScheduleExceptionMixin on BaseScheduleMixin {
  static const String _scheduleExceptionsKey = 'scheduleExceptions';
  List<ScheduleException> _scheduleExceptions = [];

  Future<void> _loadScheduleExceptionsFromStorage() async {
    if (!StorageService.containsKey(_scheduleExceptionsKey)) {
      await StorageService.setObject(_scheduleExceptionsKey, _scheduleExceptions);
    }

    _scheduleExceptions = StorageService.getObjectList<ScheduleException>(
        _scheduleExceptionsKey,
        fromJson: ScheduleException.fromJson
    ) ?? [];
  }

  List<ScheduleException> get scheduleExceptions => List.unmodifiable(_scheduleExceptions);

  void addScheduleException(ScheduleException exception) {
    _scheduleExceptions.add(exception);
    StorageService.setObject(_scheduleExceptionsKey, _scheduleExceptions);
    notify();
  }

  void removeScheduleException(String id) {
    _scheduleExceptions.removeWhere((exception) => exception.id == id);
    StorageService.setObject(_scheduleExceptionsKey, _scheduleExceptions);
    notify();
  }

  // Получить исключения для определенного дня
  ScheduleException? getExceptionForDate(DateTime date, String scheduleId) {
    return _scheduleExceptions.firstWhere(
          (exception) =>
      exception.scheduleId == scheduleId &&
          !date.isBefore(exception.startDate) &&
          !date.isAfter(exception.endDate),
      orElse: () => ScheduleException(
        id: '',
        scheduleId: '',
        workShiftId: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      ),
    );
  }

  // Проверить, есть ли исключения для даты
  bool hasExceptionForDate(DateTime date, String scheduleId) {
    return _scheduleExceptions.any((exception) =>
    exception.scheduleId == scheduleId &&
        !date.isBefore(exception.startDate) &&
        !date.isAfter(exception.endDate));
  }

  List<ScheduleException> getExceptionsForSchedule(String scheduleId) {
    return _scheduleExceptions.where((exception) => exception.scheduleId == scheduleId).toList();
  }
}


class ScheduleProvider
  extends BaseScheduleMixin
    with ChangeNotifier,
      ScheduleSequenceMixin,
      ScheduleExceptionMixin {
  static ScheduleProvider? _instance;
  static ScheduleProvider get instance {
    if (_instance == null) {
      throw Exception('ScheduleProvider not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<ScheduleProvider> initialize() async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = ScheduleProvider();
    await _instance!._loadFromStorage();
    return _instance!;
  }

  ScheduleProvider() {
    if (_instance != null) {
      throw Exception('ScheduleProvider already initialized.');
    }
  }

  static bool get isInitialized => _instance != null;

  @override
  void notify() {
    notifyListeners();
  }

  static const String _comparedSchedulesKey = 'comparedSchedules';
  List<String> _comparedScheduleIds = [];
  bool _isComparisonMode = false;

  Future<void> _loadComparisonSettingsFromStorage() async {
    if (!StorageService.containsKey(_comparedSchedulesKey)) {
      await StorageService.setObject(_comparedSchedulesKey, _comparedScheduleIds);
    }

    _comparedScheduleIds = StorageService.getObjectList<String>(_comparedSchedulesKey) ?? [];
    _isComparisonMode = _comparedScheduleIds.length == 2;
  }

  // Методы для работы с сопоставлением графиков
  List<String> get comparedScheduleIds => List.unmodifiable(_comparedScheduleIds);
  bool get isComparisonMode => _isComparisonMode;

  void enableComparisonMode(String firstScheduleId, String secondScheduleId) {
    _comparedScheduleIds = [firstScheduleId, secondScheduleId];
    _isComparisonMode = true;
    StorageService.setObject(_comparedSchedulesKey, _comparedScheduleIds);
    notify();
  }

  void disableComparisonMode() {
    _comparedScheduleIds = [];
    _isComparisonMode = false;
    StorageService.setObject(_comparedSchedulesKey, _comparedScheduleIds);
    notify();
  }

  // Обновим метод getColorsForComparison
  List<List<Color>> getColorsForComparison(List<WorkShift> workShifts, DateTime forMonth) {
    if (!_isComparisonMode || _comparedScheduleIds.length != 2) {
      return [[], []];
    }

    final firstColors = getColorsForSchedule(_comparedScheduleIds[0], workShifts, forMonth);
    final secondColors = getColorsForSchedule(_comparedScheduleIds[1], workShifts, forMonth);

    return [firstColors, secondColors];
  }

  List<Color> getComparisonColorsForDate(DateTime date, List<WorkShift> workShifts, SettingsProvider settingsProvider) {
    if (!_isComparisonMode || _comparedScheduleIds.length != 2) {
      return [Colors.grey, Colors.grey];
    }

    final firstColors = getColorsForSchedule(_comparedScheduleIds[0], workShifts, date);
    final secondColors = getColorsForSchedule(_comparedScheduleIds[1], workShifts, date);

    final firstOffset = getDayOffsetForSchedule(_comparedScheduleIds[0], date);
    final secondOffset = getDayOffsetForSchedule(_comparedScheduleIds[1], date);

    Color firstColor = _getColorWithExceptions(date, _comparedScheduleIds[0], firstColors, firstOffset, settingsProvider);
    Color secondColor = _getColorWithExceptions(date, _comparedScheduleIds[1], secondColors, secondOffset, settingsProvider);

    return [firstColor, secondColor];
  }

  Color _getColorWithExceptions(DateTime date, String scheduleId, List<Color> periodicColors, int dayOffset, SettingsProvider settingsProvider) {
    if (hasExceptionForDate(date, scheduleId)) {
      final exception = getExceptionForDate(date, scheduleId);
      final workShift = settingsProvider.allWorkShifts.firstWhere(
            (shift) => shift.id == exception!.workShiftId,
        orElse: () => WorkShift.createDefault(),
      );
      return workShift.color;
    }

    if (dayOffset < 0) {
      return Colors.grey.withValues(alpha: 0.3);
    }

    if (periodicColors.isEmpty) {
      return Colors.grey;
    }

    final int colorIndex = dayOffset % periodicColors.length;
    return periodicColors[colorIndex];
  }

  // Получить смещения для дней в сопоставляемых графиках
  List<int> getDayOffsetsForComparison(DateTime day) {
    if (!_isComparisonMode || _comparedScheduleIds.length != 2) {
      return [0, 0];
    }

    final firstOffset = getDayOffsetForSchedule(_comparedScheduleIds[0], day);
    final secondOffset = getDayOffsetForSchedule(_comparedScheduleIds[1], day);

    return [firstOffset, secondOffset];
  }

  Future<void> _loadFromStorage() async {
    await _loadShiftSequencesFromStorage();
    await _loadComparisonSettingsFromStorage();
    await _loadScheduleExceptionsFromStorage();
  }

  // Получить цвета для активного графика
  List<Color> getColorsForActiveSchedule(List<WorkShift> workShifts, DateTime forMonth) {
    final activeScheduleId = getActiveScheduleId();
    if (activeScheduleId == null) return [];

    return getColorsForSchedule(activeScheduleId, workShifts, forMonth);
  }

  // Получить смещение для дня в активном графике
  int getDayOffsetForActiveSchedule(DateTime day) {
    final activeScheduleId = getActiveScheduleId();
    if (activeScheduleId == null) return day.day - 1;

    return getDayOffsetForSchedule(activeScheduleId, day);
  }

  // Получить общее количество дней в цикле активного графика
  int getTotalCycleDaysForActiveSchedule() {
    final activeScheduleId = getActiveScheduleId();
    if (activeScheduleId == null) return 0;

    return getTotalCycleDaysForSchedule(activeScheduleId);
  }

  void addVacation(String scheduleId, DateTime startDate, DateTime endDate) {
    final exception = ScheduleException(
      id: const Uuid().v4(),
      scheduleId: scheduleId,
      workShiftId: 'vacation', // ID для отпуска
      startDate: startDate,
      endDate: endDate,
    );
    addScheduleException(exception);
  }

  void addSickLeave(String scheduleId, DateTime startDate, DateTime endDate) {
    final exception = ScheduleException(
      id: const Uuid().v4(),
      scheduleId: scheduleId,
      workShiftId: 'sickLeave', // ID для больничного
      startDate: startDate,
      endDate: endDate,
    );
    addScheduleException(exception);
  }
}
