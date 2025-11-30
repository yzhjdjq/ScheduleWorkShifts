import 'package:flutter/material.dart';
import 'package:sws/providers/schedule_provider.dart' show ScheduleProvider;
import 'package:sws/widgets/diagonal_clipper.dart' show DiagonalClipper;
import 'package:sws/widgets/diagonal_line_painter.dart' show DiagonalLinePainter;

class CalendarCellComparisonWidget extends StatelessWidget {
  final int day;
  final bool isToday;
  final DateTime currentDay;
  final ScheduleProvider scheduleProvider;
  final double cellHeight;

  const CalendarCellComparisonWidget({
    super.key,
    required this.day,
    required this.isToday,
    required this.currentDay,
    required this.scheduleProvider,
    required this.cellHeight,
  });

  @override
  Widget build(BuildContext context) {
    final colors = scheduleProvider.getComparisonColorsForDate(currentDay, scheduleProvider.workShifts);
    final firstColor = colors[0];
    final secondColor = colors[1];

    final firstColorDark = _getDarkenedColor(firstColor);
    final secondColorDark = _getDarkenedColor(secondColor);

    final fontSize = _calculateFontSize(cellHeight);

    BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 2, offset: const Offset(0, 1))],
    );

    if (isToday) {
      decoration = decoration.copyWith(
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(77), blurRadius: 4, offset: const Offset(0, 2))],
      );
    }

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            ClipPath(clipper: const DiagonalClipper(), child: Container(color: isToday ? firstColorDark : firstColor)),
            ClipPath(
              clipper: const DiagonalClipper(reverse: true),
              child: Container(color: isToday ? secondColorDark : secondColor),
            ),
            CustomPaint(painter: const DiagonalLinePainter(), size: Size.infinite),
            Positioned(
              top: isToday ? 1 : 4,
              left: isToday ? 5 : 8,
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: _getTextColorForComparison(isToday ? firstColorDark : firstColor),
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: fontSize,
                  shadows:
                      _needsTextShadow(isToday ? firstColorDark : firstColor)
                          ? [Shadow(color: Colors.black.withAlpha(128), blurRadius: 2)]
                          : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDarkenedColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness(hsl.lightness * 0.75).toColor();
  }

  Color _getTextColorForComparison(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  bool _needsTextShadow(Color color) {
    return color.computeLuminance() > 0.7;
  }

  double _calculateFontSize(double cellHeight) {
    if (cellHeight < 30) return 10;
    if (cellHeight < 60) return 12;
    if (cellHeight < 100) return 14;
    return 16;
  }
}
