import 'dart:ui' show Color;
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:sws/models/models.dart' show ShiftCategory, WorkShift;
import 'package:sws/repositories/repositories.dart' show WorkShiftRepository;
import 'package:uuid/uuid.dart' show Uuid;

class WorkShiftProvider with ChangeNotifier {
  static WorkShiftProvider? _instance;
  static WorkShiftProvider get instance {
    if (_instance == null) {
      throw Exception('WorkShiftStore not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<WorkShiftProvider> initialize() async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = WorkShiftProvider();
    await _instance!._loadDataFromRepository();
    return _instance!;
  }

  WorkShiftProvider() {
    if (_instance != null) {
      throw Exception('WorkShiftStore is already initialized.');
    }
  }

  static bool get isInitialized => _instance != null;

  static final WorkShiftRepository _workShiftsRepository = WorkShiftRepository();
  static List<WorkShift> _workShifts = [];
  static List<WorkShift> _staticShifts = [WorkShift.vacation(), WorkShift.sickLeave()];

  List<WorkShift> _ensureMinimumWorkShifts() => [
    WorkShift.createDefault(),
    WorkShift(id: const Uuid().v4(), name: 'Выходной', category: ShiftCategory.dayOff, color: const Color(0xFF00AA00)),
  ];

  Future<void> _loadDataFromRepository() async {
    final allWorkShifts = await _workShiftsRepository.loadAll(
      defaultValue: [..._ensureMinimumWorkShifts(), ..._staticShifts],
    );

    _workShifts = allWorkShifts.where((shift) => !shift.isStatic()).toList();
    _staticShifts = allWorkShifts.where((shift) => shift.isStatic()).toList();
  }

  void _saveToStorage() {
    _workShiftsRepository.saveAll([..._workShifts, ..._staticShifts]);
    notifyListeners();
  }

  List<WorkShiftItemViewModel> get workShifts =>
      List.unmodifiable(_workShifts).map((ws) => WorkShiftItemViewModel.fromWorkShift(ws)).toList();

  List<WorkShiftItemViewModel> get allWorkShifts =>
      List.unmodifiable([
        ..._workShifts,
        ..._staticShifts,
      ]).map((ws) => WorkShiftItemViewModel.fromWorkShift(ws)).toList();

  WorkShiftItemViewModel get vacationShift =>
      WorkShiftItemViewModel.fromWorkShift(_staticShifts.firstWhere((ws) => ws.isVacation()));

  WorkShiftItemViewModel get sickLeaveShift =>
      WorkShiftItemViewModel.fromWorkShift(_staticShifts.firstWhere((ws) => ws.isSickLeave()));

  void addWorkShift(WorkShiftItemViewModel shiftItem) {
    final shift = WorkShift(
      id: shiftItem.id,
      name: shiftItem.name,
      category: shiftItem.category,
      color: shiftItem.color,
    );
    _workShifts.add(shift);
    _saveToStorage();
  }

  void updateWorkShift(WorkShiftItemViewModel newShiftItem) {
    final int index = _workShifts.indexWhere((shift) => shift.id == newShiftItem.id);

    if (index != -1) {
      final newShift = WorkShift(
        id: newShiftItem.id,
        name: newShiftItem.name,
        category: newShiftItem.category,
        color: newShiftItem.color,
      );
      _workShifts[index] = newShift;
      _saveToStorage();
    }
  }

  void updateStaticShiftColor(String id, Color newColor) {
    _staticShifts.firstWhere((shift) => shift.id == id).copyWith(color: newColor);
    _saveToStorage();
  }

  void removeWorkShift(String id) {
    _workShifts.removeWhere((shift) => shift.id == id);
    _saveToStorage();
  }
}

typedef ShiftCategoryViewModel = ShiftCategory;

class WorkShiftItemViewModel {
  final String id;
  final String name;
  final ShiftCategoryViewModel category;
  final Color color;

  const WorkShiftItemViewModel({required this.id, required this.name, required this.category, required this.color});

  static WorkShiftItemViewModel fromWorkShift(WorkShift workShift) {
    return WorkShiftItemViewModel(
      id: workShift.id,
      name: workShift.name,
      category: workShift.category,
      color: workShift.color,
    );
  }

  static WorkShiftItemViewModel createDefault() {
    final defaultWorkShift = WorkShift.createDefault();
    return WorkShiftItemViewModel(
      id: defaultWorkShift.id,
      name: defaultWorkShift.name,
      category: defaultWorkShift.category,
      color: defaultWorkShift.color,
    );
  }

  WorkShiftItemViewModel copyWith({String? name, ShiftCategoryViewModel? category, Color? color}) {
    return WorkShiftItemViewModel(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
    );
  }

  bool isStatic() => WorkShift(id: id, name: name, category: category, color: color).isStatic();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WorkShiftItemViewModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              category == other.category &&
              color.toARGB32() == other.color.toARGB32();

  @override
  int get hashCode => Object.hash(id, name, category, color.toARGB32());
}
