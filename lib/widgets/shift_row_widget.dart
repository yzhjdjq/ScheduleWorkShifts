import 'package:flutter/material.dart';
import 'package:sws/models/models.dart' show ShiftCategory, WorkShift, WorkingTime;
import 'package:sws/widgets/widgets.dart' show WorkingTimeWidget;

class ShiftRowWidget extends StatelessWidget {
  final WorkShift? selectedShift;
  final List<WorkShift> availableShifts;
  final String daysCount;
  final TextEditingController daysController;
  final WorkingTime workingTime;
  final ValueChanged<WorkShift?> onShiftChanged;
  final ValueChanged<String> onDaysChanged;
  final ValueChanged<WorkingTime> onTimeChanged;
  final VoidCallback onRemove;
  final bool canRemove;

  const ShiftRowWidget({
    super.key,
    required this.selectedShift,
    required this.availableShifts,
    required this.daysCount,
    required this.daysController,
    required this.workingTime,
    required this.onShiftChanged,
    required this.onDaysChanged,
    required this.onTimeChanged,
    required this.onRemove,
    required this.canRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildShiftCell(context)),
        Expanded(flex: 1, child: _buildDaysCell()),
        Expanded(flex: 3, child: _buildTimeCell(context)),
        _buildDeleteCell(),
      ],
    );
  }

  Widget _buildShiftCell(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      child: DropdownButton<WorkShift>(
        isExpanded: true,
        value: selectedShift,
        hint: const Text('Выберите смену', style: TextStyle(fontSize: 14)),
        items: availableShifts.map((shift) {
          return DropdownMenuItem<WorkShift>(
            value: shift,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: shift.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(shift.name, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: onShiftChanged,
      ),
    );
  }

  Widget _buildDaysCell() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      child: TextField(
        maxLength: 2,
        textAlign: TextAlign.center,
        controller: daysController,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          counterText: '',
          hintText: '',
          isDense: true,
        ),
        onChanged: onDaysChanged,
      ),
    );
  }

  Widget _buildTimeCell(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      child: Builder(
        builder: (context) {
          if (selectedShift?.category == ShiftCategory.dayOff) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: Text(
                'Выходной день',
                style: TextStyle(
                  fontSize: 12,
                  color: selectedShift?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return WorkingTimeWidget(
            workingTime: workingTime,
            onTimeChanged: onTimeChanged,
          );
        },
      ),
    );
  }

  Widget _buildDeleteCell() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: canRemove
          ? IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: onRemove,
            )
          : const SizedBox(width: 32, height: 32),
    );
  }
}

class ShiftRowData {
  WorkShift? selectedShift;
  String daysCount;
  final TextEditingController daysController;
  WorkingTime workingTime;

  ShiftRowData({
    this.selectedShift,
    required this.daysCount,
    required this.workingTime,
  }) : daysController = TextEditingController(text: daysCount) {
    daysController.addListener(() {
      daysCount = daysController.text;
    });
  }

  void dispose() {
    daysController.dispose();
  }
}