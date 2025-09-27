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
  final Color _seaGreen = const Color(0xFF2E8B57);
  final Color _seaGreenLight = const Color(0xFF3CB371);
  final Color _seaGreenDark = const Color(0xFF228B22);
  final Color _textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now(); // Инициализируем здесь
    _calculateCalendarData();
  }

  void _calculateCalendarData() {
    // Количество дней в текущем месяце
    _daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;

    // Первый день месяца (1 = Monday, 7 = Sunday)
    _firstWeekday = DateTime(_currentDate.year, _currentDate.month, 1).weekday;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Заголовок с текущим месяцем и годом
          _buildCalendarHeader(context),

          // Дни недели
          _buildWeekDaysHeader(),

          // Сетка календаря
          Expanded(
            child: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  // Заголовок календаря
  Widget _buildCalendarHeader(BuildContext context) {
    return Container(
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
    );
  }

  // Заголовок дней недели
  Widget _buildWeekDaysHeader() {
    const List<String> weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return Container(
      color: _seaGreenLight,
      padding: EdgeInsets.symmetric(horizontal: 6),
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

  // Сетка календаря
  Widget _buildCalendarGrid() {
    final int totalCells = 35; // 5 недель × 7 дней
    final List<Widget> cells = [];

    // Добавляем пустые ячейки перед первым днем месяца
    for (int i = 1; i < _firstWeekday; i++) {
      cells.add(_buildEmptyCell());
    }

    // Добавляем ячейки с днями месяца
    for (int day = 1; day <= _daysInMonth; day++) {
      cells.add(_buildDayCell(day));
    }

    // Добавляем пустые ячейки после последнего дня месяца
    final int remainingCells = totalCells - cells.length;
    for (int i = 0; i < remainingCells; i++) {
      cells.add(_buildEmptyCell());
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 1.0,
      padding: EdgeInsets.all(6),
      children: cells,
    );
  }

  // Ячейка с днем
  Widget _buildDayCell(int day) {
    final bool isToday = _isToday(day);

    // Базовый decoration
    BoxDecoration decoration = BoxDecoration(
      color: _seaGreen,
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
        color: _seaGreenDark,
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
                color: _textColor,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                fontSize: isToday ? 18 : 16,
              ),
            ),
          ),
          Center(child: _buildCellContent(day)),
        ],
      ),
    );
  }

  // Пустая ячейка
  Widget _buildEmptyCell() {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: _seaGreen.withValues(alpha: .3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Содержимое ячейки (можно кастомизировать)
  Widget _buildCellContent(int day) {
    // Пример: показываем точку если день кратен 5
    if (day % 5 == 0) {
      return Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // Проверка, является ли день сегодняшним
  bool _isToday(int day) {
    final DateTime now = DateTime.now();
    return day == now.day &&
        _currentDate.month == now.month &&
        _currentDate.year == now.year;
  }

  // Текст с месяцем и годом
  String _getMonthYearText() {
    const List<String> months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];

    return '${months[_currentDate.month - 1]} ${_currentDate.year}';
  }

  // Переход к предыдущему месяцу
  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      _calculateCalendarData();
    });
  }

  // Переход к следующему месяцу
  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      _calculateCalendarData();
    });
  }
}