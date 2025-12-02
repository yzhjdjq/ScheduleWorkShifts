import 'package:flutter/material.dart';
import 'package:sws/models/models.dart' show WorkShift;
import 'package:sws/providers/providers.dart' show ScheduleProvider;
import 'package:sws/widgets/calendar/calendar.dart'
    show CalendarCellEmptyWidget, CalendarCellWidget, CalendarCellComparisonWidget;
import 'package:sws/widgets/widgets.dart' show showDaySettingsDialog, showExceptionDetailsDialog;

class CalendarGridWidget extends StatelessWidget {
  final int daysInMonth;
  final int firstWeekday;
  final DateTime currentDate;
  final List<Color> periodicColors;
  final String? selectedScheduleId;
  final bool isComparisonMode;
  final List<List<Color>> comparisonColors;
  final bool showShiftNames;
  final ScheduleProvider scheduleProvider;

  const CalendarGridWidget({
    super.key,
    required this.daysInMonth,
    required this.firstWeekday,
    required this.currentDate,
    required this.periodicColors,
    required this.selectedScheduleId,
    required this.isComparisonMode,
    required this.comparisonColors,
    required this.showShiftNames,
    required this.scheduleProvider,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pads = const EdgeInsets.all(6);
        final double availableHeight = constraints.maxHeight - pads.vertical;
        final double cellHeight = availableHeight / 5;

        return Container(
          padding: pads,
          child: Column(
            children: List.generate(5, (row) {
              return SizedBox(
                height: cellHeight,
                child: Row(
                  children: List.generate(7, (col) {
                    final cellIndex = row * 7 + col;
                    final day = cellIndex - firstWeekday + 2;
                    final isInRange = cellIndex >= firstWeekday - 1 && cellIndex < firstWeekday - 1 + daysInMonth;

                    if (!isInRange) {
                      return const Expanded(child: CalendarCellEmptyWidget());
                    }

                    final currentDay = DateTime(currentDate.year, currentDate.month, day);
                    final isToday = _isToday(day);

                    // 🔹 Режим сравнения
                    if (isComparisonMode) {
                      return Expanded(
                        child: CalendarCellComparisonWidget(
                          day: day,
                          isToday: isToday,
                          currentDay: currentDay,
                          scheduleProvider: scheduleProvider,
                          cellHeight: cellHeight,
                        ),
                      );
                    }

                    // 🔹 Обычный режим
                    final scheduleId = selectedScheduleId ?? scheduleProvider.getActiveScheduleId();
                    if (scheduleId == null || scheduleId.isEmpty) {
                      return Expanded(child: CalendarCellWidget(
                        day: day,
                        currentDay: currentDay,
                        isToday: isToday,
                        cellHeight: cellHeight,
                        cellColor: Colors.grey.withAlpha(77),
                        shiftName: '',
                        showShiftName: false,
                        onTap: () {},
                      ));
                    }

                    final dayOffset = scheduleProvider.getDayOffsetForSchedule(scheduleId, currentDay);
                    final totalCycleDays = scheduleProvider.getTotalCycleDaysForSchedule(scheduleId);

                    final bool hasValidCycle = totalCycleDays > 0;
                    final bool isWithinCycle = dayOffset >= 0;

                    Color cellColor;
                    String shiftName = '';

                    if (scheduleProvider.hasExceptionForDate(currentDay, scheduleId)) {
                      final exception = scheduleProvider.getExceptionForDate(currentDay, scheduleId)!;
                      final workShift = scheduleProvider.allWorkShifts.firstWhere(
                        (s) => s.id == exception.workShiftId,
                        orElse: () => WorkShift.createDefault(),
                      );
                      cellColor = workShift.color;
                      shiftName = workShift.name;
                    } else if (hasValidCycle && isWithinCycle) {
                      final periodicColors = scheduleProvider.getColorsForSchedule(
                        scheduleId,
                        scheduleProvider.workShifts,
                        currentDay,
                      );
                      final colorIndex = dayOffset % periodicColors.length;
                      cellColor = periodicColors[colorIndex];

                      final cyclePosition = dayOffset % totalCycleDays;
                      final sequences =
                          scheduleProvider.shiftSequences.where((seq) => seq.scheduleId == scheduleId).toList()
                            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

                      int currentDayIndex = 0;
                      for (final sequence in sequences) {
                        if (cyclePosition < currentDayIndex + sequence.consecutiveDays) {
                          final workShift = scheduleProvider.allWorkShifts.firstWhere(
                            (s) => s.id == sequence.workShiftId,
                            orElse: () => WorkShift.createDefault(),
                          );
                          shiftName = workShift.name;
                          break;
                        }
                        currentDayIndex += sequence.consecutiveDays;
                      }
                    } else {
                      cellColor = Colors.grey.withAlpha(77);
                      shiftName = '';
                    }

                    return Expanded(
                      child: CalendarCellWidget(
                        day: day,
                        currentDay: currentDay,
                        isToday: isToday,
                        cellHeight: cellHeight,
                        cellColor: cellColor,
                        shiftName: shiftName,
                        showShiftName: showShiftNames,
                        onTap: () {
                          if (scheduleProvider.hasExceptionForDate(currentDay, scheduleId)) {
                            showExceptionDetailsDialog(
                              context: context,
                              day: currentDay,
                              scheduleProvider: scheduleProvider,
                              scheduleId: scheduleId,
                            );
                          } else {
                            showDaySettingsDialog(
                              context: context,
                              day: currentDay,
                              scheduleProvider: scheduleProvider,
                              scheduleId: scheduleId,
                            );
                          }
                        },
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

  bool _isToday(int day) {
    final now = DateTime.now();
    return day == now.day && currentDate.month == now.month && currentDate.year == now.year;
  }
}
