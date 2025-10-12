import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime _currentDate;

  final int _daysInMonth;
  final int _firstWeekday;

  // Цвета для календаря
  final Color _seaGreenLight = const Color(0xFF3CB371);
  final Color _seaGreenDark = const Color(0xFF228B22);
  final Color _textColor =  Colors.white;

  // Цветовая палитра для периодической расцветки (цикл 4 дня)
  final List<Color> _periodicColors = const <Color>[
    Colors.orange, // День 1: Оранжевый
    Colors.red, // День 2: Красный
    Colors.yellow, // День 3: Желтый
    Colors.green, // День 4: Зеленый
  ];

  // Темные версии цветов для выделения текущего дня
  final List<Color> _periodicColorsDark = <Color>[
    Colors.orange.shade700, // Темно-оранжевый
    Colors.red.shade700, // Темно-красный
    Colors.yellow.shade700, // Темно-желтый
    Colors.green.shade700, // Темно-зеленый
  ];

  CalendarWidget({
    super.key,
    required DateTime currentDate,
    required int daysInMonth,
    required int firstWeekday,
  })
      : _currentDate = currentDate,
        _daysInMonth = daysInMonth,
        _firstWeekday = firstWeekday;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildWeekDaysHeader(),
        Expanded(
          child: _buildCalendarGrid(),
        ),
      ],
    );
  }

  Widget _buildWeekDaysHeader() {
    const List<String> weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return Container(
      color: _seaGreenLight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: weekDays.map((day) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: _seaGreenDark, width: 0.5),
            ),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textColor,
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
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
                  children: List.generate(7, (col) =>
                    Expanded(
                      child: _buildCalendarCell(row, col, cellHeight),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildCalendarCell(int row, int col, double cellHeight) {
    const int dayInWeek = 7;
    final cellIndex = row * dayInWeek + col;

    if (cellIndex < _firstWeekday - 1 || cellIndex >= _firstWeekday - 1 + _daysInMonth) {
      return const _CalendarCellEmptyWidget();
    } else {
      int day = cellIndex - _firstWeekday + 2;
      bool isToday = _isToday(day);
      Color dayColor = _getDayColor(day);
      Color dayCurrentColor = _getDayColorDark(day);
      double fontSize = _calculateFontSize(cellHeight);
      return _CalendarCellWidget(
          day: day,
          isToday: isToday,
          dayColor: dayColor,
          dayCurrentColor: dayCurrentColor,
          fontSize: fontSize,
      );
    }
  }

  double _calculateFontSize(double cellHeight) {
    if (cellHeight < 30) {
      return 10.0;
    } else if (cellHeight < 60) {
      return 12.0;
    } else if (cellHeight < 100) {
      return 14.0;
    } else {
      return 16.0;
    }
  }

  Color _getDayColor(int day) {
    final int colorIndex = (day - 1) % _periodicColors.length;
    return _periodicColors[colorIndex];
  }

  Color _getDayColorDark(int day) {
    final int colorIndex = (day - 1) % _periodicColorsDark.length;
    return _periodicColorsDark[colorIndex];
  }

  bool _isToday(int day) {
    final DateTime now = DateTime.now();
    return day == now.day && _currentDate.month == now.month && _currentDate.year == now.year;
  }
}

class _CalendarCellWidget extends StatelessWidget {
  final int _day;
  final bool _isToday;
  final Color _dayColor;
  final Color _dayCurrentColor;
  final double _fontSize;

  const _CalendarCellWidget({
    super.key,
    required int day,
    required bool isToday,
    required Color dayColor,
    required Color dayCurrentColor,
    required double fontSize,
  })
    : _day = day,
      _isToday = isToday,
      _dayColor = dayColor,
      _dayCurrentColor = dayCurrentColor,
      _fontSize = fontSize;


  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration = BoxDecoration(
      color: _dayColor,
      borderRadius: BorderRadius.circular(4),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .1),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    );

    if (_isToday) {
      decoration = decoration.copyWith(
        color: _dayCurrentColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.black, width: 3),
      );
    }

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: decoration,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: _isToday ? 1 : 4,
            left: _isToday ? 5 : 8,
            child: Text(
              _day.toString(),
              style: TextStyle(
                color: _getTextColorForBackground(_dayColor),
                fontWeight: _isToday ? FontWeight.bold : FontWeight.normal,
                fontSize: _fontSize,
                shadows: <Shadow>[
                  if (_needsTextShadow(_dayColor))
                    Shadow(
                      color: Colors.black.withValues(alpha: .5),
                      blurRadius: 2,
                    ),
                ],
              ),
            ),
          ),
          Center(child: Text(_day.toString())),
        ],
      ),
    );
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    final double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  bool _needsTextShadow(Color backgroundColor) {
    final double luminance = backgroundColor.computeLuminance();
    return luminance > 0.7;
  }
}

class _CalendarCellEmptyWidget extends StatelessWidget {
  const _CalendarCellEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}