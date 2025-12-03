import 'package:flutter/material.dart';
import 'package:sws/providers/providers.dart' show CalendarWidgetProvider, WorkShiftItemViewModel;
import 'package:sws/widgets/calendar/calendar.dart' show CalendarGridWidget, CalendarHeaderWidget;

class CalendarWidget extends StatelessWidget {
  final DateTime currentDate;
  final int daysInMonth;
  final int firstWeekday;
  final void Function(DateTime, WorkShiftItemViewModel) onDayCellTap;
  final CalendarWidgetProvider calendarProvider;

  const CalendarWidget({
    super.key,
    required this.currentDate,
    required this.daysInMonth,
    required this.firstWeekday,
    required this.onDayCellTap,
    required this.calendarProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CalendarHeaderWidget(),
        Expanded(
          child: CalendarGridWidget(
            currentDate: currentDate,
            daysInMonth: daysInMonth,
            firstWeekday: firstWeekday,
            onDayCellTap: onDayCellTap,
            calendarProvider: calendarProvider,
          ),
        ),
      ],
    );
  }
}
