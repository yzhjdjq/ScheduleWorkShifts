import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sws/providers/settings_provider.dart';
import 'package:sws/models/schedule.dart';

class SettingsSchedulesPage extends StatelessWidget {
  const SettingsSchedulesPage({super.key});

  void _addNewSchedule(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final newSchedule = Schedule.createDefault();

    _editSchedule(
        context,
        newSchedule,
        isNewSchedule: true,
        onSave: (savedSchedule)
          => settings.addSchedule(savedSchedule),
    );
  }

  void _editSchedule(
      BuildContext context,
      Schedule schedule, {
        bool isNewSchedule = false,
        void Function(Schedule)? onSave,
      }) {
    final settings = context.read<SettingsProvider>();
    final textController = TextEditingController(text: schedule.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Переименовать график'),
        content: TextField(controller: textController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final savedSchedule = Schedule.copy(schedule);
              savedSchedule.name = textController.text.isEmpty
                ? 'График'
                : textController.text;

              if ( isNewSchedule && onSave != null ) {
                onSave(savedSchedule);
              } else {
                settings.updateSchedule(schedule.id, savedSchedule);
              }

              Navigator.pop(context);
            },
            child: Text(isNewSchedule ? 'Создать' : 'Сохранить'),
          ),
        ],
      ),
    );
  }

  void _deleteSchedule(BuildContext context, Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить график?'),
        content: Text('Вы уверены, что хотите удалить "${schedule.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
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
      appBar: AppBar(
        title: const Text('Настройка графиков'),
      ),
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
                  onTap: () => _editSchedule(context, schedule),
                  onLongPress: () => _deleteSchedule(context, schedule),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewSchedule(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}