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
  // final Color _seaGreen = const Color(0xFF2E8B57);
  final Color _seaGreenLight = const Color(0xFF3CB371);
  final Color _seaGreenDark = const Color(0xFF228B22);
  final Color _textColor = Colors.white;

  // Цветовая палитра для периодической расцветки (цикл 4 дня)
  final List<Color> _periodicColors = [
    Color(0xFFA64000),      // День 1: Оранжевый
    Colors.red,         // День 2: Красный
    Colors.yellow,      // День 3: Желтый
    Colors.green,       // День 4: Зеленый
  ];

  // Темные версии цветов для выделения текущего дня
  final List<Color> _periodicColorsDark = [
    Colors.orange.shade700,     // Темно-оранжевый
    Colors.red.shade700,        // Темно-красный
    Colors.yellow.shade700,     // Темно-желтый
    Colors.green.shade700,      // Темно-зеленый
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
          Expanded(child: _buildCalendarGrid()),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: _seaGreenDark,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: _textColor),
                onPressed: _previousMonth,
              ),
              Text(
                _getMonthYearText(),
                style: TextStyle(
                  color: _textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
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
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: weekDays.map((day) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
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
    final int totalCells = 35;
    final List<Widget> cells = [];

    for (int i = 1; i < _firstWeekday; i++) {
      cells.add(_buildEmptyCell());
    }

    for (int day = 1; day <= _daysInMonth; day++) {
      cells.add(_buildDayCell(day));
    }

    final int remainingCells = totalCells - cells.length;
    for (int i = 0; i < remainingCells; i++) {
      cells.add(_buildEmptyCell());
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 1.0,
      padding: const EdgeInsets.all(6),
      children: cells,
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
            top: 4,
            left: 8,
            child: Text(
              day.toString(),
              style: TextStyle(
                color: _getTextColorForBackground(dayColor), // Автоподбор цвета текста
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                fontSize: isToday ? 18 : 16,
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
    // Вычисляем яркость цвета
    final double luminance = backgroundColor.computeLuminance();
    // Если цвет светлый - используем черный текст, если темный - белый
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

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      _calculateCalendarData();
    });
  }
}