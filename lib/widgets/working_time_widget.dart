import 'package:flutter/material.dart';
import 'package:sws/providers/providers.dart' show WorkingTimeViewModel;
import 'package:sws/widgets/widgets.dart' show WorkingTimeEditWidget;

class WorkingTimeWidget extends StatelessWidget {
  final WorkingTimeViewModel workingTime;
  final ValueChanged<WorkingTimeViewModel> onTimeChanged;

  const WorkingTimeWidget({
    super.key,
    required this.workingTime,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Компактное отображение выбранного времени
        _buildTimeSummary(context),
        const SizedBox(height: 4),

        // Кнопка для открытия диалога редактирования
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showWorkingTimeViewModelDialog(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            child: const Text('Настроить', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  /// Отображение сводки выбранного времени
  Widget _buildTimeSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (workingTime.startTime != null && workingTime.endTime != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Время:', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                Text(
                  '${_formatTimeOfDay(workingTime.startTime!, context)} - ${_formatTimeOfDay(workingTime.endTime!, context)}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Длит:', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                Text(workingTime.durationText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ] else ...[
            Text(
              'Время не настроено',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  /// Диалог для настройки рабочего времени
  void _showWorkingTimeViewModelDialog(BuildContext context) {
    // Локальная копия для редактирования
    var tempWorkingTimeViewModel = workingTime;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Настройка рабочего времени'),
        content: WorkingTimeEditWidget(
          workingTime: tempWorkingTimeViewModel,
          onTimeChanged: (updated) {
            tempWorkingTimeViewModel = updated;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              onTimeChanged(tempWorkingTimeViewModel);
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time, BuildContext context) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time, alwaysUse24HourFormat: true);
  }
}