import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext;

import 'package:sws/widgets/calendar_widget.dart';
import 'package:sws/widgets/schedule_shifts_statistics.dart';
import 'package:sws/providers/settings_provider.dart';

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
    final workShifts = context.read<SettingsProvider>().workShifts;
    final periodicColors = workShifts.map((shift) => shift.color).toList();

    return Scaffold(
      body: Column(
        children: [
          _buildMonthSwitcher(),
          Expanded(
            flex: 3,
            child: CalendarWidget(
              currentDate: _currentDate,
              daysInMonth: _daysInMonth,
              firstWeekday: _firstWeekday,
              periodicColors: periodicColors,
            ),
          ),
          Expanded(
            flex: 1,
            child: ScheduleShiftsStatistics(
              currentDate: _currentDate,
            ),
          ),
       ],
      ),
    );
  }

  Widget _buildMonthSwitcher() {
    return Column(
      children: [
        Container(
          color: _seaGreenDark,
          padding: const EdgeInsets.all(0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: _textColor),
                onPressed: _previousMonth,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _nowMonth,
                  child: Text(
                    _getMonthYearText(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: _buildLegendItem('Оранжевый', Colors.orange)),
          Expanded(child: _buildLegendItem('Красный', Colors.red)),
          Expanded(child: _buildLegendItem('Желтый', Colors.yellow)),
          Expanded(child: _buildLegendItem('Зеленый', Colors.green)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
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

  String _getMonthYearText() {
    const List<String> months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return '${months[_currentDate.month - 1]} ${_currentDate.year}';
  }
}
