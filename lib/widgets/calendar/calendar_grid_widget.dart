import 'package:flutter/material.dart';
import 'package:sws/providers/model_providers/model_providers.dart';
import 'package:sws/providers/providers.dart' show CalendarWidgetProvider, WorkShiftItemViewModel;
import 'package:sws/widgets/calendar/calendar.dart'
    show CalendarCellEmptyWidget, CalendarCellWidget, CalendarCellComparisonWidget;

class CalendarGridWidget extends StatelessWidget {
  final DateTime currentDate;
  final int daysInMonth;
  final int firstWeekday;
  final void Function(DateTime, WorkShiftItemViewModel) onDayCellTap;
  final CalendarWidgetProvider calendarProvider;

  const CalendarGridWidget({
    super.key,
    required this.currentDate,
    required this.daysInMonth,
    required this.firstWeekday,
    required this.onDayCellTap,
    required this.calendarProvider,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pads = const EdgeInsets.all(6);
        final double availableHeight = constraints.maxHeight - pads.vertical;
        final double countRowsInCalendarGrid = 5;
        final double cellHeight = availableHeight / countRowsInCalendarGrid;
        final int countDaysInWeek = 7;

        return Container(
          padding: pads,
          child: Column(
            children: List.generate(5, (row) {
              return SizedBox(
                height: cellHeight,
                child: Row(
                  children: List.generate(countDaysInWeek, (col) {
                    final cellIndex = row * countDaysInWeek + col;
                    final day = cellIndex - firstWeekday + 2;
                    final isInRange = cellIndex >= firstWeekday - 1 && cellIndex < firstWeekday - 1 + daysInMonth;

                    if (!isInRange) {
                      return const Expanded(child: CalendarCellEmptyWidget());
                    }

                    final currentDay = DateTime(currentDate.year, currentDate.month, day);
                    final isToday = calendarProvider.isToday(day, currentDate);

                    if (calendarProvider.isSimpleMode) {
                      return Expanded(
                        child: CalendarCellWidget.simpleMode(
                          currentDay: currentDay,
                          isToday: isToday,
                          cellHeight: cellHeight,
                        ),
                      );
                    }

                    if (calendarProvider.isComparisonMode) {
                      return Expanded(
                        child: CalendarCellComparisonWidget(
                          isToday: isToday,
                          currentDay: currentDay,
                          cellHeight: cellHeight,
                          calendarProvider: calendarProvider,
                        ),
                      );
                    }
                    final (Color?, WorkShiftItemViewModel?) defaultValue = (
                      Colors.grey.withAlpha(77),
                      WorkShiftItemViewModel(
                        id: '',
                        name: '',
                        color: Colors.transparent,
                        category: ShiftCategoryViewModel.dayOff,
                      ),
                    );
                    final (cellColor, workShift) = calendarProvider.getCellColorAndWorkShiftNameByActiveScheduleMode(
                      currentDay: currentDay,
                      defaultValue: defaultValue,
                    );

                    return Expanded(
                      child: CalendarCellWidget(
                        currentDay: currentDay,
                        isToday: isToday,
                        cellHeight: cellHeight,
                        cellColor: cellColor!,
                        shiftName: workShift!.name,
                        showShiftName: calendarProvider.showShiftName(),
                        onTap:
                            (cellColor, workShift) == defaultValue ? null : () => onDayCellTap(currentDay, workShift),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
