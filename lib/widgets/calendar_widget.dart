import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:sws/models/work_shift.dart';
import 'package:sws/providers/schedule_provider.dart';
import 'package:sws/providers/settings_provider.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime _currentDate;
  final int _daysInMonth;
  final int _firstWeekday;
  final List<Color> _periodicColors;
  final String? _selectedScheduleId;
  final bool _isComparisonMode;
  final List<List<Color>> _comparisonColors;
  final bool _showShiftNames; // Новый параметр
  final ScheduleProvider _scheduleProvider; // Новый параметр
  final SettingsProvider _settingsProvider; // Новый параметр

  const CalendarWidget({
    super.key,
    required DateTime currentDate,
    required int daysInMonth,
    required int firstWeekday,
    required List<Color> periodicColors,
    required String? selectedScheduleId,
    required bool isComparisonMode,
    required List<List<Color>> comparisonColors,
    required bool showShiftNames,
    required ScheduleProvider scheduleProvider,
    required SettingsProvider settingsProvider,
  }) : _currentDate = currentDate,
       _daysInMonth = daysInMonth,
       _firstWeekday = firstWeekday,
       _periodicColors = periodicColors,
       _selectedScheduleId = selectedScheduleId,
       _isComparisonMode = isComparisonMode,
       _comparisonColors = comparisonColors,
       _showShiftNames = showShiftNames,
       _scheduleProvider = scheduleProvider,
       _settingsProvider = settingsProvider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[_buildWeekDaysHeader(), Expanded(child: _buildCalendarGrid(context, _scheduleProvider))],
    );
  }

  Widget _buildWeekDaysHeader() {
    const List<String> weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return Container(
      color: Colors.grey.withValues(alpha: .2),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children:
            weekDays
                .map(
                  (day) => Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          vertical: BorderSide(color: Colors.white, width: 1),
                        ), // Основной цвет для границ
                      ),
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, ScheduleProvider scheduleProvider) {
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
                  children: List.generate(
                    7,
                    (col) => Expanded(child: _buildCalendarCell(context, row, col, cellHeight, scheduleProvider)),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildCalendarCell(BuildContext context, int row, int col, double cellHeight, ScheduleProvider scheduleProvider) {
    const int dayInWeek = 7;
    final cellIndex = row * dayInWeek + col;

    if (cellIndex < _firstWeekday - 1 || cellIndex >= _firstWeekday - 1 + _daysInMonth) {
      return const _CalendarCellEmptyWidget();
    } else {
      int day = cellIndex - _firstWeekday + 2;
      bool isToday = _isToday(day);

      final currentDay = DateTime(_currentDate.year, _currentDate.month, day);

      if (_isComparisonMode) {
        return _ComparisonCalendarCellWidget(
          day: day,
          isToday: isToday,
          currentDay: currentDay,
          scheduleProvider: _scheduleProvider,
          comparisonColors: _comparisonColors,
          fontSize: _calculateFontSize(cellHeight),
          settingsProvider: _settingsProvider,
        );
      } else {
        // Обычный режим - получаем цвет с учетом исключений
        final dayOffset = _selectedScheduleId != null
            ? _scheduleProvider.getDayOffsetForSchedule(_selectedScheduleId, currentDay)
            : _scheduleProvider.getDayOffsetForActiveSchedule(currentDay);

        Color dayColor = _getColorWithExceptions(currentDay, dayOffset, scheduleProvider);
        Color dayCurrentColor = _getDarkenedColor(dayColor);

        double fontSize = _calculateFontSize(cellHeight);

        return _CalendarCellWidget(
          day: day,
          isToday: isToday,
          dayColor: isToday ? dayCurrentColor : dayColor,
          dayCurrentColor: dayCurrentColor,
          fontSize: fontSize,
          showShiftNames: _showShiftNames,
          currentDay: currentDay,
          scheduleProvider: _scheduleProvider,
          settingsProvider: _settingsProvider,
          onTap: () => _onDayTapped(context, currentDay, scheduleProvider, _settingsProvider), // Передаем context
        );
      }
    }
  }

  void _showExceptionDetailsDialog(
      BuildContext context,
      DateTime day,
      ScheduleProvider scheduleProvider,
      SettingsProvider settingsProvider,
      String scheduleId
      ) {
    final exception = scheduleProvider.getExceptionForDate(day, scheduleId);
    if (exception == null) return;

    final workShift = settingsProvider.allWorkShifts.firstWhere(
          (shift) => shift.id == exception.workShiftId,
      orElse: () => WorkShift.createDefault(),
    );

    final DateFormat dateFormat = DateFormat('d MMMM yyyy', 'ru');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          dateFormat.format(day),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                workShift.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 16),

            // Период
            const Text(
              'Период:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              '${exception.startDate.day}.${exception.startDate.month}.${exception.startDate.year} - '
                  '${exception.endDate.day}.${exception.endDate.month}.${exception.endDate.year}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  scheduleProvider.removeScheduleException(exception.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${workShift.name} удален'))
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Удалить'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
            ]
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  void _onDayTapped(BuildContext context, DateTime day, ScheduleProvider scheduleProvider, SettingsProvider settingsProvider) {
    final activeScheduleId = _selectedScheduleId ?? scheduleProvider.getActiveScheduleId();
    if (activeScheduleId == null) return;

    // Проверяем, есть ли исключение для этого дня
    if (scheduleProvider.hasExceptionForDate(day, activeScheduleId)) {
      _showExceptionDetailsDialog(context, day, scheduleProvider, settingsProvider, activeScheduleId);
    }
    // Для обычных смен пока ничего не делаем (оставим на будущее)
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

  Color _getColorWithExceptions(DateTime date, int dayOffset, ScheduleProvider scheduleProvider) {
    final scheduleId = _selectedScheduleId ?? scheduleProvider.getActiveScheduleId() ?? '';

    // Проверяем исключения
    if (scheduleProvider.hasExceptionForDate(date, scheduleId)) {
      final exception = scheduleProvider.getExceptionForDate(date, scheduleId);
      final workShift = _settingsProvider.allWorkShifts.firstWhere(
            (shift) => shift.id == exception!.workShiftId,
        orElse: () => WorkShift.createDefault(),
      );
      return workShift.color;
    }

    // Обычная логика если исключений нет
    if (_periodicColors.isEmpty) return Colors.grey;

    if (dayOffset < 0) {
      return Colors.grey.withValues(alpha: 0.3);
    }

    final int colorIndex = dayOffset % _periodicColors.length;
    return _periodicColors[colorIndex];
  }

  Color _getDarkenedColor(Color color) {
    final HSLColor hslColor = HSLColor.fromColor(color);
    return hslColor.withLightness(hslColor.lightness * 0.75).toColor();
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
  final bool _showShiftNames;
  final DateTime _currentDay;
  final ScheduleProvider _scheduleProvider;
  final SettingsProvider _settingsProvider;
  final VoidCallback _onTap; // Добавляем callback

  const _CalendarCellWidget({
    required int day,
    required bool isToday,
    required Color dayColor,
    required Color dayCurrentColor,
    required double fontSize,
    required bool showShiftNames,
    required DateTime currentDay,
    required ScheduleProvider scheduleProvider,
    required SettingsProvider settingsProvider,
    required VoidCallback onTap, // Добавляем параметр
  }) : _day = day,
        _isToday = isToday,
        _dayColor = dayColor,
        _dayCurrentColor = dayCurrentColor,
        _fontSize = fontSize,
        _showShiftNames = showShiftNames,
        _currentDay = currentDay,
        _scheduleProvider = scheduleProvider,
        _settingsProvider = settingsProvider,
        _onTap = onTap;

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration = BoxDecoration(
      color: _dayColor,
      borderRadius: BorderRadius.circular(4),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2, offset: const Offset(0, 1))],
    );

    if (_isToday) {
      decoration = decoration.copyWith(
        color: _dayCurrentColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.black, width: 3),
      );
    }

    // Получаем название смены для этого дня
    final shiftName = _getShiftNameForDay();

    return GestureDetector(
      onTap: _onTap, // Добавляем обработчик нажатия
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: decoration,
        child: Stack(
          children: <Widget>[
            // Число дня в левом верхнем углу
            Positioned(
              top: _isToday ? 1 : 4,
              left: _isToday ? 5 : 8,
              child: Text(
                _day.toString(),
                style: TextStyle(
                  color: _getTextColorForBackground(_dayColor),
                  fontWeight: _isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: _fontSize,
                  shadows: _needsTextShadow(_dayColor)
                      ? <Shadow>[Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 2)]
                      : null,
                ),
              ),
            ),
            // Название смены в центре (если включено)
            if (_showShiftNames && shiftName.isNotEmpty)
              Center(
                child: Text(
                  shiftName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _getTextColorForBackground(_dayColor),
                    fontSize: _fontSize * 0.8,
                    shadows: _needsTextShadow(_dayColor)
                        ? <Shadow>[Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 1)]
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // В классе _CalendarCellWidget обновим метод _getShiftNameForDay
  String _getShiftNameForDay() {
    final activeScheduleId = _scheduleProvider.getActiveScheduleId();
    if (activeScheduleId == null) return '';

    // Сначала проверяем, есть ли исключение для этого дня
    if (_scheduleProvider.hasExceptionForDate(_currentDay, activeScheduleId)) {
      final exception = _scheduleProvider.getExceptionForDate(_currentDay, activeScheduleId);
      final workShift = _settingsProvider.allWorkShifts.firstWhere(
            (shift) => shift.id == exception!.workShiftId,
        orElse: () => WorkShift.createDefault(),
      );
      return workShift.name; // Показываем название отпуска/больничного
    }

    // Если исключений нет, показываем обычную смену
    final totalCycleDays = _scheduleProvider.getTotalCycleDaysForSchedule(activeScheduleId);
    if (totalCycleDays == 0) return '';

    final dayOffset = _scheduleProvider.getDayOffsetForActiveSchedule(_currentDay);
    if (dayOffset < 0) return '';

    final cyclePosition = dayOffset % totalCycleDays;
    final sequences = _scheduleProvider.shiftSequences.where((seq) => seq.scheduleId == activeScheduleId).toList();

    if (sequences.isEmpty) return '';

    sequences.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    int currentDay = 0;
    for (final sequence in sequences) {
      if (cyclePosition < currentDay + sequence.consecutiveDays) {
        final workShift = _settingsProvider.allWorkShifts.firstWhere(
              (shift) => shift.id == sequence.workShiftId,
          orElse: () => WorkShift.createDefault(),
        );
        return workShift.name;
      }
      currentDay += sequence.consecutiveDays;
    }

    return '';
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
  const _CalendarCellEmptyWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: .2), borderRadius: BorderRadius.circular(4)),
    );
  }
}

class _ComparisonCalendarCellWidget extends StatelessWidget {
  final int _day;
  final bool _isToday;
  final DateTime _currentDay;
  final ScheduleProvider _scheduleProvider;
  final double _fontSize;
  final SettingsProvider _settingsProvider;

  const _ComparisonCalendarCellWidget({
    required int day,
    required bool isToday,
    required DateTime currentDay,
    required ScheduleProvider scheduleProvider,
    required List<List<Color>> comparisonColors,
    required double fontSize,
    required SettingsProvider settingsProvider,
  }) : _day = day,
        _isToday = isToday,
        _currentDay = currentDay,
        _scheduleProvider = scheduleProvider,
        _fontSize = fontSize,
        _settingsProvider = settingsProvider;

  @override
  Widget build(BuildContext context) {
    final colors = _scheduleProvider.getComparisonColorsForDate(
        _currentDay,
        _settingsProvider.workShifts,
        _settingsProvider
    );

    Color firstColor = colors[0];
    Color secondColor = colors[1];

    final firstColorDark = _getDarkenedColor(firstColor);
    final secondColorDark = _getDarkenedColor(secondColor);

    BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2, offset: const Offset(0, 1))],
    );

    if (_isToday) {
      decoration = decoration.copyWith(
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [BoxShadow(color: Colors.black.withValues( alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
      );
    }

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            // Диагональное разделение ячейки
            ClipPath(
              clipper: DiagonalClipper(),
              child: Container(
                color: _isToday ? firstColorDark : firstColor,
              ),
            ),
            ClipPath(
              clipper: DiagonalClipper(reverse: true),
              child: Container(
                color: _isToday ? secondColorDark : secondColor,
              ),
            ),
            // Диагональная разделительная линия
            CustomPaint(painter: DiagonalLinePainter(), size: Size.infinite),
            // Число дня в левом верхнем углу
            Positioned(
              top: _isToday ? 1 : 4,
              left: _isToday ? 5 : 8,
              child: Text(
                _day.toString(),
                style: TextStyle(
                  color: _getTextColorForComparison(_isToday ? firstColorDark : firstColor),
                  fontWeight: _isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: _fontSize,
                  shadows: _needsTextShadow(_isToday ? firstColorDark : firstColor)
                      ? <Shadow>[Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 2)]
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
    final HSLColor hslColor = HSLColor.fromColor(color);
    return hslColor.withLightness(hslColor.lightness * 0.75).toColor();
  }

  Color _getTextColorForComparison(Color firstColor) {
    final luminance = firstColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  bool _needsTextShadow(Color firstColor) {
    final luminance = firstColor.computeLuminance();
    return luminance > 0.7;
  }
}

// Кастомный painter для диагональной линии
class DiagonalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    // Рисуем диагональную линию от левого нижнего до правого верхнего угла
    final path =
        Path()
          ..moveTo(0, size.height)
          ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Кастомный clipper для диагонального разделения
class DiagonalClipper extends CustomClipper<Path> {
  final bool reverse;

  DiagonalClipper({this.reverse = false});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (reverse) {
      path.moveTo(0, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
