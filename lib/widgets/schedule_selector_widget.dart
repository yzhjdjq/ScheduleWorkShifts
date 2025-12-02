import 'package:flutter/material.dart';
import 'package:sws/models/models.dart' show Schedule;

class ScheduleSelectorWidget extends StatelessWidget {
  final List<Schedule> schedules;
  final Schedule? selectedSchedule;
  final ValueChanged<Schedule?> onChanged;

  const ScheduleSelectorWidget({
    super.key,
    required this.schedules,
    required this.selectedSchedule,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'График *',
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      ),
      value: selectedSchedule?.id,
      items:
          schedules.map((schedule) {
            return DropdownMenuItem<String>(value: schedule.id, child: Text(schedule.name));
          }).toList(),
      onChanged: (String? newValue) {
        if (newValue == null) return;
        final schedule = schedules.firstWhere((s) => s.id == newValue, orElse: () => schedules.first);
        onChanged(schedule);
      },
    );
  }
}
