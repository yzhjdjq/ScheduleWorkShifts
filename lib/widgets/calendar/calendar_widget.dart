import 'package:flutter/material.dart';
import 'package:sws/providers/providers.dart' show ScheduleProvider;
import 'package:sws/widgets/calendar/calendar.dart' show CalendarGridWidget, CalendarHeaderWidget;

class CalendarWidget extends StatelessWidget {
  final DateTime currentDate;
  final int daysInMonth;
  final int firstWeekday;
  final List<Color> periodicColors;
  final String? selectedScheduleId;
  final bool isComparisonMode;
  final List<List<Color>> comparisonColors;
  final bool showShiftNames;
  final ScheduleProvider scheduleProvider;

  const CalendarWidget({
    super.key,
    required this.currentDate,
    required this.daysInMonth,
    required this.firstWeekday,
    required this.periodicColors,
    required this.selectedScheduleId,
    required this.isComparisonMode,
    required this.comparisonColors,
    required this.showShiftNames,
    required this.scheduleProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CalendarHeaderWidget(),
        Expanded(
          child: CalendarGridWidget(
            daysInMonth: daysInMonth,
            firstWeekday: firstWeekday,
            currentDate: currentDate,
            periodicColors: periodicColors,
            selectedScheduleId: selectedScheduleId,
            isComparisonMode: isComparisonMode,
            comparisonColors: comparisonColors,
            showShiftNames: showShiftNames,
            scheduleProvider: scheduleProvider,
          ),
        ),
      ],
    );
  }
}