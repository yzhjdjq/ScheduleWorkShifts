import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Consumer, ReadContext;

import 'package:sws/providers/providers.dart' show SettingsProvider;
import 'package:sws/models/models.dart' show Schedule;

class SettingsSchedulesPage extends StatelessWidget {
  const SettingsSchedulesPage({super.key});

  void _addNewScheduleBtnHandler(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final newSchedule = Schedule.createDefault();

    _editScheduleBtnHandler(
      context,
      newSchedule,
      isNewSchedule: true,
      onSave: (savedSchedule) => settings.addSchedule(savedSchedule),
    );
  }

  void _editScheduleBtnHandler(
    BuildContext context,
    Schedule schedule, {
    bool isNewSchedule = false,
    void Function(Schedule)? onSave,
  }) {
    final settings = context.read<SettingsProvider>();
    final textController = TextEditingController(text: schedule.name);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Переименовать график'),
            content: TextField(controller: textController),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
              TextButton(
                onPressed: () {
                  final savedSchedule = schedule.copyWith(
                    name: textController.text.isEmpty ? 'График' : textController.text,
                  );

                  if (isNewSchedule && onSave != null) {
                    onSave(savedSchedule);
                  } else {
                    settings.updateSchedule(savedSchedule);
                  }

                  Navigator.pop(context);
                },
                child: Text(isNewSchedule ? 'Создать' : 'Сохранить'),
              ),
            ],
          ),
    );
  }

  void _deleteScheduleBtnHandler(BuildContext context, Schedule schedule) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Удалить график?'),
            content: Text('Вы уверены, что хотите удалить "${schedule.name}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
              TextButton(
                onPressed: () {
                  context.read<SettingsProvider>().removeSchedule(schedule.id);
                  Navigator.pop(context);
                },
                child: const Text('Удалить'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройка графиков')),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: settings.schedules.length,
            itemBuilder: (context, index) {
              final schedule = settings.schedules[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(schedule.name),
                  onTap: () => _editScheduleBtnHandler(context, schedule),
                  onLongPress: () => _deleteScheduleBtnHandler(context, schedule),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewScheduleBtnHandler(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
