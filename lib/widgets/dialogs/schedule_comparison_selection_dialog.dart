import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext;
import 'package:sws/providers/providers.dart'
    show ScheduleSelectionDialogsProvider, SnackBarMessageProvider;
import 'package:sws/services/services.dart' show S;

void showScheduleComparisonSelectionDialog(BuildContext context) {
  final pageProvider = context.read<ScheduleSelectionDialogsProvider>();

  final (firstSchedule, secondSchedule) =
      pageProvider.getSchedulesForComparisonSetting();

  if (firstSchedule == secondSchedule) {
    context.read<SnackBarMessageProvider>().showWarning(
      S.of(context).notEnoughSchedules,
    );
    return;
  }

  var (firstScheduleState, secondScheduleState) = (
    firstSchedule,
    secondSchedule,
  );

  showDialog(
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder: (context, setState) {
            final availableSecondSchedules = pageProvider
                .getAvailableSchedulesForComparison(firstScheduleState);

            if (firstScheduleState.id == secondScheduleState.id) {
              secondScheduleState =
                  availableSecondSchedules.firstOrNull ?? secondScheduleState;
            }

            final areSchedulesDifferent =
                firstScheduleState.id != secondScheduleState.id;

            void swapSchedules() {
              setState(() {
                final temp = firstScheduleState;
                firstScheduleState = secondScheduleState;
                secondScheduleState = temp;
              });
            }

            void onFirstScheduleChanged(String? value) {
              setState(() {
                if (value == null) {
                  firstScheduleState = firstSchedule;
                } else {
                  final schedule = pageProvider.getScheduleById(value);
                  firstScheduleState = schedule ?? firstSchedule;
                }
                final newAvailableSchedules = pageProvider
                    .getAvailableSchedulesForComparison(firstScheduleState);
                secondScheduleState =
                    newAvailableSchedules.firstOrNull ?? secondSchedule;
              });
            }

            void onSecondScheduleChanged(String? value) {
              setState(() {
                if (value == null) {
                  secondScheduleState = secondSchedule;
                } else {
                  final schedule = pageProvider.getScheduleById(value);
                  secondScheduleState = schedule ?? secondSchedule;
                }
              });
            }

            void onCompareBtnClicked() {
              if (pageProvider.isScheduleHasSequences(firstScheduleState) ||
                  pageProvider.isScheduleHasSequences(secondScheduleState)) {
                context.read<SnackBarMessageProvider>().showWarning(
                  S.of(context).schedulesForComparisonNotConfigured,
                );
              }
              pageProvider.enableComparisonMode(
                firstScheduleState,
                secondScheduleState,
              );
              Navigator.pop(context);
            }

            return AlertDialog(
              title: Text(S.of(context).scheduleComparison),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: S.of(context).firstScheduleTitleName,
                        border: const OutlineInputBorder(),
                      ),
                      value: firstScheduleState.id,
                      items:
                          pageProvider.schedules.map((schedule) {
                            final hasSequences = pageProvider
                                .isScheduleHasSequences(schedule);

                            return DropdownMenuItem<String>(
                              value: schedule.id,
                              child: Row(
                                children: <Widget>[
                                  Text(schedule.name),
                                  if (!hasSequences)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        S.of(context).notConfigured,
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: onFirstScheduleChanged,
                    ),

                    const SizedBox(height: 16),

                    if (areSchedulesDifferent)
                      IconButton(
                        onPressed: swapSchedules,
                        icon: const Icon(Icons.swap_vert),
                        tooltip: S.of(context).swapSchedules,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: S.of(context).secondScheduleTitleName,
                        border: const OutlineInputBorder(),
                      ),
                      value: secondScheduleState.id,
                      items:
                          availableSecondSchedules.map((schedule) {
                            final hasSequences = pageProvider
                                .isScheduleHasSequences(schedule);

                            return DropdownMenuItem<String>(
                              value: schedule.id,
                              child: Row(
                                children: <Widget>[
                                  Text(schedule.name),
                                  if (!hasSequences)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        S.of(context).notConfigured,
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: onSecondScheduleChanged,
                    ),

                    if (availableSecondSchedules.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          S.of(context).noSchedulesAvailableForCompare,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.of(context).cancel),
                ),
                TextButton(
                  onPressed:
                      areSchedulesDifferent &&
                              availableSecondSchedules.isNotEmpty
                          ? onCompareBtnClicked
                          : null,
                  child: Text(S.of(context).compare),
                ),
              ],
            );
          },
        ),
  );
}
