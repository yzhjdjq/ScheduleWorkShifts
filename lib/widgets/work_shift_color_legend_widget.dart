import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext;
import 'package:sws/providers/providers.dart'
    show WorkShiftColorLegendWidgetProvider, WorkShiftItemViewModel;

mixin _WorkShiftColorLegendItem {
  Widget buildLegendItem(String text, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class WorkShiftColorLegendWidget extends StatelessWidget
    with _WorkShiftColorLegendItem {
  final String? _activeScheduleId;
  final Color _primaryLight;

  const WorkShiftColorLegendWidget({
    super.key,
    required String? activeScheduleId,
    required Color primaryLight,
  }) : _activeScheduleId = activeScheduleId,
       _primaryLight = primaryLight;

  @override
  Widget build(BuildContext context) {
    final pageProvider = context.read<WorkShiftColorLegendWidgetProvider>();

    if (!pageProvider.showShiftNameLegend() ||
        !pageProvider.hasSchedules() ||
        _activeScheduleId == null) {
      return const SizedBox.shrink();
    }

    if (pageProvider.isComparisonMode) {
      return _WorkShiftComparisonColorLegendWidget(primaryLight: _primaryLight);
    }

    final List<WorkShiftItemViewModel> shiftsToShow = pageProvider
        .getUsedShiftsInSchedule(_activeScheduleId);

    if (shiftsToShow.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            shiftsToShow.map((shift) {
              return Expanded(child: buildLegendItem(shift.name, shift.color));
            }).toList(),
      ),
    );
  }
}

class _WorkShiftComparisonColorLegendWidget extends StatelessWidget
    with _WorkShiftColorLegendItem {
  final Color _primaryLight;

  const _WorkShiftComparisonColorLegendWidget({required Color primaryLight})
    : _primaryLight = primaryLight;

  @override
  Widget build(BuildContext context) {
    final pageProvider = context.read<WorkShiftColorLegendWidgetProvider>();

    final firstSchedule = pageProvider.comparedSchedules.first;
    final secondSchedule = pageProvider.comparedSchedules.last;
    final (firstShifts, secondShifts) =
        pageProvider.getUsedShiftsInComparedSchedules();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    firstSchedule.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ...firstShifts.map(
                  (shift) =>
                      Expanded(child: buildLegendItem(shift.name, shift.color)),
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  secondSchedule.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ...secondShifts.map(
                (shift) =>
                    Expanded(child: buildLegendItem(shift.name, shift.color)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
