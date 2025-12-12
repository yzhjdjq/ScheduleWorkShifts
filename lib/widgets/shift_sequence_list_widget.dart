import 'package:flutter/material.dart';
import 'package:sws/providers/providers.dart' show WorkShiftItemViewModel, WorkingTimeViewModel;
import 'package:sws/widgets/widgets.dart' show ShiftRowWidget, ShiftRowData;

class ShiftSequenceListWidget extends StatelessWidget {
  final List<ShiftRowData> rows;
  final List<WorkShiftItemViewModel> availableShifts;
  final void Function(WorkShiftItemViewModel? newShift, int indexRow) onShiftChanged;
  final void Function(String newDays, int indexRow) onDaysChanged;
  final void Function(WorkingTimeViewModel newWorkingTime, int indexRow) onTimeChanged;
  final VoidCallback onAdd;
  final Function(int rowIndex) onRemove;

  const ShiftSequenceListWidget({
    super.key,
    required this.rows,
    required this.availableShifts,
    required this.onShiftChanged,
    required this.onDaysChanged,
    required this.onTimeChanged,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // Заголовок
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(flex: 3, child: _buildHeader('Смена *')),
                Expanded(flex: 1, child: _buildHeader('Кол-во дней *')),
                Expanded(flex: 3, child: _buildHeader('Рабочее время')),
                SizedBox(width: 48, child: _buildHeader('')),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Список строк
          Expanded(
            child:
                rows.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const Divider(height: 8, color: Colors.transparent),
                      itemBuilder: (context, index) {
                        final data = rows[index];
                        return ShiftRowWidget(
                          selectedShift: data.selectedShift,
                          availableShifts: availableShifts,
                          daysCount: data.daysCount,
                          daysController: data.daysController,
                          workingTime: data.workingTime,
                          onShiftChanged: (newShift) => onShiftChanged(newShift, index),
                          onDaysChanged: (newDays) => onDaysChanged(newDays, index),
                          onTimeChanged: (newWorkingTime) => onTimeChanged(newWorkingTime, index),
                          onRemove: () => onRemove(index),
                          canRemove: rows.length > 2,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14));
  }
}
