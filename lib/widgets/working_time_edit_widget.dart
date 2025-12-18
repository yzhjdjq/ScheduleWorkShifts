import 'package:flutter/material.dart';
import 'package:sws/providers/model_providers/model_providers.dart'
    show WorkingTimeViewModel;
import 'package:sws/services/services.dart' show S;

class WorkingTimeEditWidget extends StatefulWidget {
  final WorkingTimeViewModel workingTime;
  final Function(WorkingTimeViewModel) onTimeChanged;

  const WorkingTimeEditWidget({
    super.key,
    required this.workingTime,
    required this.onTimeChanged,
  });

  @override
  State<WorkingTimeEditWidget> createState() => _WorkingTimeEditWidgetState();
}

class _WorkingTimeEditWidgetState extends State<WorkingTimeEditWidget> {
  late WorkingTimeViewModel _workingTime;

  @override
  void initState() {
    super.initState();
    _workingTime = widget.workingTime;
  }

  @override
  void didUpdateWidget(covariant WorkingTimeEditWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workingTime != widget.workingTime) {
      _workingTime = widget.workingTime;
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _workingTime.startTime ?? TimeOfDay.now(),
    );

    if (selectedTime != null) {
      final updatedTime = _workingTime.copyWith(startTime: selectedTime);
      setState(() {
        _workingTime = updatedTime;
      });
      widget.onTimeChanged(updatedTime);
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _workingTime.endTime ?? TimeOfDay.now(),
    );

    if (selectedTime != null) {
      final updatedTime = _workingTime.copyWith(endTime: selectedTime);
      setState(() {
        _workingTime = updatedTime;
      });
      widget.onTimeChanged(updatedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildTimeField(
            label: S.of(context).startWork,
            time: _workingTime.startTime,
            onTap: _selectStartTime,
          ),
          const SizedBox(height: 12),

          _buildTimeField(
            label: S.of(context).endWork,
            time: _workingTime.endTime,
            onTap: _selectEndTime,
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${S.of(context).workTimeDuration}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  S
                      .of(context)
                      .durationText(
                        _workingTime.durationForText.$1,
                        _workingTime.durationForText.$2,
                      ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 4),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: AbsorbPointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  color: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      WorkingTimeViewModel.formatTimeOfDay(time, context),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.access_time, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
