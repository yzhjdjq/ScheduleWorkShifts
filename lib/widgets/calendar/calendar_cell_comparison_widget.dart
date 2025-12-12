import 'package:flutter/material.dart';
import 'package:sws/providers/providers.dart' show CalendarWidgetProvider;
import 'package:sws/widgets/calendar/calendar.dart' show DiagonalClipper, DiagonalLinePainter;

class CalendarCellComparisonWidget extends StatelessWidget {
  final bool isToday;
  final DateTime currentDay;
  final double cellHeight;
  final CalendarWidgetProvider calendarProvider;

  const CalendarCellComparisonWidget({
    super.key,
    required this.isToday,
    required this.currentDay,
    required this.cellHeight,
    required this.calendarProvider,
  });

  @override
  Widget build(BuildContext context) {
    final (firstColor, secondColor) = calendarProvider.getComparisonColorsForDate(currentDay);

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
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: Stack(
          children: <Widget>[
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
                currentDay.day.toString(),
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
