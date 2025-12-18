import 'package:flutter/material.dart';
import 'package:sws/providers/providers.dart' show ScheduleItemViewModel;
import 'package:sws/services/services.dart' show S;

class ScheduleSelectorWidget extends StatelessWidget {
  final List<ScheduleItemViewModel> schedules;
  final ScheduleItemViewModel? selectedSchedule;
  final ValueChanged<String> onChanged;

  const ScheduleSelectorWidget({
    super.key,
    required this.schedules,
    required this.selectedSchedule,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: '${S.of(context).schedule} *',
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      ),
      value: selectedSchedule?.id,
      items:
          schedules.map((schedule) {
            return DropdownMenuItem<String>(value: schedule.id, child: Text(schedule.name));
          }).toList(),
      onChanged: (String? newValue) {
        if (newValue == null) return;
        onChanged(newValue);
      },
    );
  }
}
