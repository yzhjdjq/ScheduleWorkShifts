import 'package:flutter/material.dart';

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
            label: const Text('Добавить смену'),
            onPressed: onAddShift,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Сохранить'),
            onPressed: onSave,
          ),
        ),
      ],
    );
  }
}