import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _currentDate;
  late int _daysInMonth;
  late int _firstWeekday;

  // Цвета для календаря
  final Color _seaGreenLight = const Color(0xFF3CB371);
  final Color _seaGreenDark = const Color(0xFF228B22);
  final Color _textColor = Colors.white;

  // Цветовая палитра для периодической расцветки (цикл 4 дня)
  final List<Color> _periodicColors = [
    const Color(0xFFA64000), // День 1: Оранжевый
    Colors.red, // День 2: Красный
    Colors.yellow, // День 3: Желтый
    Colors.green, // День 4: Зеленый
  ];

  // Темные версии цветов для выделения текущего дня
  final List<Color> _periodicColorsDark = [
    Colors.orange.shade700, // Темно-оранжевый
    Colors.red.shade700, // Темно-красный
    Colors.yellow.shade700, // Темно-желтый
    Colors.green.shade700, // Темно-зеленый
  ];

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _calculateCalendarData();
  }

  void _calculateCalendarData() {
    _daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    _firstWeekday = DateTime(_currentDate.year, _currentDate.month, 1).weekday;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildCalendarHeader(context),
          _buildWeekDaysHeader(),
          // Ограничиваем высоту календаря и даем возможность уменьшаться
          Flexible(
            flex: 3, // 3 части из 4 для календаря
            child: _buildCalendarGrid(),
          ),
          const Divider(color: Colors.grey, indent: 8, endIndent: 8),
          Flexible(
            flex: 1, // 1 часть из 4 для статистики
            child: _buildScheduleShiftsStatistics(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(0),
          color: _seaGreenDark,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: _textColor),
                onPressed: _previousMonth,
              ),
              GestureDetector(
                onTap: _nowMonth,
                child: Text(
                  _getMonthYearText(),
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: _textColor),
                onPressed: _nextMonth,
              ),
            ],
          ),
        ),
        _buildColorLegend(),
      ],
    );
  }

  Widget _buildColorLegend() {
    return Container(
      color: _seaGreenLight,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('Оранжевый', Colors.orange),
          _buildLegendItem('Красный', Colors.red),
          _buildLegendItem('Желтый', Colors.yellow),
          _buildLegendItem('Зеленый', Colors.green),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10),
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
        // Вычисляем максимальную доступную высоту для календаря
        final maxHeight = constraints.maxHeight;

        return Container(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              for (int row = 0; row < 5; row++)
                Expanded(
                  child: Row(
                    children: [for (int col = 0; col < 7; col++)
                      Expanded(child: _buildCalendarCell(row, col))],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarCell(int row, int col) {
    final cellIndex = row * 7 + col;
    final totalCells = 35;

    // Проверяем, является ли ячейка пустой или содержит день
    if (cellIndex < _firstWeekday - 1 || cellIndex >= _firstWeekday - 1 + _daysInMonth) {
      return _buildEmptyCell();
    }

    final day = cellIndex - _firstWeekday + 2;
    return _buildDayCell(day);
  }

  Widget _buildScheduleShiftsStatistics() {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Календарные дни",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 12),
                ),
                Text(
                  _daysInMonth.toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 8, color: Colors.transparent),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Рабочие дни", style: TextStyle(color: Colors.black, fontSize: 12)),
                Text(
                  (_daysInMonth - 8).toString(), // Пример вычисления
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(int day) {
    final bool isToday = _isToday(day);
    final Color dayColor = _getDayColor(day);
    final Color dayColorDark = _getDayColorDark(day);

    // Базовый decoration
    BoxDecoration decoration = BoxDecoration(
      color: dayColor,
      borderRadius: BorderRadius.circular(4),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .1),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    );

    // Если сегодняшний день - добавляем особые стили
    if (isToday) {
      decoration = decoration.copyWith(
        color: dayColorDark,
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
        children: [
          Positioned(
            top: isToday ? 1 : 4,
            left: isToday ? 5 : 8,
            child: Text(
              day.toString(),
              style: TextStyle(
                color: _getTextColorForBackground(dayColor), // Автоподбор цвета текста
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                fontSize: _calculateFontSize(context),
                shadows: [
                  if (_needsTextShadow(dayColor))
                    Shadow(
                      color: Colors.black.withValues(alpha: .5),
                      blurRadius: 2,
                    ),
                ],
              ),
            ),
          ),
          Center(child: _buildCellContent(day)),
        ],
      ),
    );
  }

  // Адаптивный расчет размера шрифта
  double _calculateFontSize(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    if (screenHeight < 400) {
      return 10.0;
    } else if (screenHeight < 600) {
      return 12.0;
    } else if (screenHeight < 800) {
      return 14.0;
    } else {
      return 16.0;
    }
  }

  // Получение цвета для дня по циклу 4 дня
  Color _getDayColor(int day) {
    final int colorIndex = (day - 1) % _periodicColors.length;
    return _periodicColors[colorIndex];
  }

  // Получение темного цвета для выделения текущего дня
  Color _getDayColorDark(int day) {
    final int colorIndex = (day - 1) % _periodicColorsDark.length;
    return _periodicColorsDark[colorIndex];
  }

  // Получение цвета текста в зависимости от фона
  Color _getTextColorForBackground(Color backgroundColor) {
    final double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Проверка, нужна ли тень для текста
  bool _needsTextShadow(Color backgroundColor) {
    final double luminance = backgroundColor.computeLuminance();
    return luminance > 0.7; // Тень для очень светлых цветов
  }

  Widget _buildEmptyCell() {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildCellContent(int day) {
    // Можно добавить дополнительный контент в зависимости от дня
    final int dayType = (day - 1) % 4;

    switch (dayType) {
      default:
        return const SizedBox.shrink();
    }
  }

  bool _isToday(int day) {
    final DateTime now = DateTime.now();
    return day == now.day && _currentDate.month == now.month && _currentDate.year == now.year;
  }

  String _getMonthYearText() {
    const List<String> months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return '${months[_currentDate.month - 1]} ${_currentDate.year}';
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      _calculateCalendarData();
    });
  }
  void _nowMonth() {
    setState(() {
      _currentDate = DateTime.now();
      _calculateCalendarData();
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      _calculateCalendarData();
    });
  }
}
