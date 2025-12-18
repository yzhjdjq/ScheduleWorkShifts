import 'package:flutter/material.dart';
import 'package:sws/services/services.dart' show S;

class CreateScheduleActionsWidget extends StatelessWidget {
  final VoidCallback onAddShift;
  final VoidCallback onSave;

  const CreateScheduleActionsWidget({
    super.key,
    required this.onAddShift,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(S.of(context).addShift),
            onPressed: onAddShift,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.icon(
            icon: const Icon(Icons.save),
            label: Text(S.of(context).save),
            onPressed: onSave,
          ),
        ),
      ],
    );
  }
}