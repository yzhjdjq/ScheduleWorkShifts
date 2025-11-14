import 'package:flutter/material.dart';

import 'package:sws/models/working_time.dart' show WorkingTime;
import 'package:sws/widgets/working_time_edit_widget.dart' show WorkingTimeEditWidget;

class WorkingTimeWidget extends StatelessWidget {
  final WorkingTime _workingTime;
  final Function(WorkingTime) _onTimeChanged;

  const WorkingTimeWidget({super.key, required WorkingTime workingTime, required Function(WorkingTime) onTimeChanged})
      : _workingTime = workingTime,
        _onTimeChanged = onTimeChanged;

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
            onPressed: () => _showWorkingTimeDialog(context),
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
          if (_workingTime.startTime != null && _workingTime.endTime != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Время:', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                Text(
                  '${_formatTimeOfDay(_workingTime.startTime!, context)} - ${_formatTimeOfDay(_workingTime.endTime!, context)}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Длит:', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                Text(_workingTime.durationText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
  void _showWorkingTimeDialog(BuildContext context) {
    WorkingTime tempWorkingTime =
    WorkingTime()
      ..startTime = _workingTime.startTime
      ..endTime = _workingTime.endTime
      ..duration = _workingTime.duration;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text('Настройка рабочего времени'),
        content: WorkingTimeEditWidget(
          workingTime: tempWorkingTime,
          onTimeChanged: (updatedTime) {
            tempWorkingTime = updatedTime;
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              _workingTime.startTime = tempWorkingTime.startTime;
              _workingTime.endTime = tempWorkingTime.endTime;
              _workingTime.calculateDuration();
              _onTimeChanged(_workingTime);
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
