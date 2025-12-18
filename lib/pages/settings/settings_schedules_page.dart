import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Consumer, ReadContext;

import 'package:sws/providers/providers.dart'
    show ScheduleItemViewModel, SettingsSchedulePageProvider;
import 'package:sws/services/services.dart' show S;

class SettingsSchedulesPage extends StatelessWidget {
  const SettingsSchedulesPage({super.key});

  void _addNewScheduleBtnHandler(BuildContext context) {
    final settings = context.read<SettingsSchedulePageProvider>();
    final newSchedule = ScheduleItemViewModel.createDefault();

    _editScheduleBtnHandler(
      context,
      newSchedule,
      isNewSchedule: true,
      onSave: (savedSchedule) => settings.addSchedule(savedSchedule),
    );
  }

  void _editScheduleBtnHandler(
    BuildContext context,
    ScheduleItemViewModel schedule, {
    bool isNewSchedule = false,
    void Function(ScheduleItemViewModel)? onSave,
  }) {
    final settings = context.read<SettingsSchedulePageProvider>();
    final textController = TextEditingController(text: schedule.name);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title:
                isNewSchedule
                    ? Text(S.of(context).createSchedule)
                    : Text(S.of(context).renameSchedule),
            content: TextField(controller: textController),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(   context),
                child: Text(S.of(context).cancel),
              ),
              TextButton(
                onPressed: () {
                  final savedSchedule = schedule.copyWith(
                    name:
                        textController.text.isEmpty
                            ? S.of(context).newScheduleName
                            : textController.text,
                  );

                  if (isNewSchedule && onSave != null) {
                    onSave(savedSchedule);
                  } else {
                    settings.updateSchedule(savedSchedule);
                  }

                  Navigator.pop(context);
                },
                child: Text(
                  isNewSchedule ? S.of(context).create : S.of(context).save,
                ),
              ),
            ],
          ),
    );
  }

  void _deleteScheduleBtnHandler(
    BuildContext context,
    ScheduleItemViewModel schedule,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(S.of(context).deleteScheduleQuestion),
            content: Text(S.of(context).confirmDeleteSchedule(schedule.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).cancel),
              ),
              TextButton(
                onPressed: () {
                  context.read<SettingsSchedulePageProvider>().removeSchedule(
                    schedule.id,
                  );
                  Navigator.pop(context);
                },
                child: Text(S.of(context).delete),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).settingsSchedulesBarTitle)),
      body: Consumer<SettingsSchedulePageProvider>(
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
                  onLongPress:
                      () => _deleteScheduleBtnHandler(context, schedule),
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
