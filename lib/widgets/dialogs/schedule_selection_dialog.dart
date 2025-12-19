import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext;
import 'package:sws/providers/providers.dart'
    show ScheduleSelectionDialogsProvider, SnackBarMessageProvider;
import 'package:sws/services/services.dart' show S;
import 'package:sws/widgets/dialogs/dialogs.dart'
    show showScheduleComparisonSelectionDialog;

void showScheduleSelectionDialog(BuildContext context) {
  final pageProvider = context.read<ScheduleSelectionDialogsProvider>();
  const int countListItemForComparisonMenu = 1;

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(S.of(context).selectSchedule),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount:
                  pageProvider.schedules.length +
                  countListItemForComparisonMenu,
              itemBuilder: (context, index) {
                if (index == pageProvider.schedules.length) {
                  return _buildScheduleComparisonSelectionListItem(
                    context,
                    pageProvider,
                  );
                }

                final schedule = pageProvider.schedules[index];
                final hasSequences = pageProvider.isScheduleHasSequences(
                  schedule,
                );
                final isActive =
                    !pageProvider.isComparisonMode &&
                    pageProvider.isScheduleActive(schedule);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 0,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                      bottom: Radius.circular(12),
                    ),
                  ),
                  elevation: 1,
                  child: ListTile(
                    title: Text(schedule.name),
                    subtitle:
                        hasSequences
                            ? Text(
                              S.of(context).configured,
                              style: const TextStyle(color: Colors.green),
                            )
                            : Text(
                              S.of(context).notConfigured,
                              style: const TextStyle(color: Colors.orange),
                            ),
                    trailing:
                        isActive
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                    tileColor:
                        isActive ? Colors.green.withValues(alpha: 0.1) : null,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                        bottom: Radius.circular(12),
                      ),
                    ),
                    onTap: () {
                      if (!hasSequences) {
                        context.read<SnackBarMessageProvider>().showWarning(
                          S.of(context).unconfiguredScheduleSelected,
                        );
                      }
                      pageProvider.onActiveScheduleChange(schedule);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context).cancel),
            ),
          ],
        ),
  );
}

Widget _buildScheduleComparisonSelectionListItem(
  BuildContext context,
  ScheduleSelectionDialogsProvider pageProvider,
) {
  final isComparisonActive = pageProvider.isComparisonMode;

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(12),
        bottom: Radius.circular(12),
      ),
    ),
    elevation: 1,
    child: ListTile(
      title: Text(S.of(context).scheduleComparison),
      leading: const Icon(Icons.compare),
      trailing:
          isComparisonActive
              ? const Icon(Icons.check, color: Colors.green)
              : null,
      tileColor:
          isComparisonActive ? Colors.green.withValues(alpha: 0.1) : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
          bottom: Radius.circular(12),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        showScheduleComparisonSelectionDialog(context);
      },
    ),
  );
}
