import 'package:flutter/material.dart';
import 'package:sws/models/working_time.dart' show WorkingTime;

class WorkingTimeEditWidget extends StatefulWidget {
  final WorkingTime workingTime;
  final Function(WorkingTime) onTimeChanged;

  const WorkingTimeEditWidget({super.key, required this.workingTime, required this.onTimeChanged});

  @override
  State<WorkingTimeEditWidget> createState() => _WorkingTimeEditWidgetState();
}

class _WorkingTimeEditWidgetState extends State<WorkingTimeEditWidget> {
  late WorkingTime _workingTime;

  @override
  void initState() {
    super.initState();
    _workingTime =
    WorkingTime()
      ..startTime = widget.workingTime.startTime
      ..endTime = widget.workingTime.endTime
      ..duration = widget.workingTime.duration;
  }

  Future<void> _selectStartTime() async {
    final selectedTime = await showTimePicker(context: context, initialTime: _workingTime.startTime ?? TimeOfDay.now());

    if (selectedTime != null) {
      setState(() {
        _workingTime.startTime = selectedTime;
        _workingTime.calculateDuration();
        widget.onTimeChanged(_workingTime);
      });
    }
  }

  Future<void> _selectEndTime() async {
    final selectedTime = await showTimePicker(context: context, initialTime: _workingTime.endTime ?? TimeOfDay.now());

    if (selectedTime != null) {
      setState(() {
        _workingTime.endTime = selectedTime;
        _workingTime.calculateDuration();
        widget.onTimeChanged(_workingTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Начало работы
          _buildTimeField(label: 'Начало работы', time: _workingTime.startTime, onTap: _selectStartTime),
          const SizedBox(height: 12),

          // Конец работы
          _buildTimeField(label: 'Конец работы', time: _workingTime.endTime, onTap: _selectEndTime),
          const SizedBox(height: 16),

          // Отображение продолжительности
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Общее рабочее время:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  _workingTime.durationText,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField({required String label, required TimeOfDay? time, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.access_time),
                hintText: time != null ? _formatTimeOfDay(time, context) : '--:--',
              ),
              controller: TextEditingController(text: time != null ? _formatTimeOfDay(time, context) : ''),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimeOfDay(TimeOfDay time, BuildContext context) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time, alwaysUse24HourFormat: true);
  }
}