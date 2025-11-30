import 'package:flutter/material.dart';

class CalendarCellWidget extends StatelessWidget {
  final int day;
  final DateTime currentDay;
  final bool isToday;
  final double cellHeight;
  final Color cellColor;
  final String shiftName;
  final bool showShiftName;
  final VoidCallback onTap;

  const CalendarCellWidget({
    super.key,
    required this.day,
    required this.currentDay,
    required this.isToday,
    required this.cellHeight,
    required this.cellColor,
    required this.shiftName,
    required this.showShiftName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cellColorDark = _getDarkenedColor(cellColor);
    final fontSize = _calculateFontSize(cellHeight);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isToday ? cellColorDark : cellColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isToday ? 77 : 26),
              blurRadius: isToday ? 4 : 2,
              offset: const Offset(0, 2),
            ),
          ],
          border: isToday ? Border.all(color: Colors.black, width: 3) : null,
        ),
        child: Stack(
          children: [
            Positioned(
              top: isToday ? 1 : 4,
              left: isToday ? 5 : 8,
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: _getTextColorForBackground(isToday ? cellColorDark : cellColor),
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: fontSize,
                  shadows:
                      _needsTextShadow(isToday ? cellColorDark : cellColor)
                          ? const [Shadow(color: Colors.black87, blurRadius: 2)]
                          : null,
                ),
              ),
            ),
            if (showShiftName)
              Center(
                child: Text(
                  shiftName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _getTextColorForBackground(isToday ? cellColorDark : cellColor),
                    fontSize: fontSize * 0.8,
                    shadows:
                        _needsTextShadow(isToday ? cellColorDark : cellColor)
                            ? const [Shadow(color: Colors.black54, blurRadius: 1)]
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

  Color _getTextColorForBackground(Color color) {
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
