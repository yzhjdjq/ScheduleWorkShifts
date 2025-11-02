import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sws/models/work_shift.dart';
import 'package:sws/models/schedule.dart';

import 'package:sws/widgets/calendar_widget.dart';
import 'package:sws/widgets/schedule_shifts_statistics.dart';
import 'package:sws/providers/settings_provider.dart';
import 'package:sws/providers/schedule_provider.dart';
import 'package:sws/pages/about_page.dart';
import 'package:sws/pages/settings_page.dart';
import 'package:sws/pages/create_schedule_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _appVersion  = '0.2.0';

  late DateTime _currentDate;
  late int _daysInMonth;
  late int _firstWeekday;

  // Новые цвета на основе #0E879C
  final Color _primaryColor = const Color(0xFF0E879C);
  final Color _primaryLight = const Color(0xFF4DA8B8); // Более светлый вариант
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

  void _showComparisonSelectionDialog(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();
    final scheduleProvider = context.read<ScheduleProvider>();

    // Логика предзаполнения графиков
    String? firstScheduleId;
    String? secondScheduleId;

    // Если уже активно сопоставление - используем текущие графики
    if (scheduleProvider.isComparisonMode) {
      firstScheduleId = scheduleProvider.comparedScheduleIds[0];
      secondScheduleId = scheduleProvider.comparedScheduleIds[1];
    } else {
      // Ищем настроенные графики
      final configuredSchedules = settingsProvider.schedules.where((schedule) {
        return scheduleProvider.shiftSequences
            .any((seq) => seq.scheduleId == schedule.id);
      }).toList();

      if (configuredSchedules.length >= 2) {
        firstScheduleId = configuredSchedules[0].id;
        secondScheduleId = configuredSchedules[1].id;
      } else if (configuredSchedules.length == 1 && settingsProvider.schedules.length >= 2) {
        firstScheduleId = configuredSchedules[0].id;
        // Второй график - первый доступный, отличный от первого
        secondScheduleId = settingsProvider.schedules
            .where((schedule) => schedule.id != firstScheduleId)
            .firstOrNull
            ?.id;
      } else if (settingsProvider.schedules.length >= 2) {
        firstScheduleId = settingsProvider.schedules[0].id;
        secondScheduleId = settingsProvider.schedules[1].id;
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Получаем доступные графики для второго комбобокса
          final availableSecondSchedules = settingsProvider.schedules
              .where((schedule) => schedule.id != firstScheduleId)
              .toList();

          // Проверяем валидность текущих значений
          final isFirstScheduleValid = firstScheduleId != null &&
              settingsProvider.schedules.any((schedule) => schedule.id == firstScheduleId);

          final isSecondScheduleValid = secondScheduleId != null &&
              availableSecondSchedules.any((schedule) => schedule.id == secondScheduleId);

          // Автоматически исправляем невалидные значения
          if (!isFirstScheduleValid) {
            firstScheduleId = settingsProvider.schedules.firstOrNull?.id;
          }

          if (!isSecondScheduleValid || firstScheduleId == secondScheduleId) {
            secondScheduleId = availableSecondSchedules.firstOrNull?.id;
          }

          // Финальная проверка
          final areSchedulesDifferent = firstScheduleId != null &&
              secondScheduleId != null &&
              firstScheduleId != secondScheduleId;

          // Функция для обмена графиков местами
          void swapSchedules() {
            setState(() {
              final temp = firstScheduleId;
              firstScheduleId = secondScheduleId;
              secondScheduleId = temp;
            });
          }

          return AlertDialog(
            title: const Text('Сопоставление графиков'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Выбор первого графика
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Первый график',
                      border: OutlineInputBorder(),
                    ),
                    value: firstScheduleId,
                    items: settingsProvider.schedules.map((schedule) {
                      final hasSequences = scheduleProvider.shiftSequences
                          .any((seq) => seq.scheduleId == schedule.id);

                      return DropdownMenuItem<String>(
                        value: schedule.id,
                        child: Row(
                          children: [
                            Text(schedule.name),
                            if (!hasSequences)
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '(не настроен)',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        firstScheduleId = value;
                        // При изменении первого графика автоматически выбираем первый доступный второй график
                        final newAvailableSchedules = settingsProvider.schedules
                            .where((schedule) => schedule.id != firstScheduleId)
                            .toList();

                        secondScheduleId = newAvailableSchedules.firstOrNull?.id;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Кнопка обмена местами
                  if (areSchedulesDifferent)
                    IconButton(
                      onPressed: swapSchedules,
                      icon: const Icon(Icons.swap_vert),
                      tooltip: 'Поменять графики местами',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                  // Выбор второго графика
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Второй график',
                      border: OutlineInputBorder(),
                    ),
                    value: secondScheduleId,
                    items: availableSecondSchedules.map((schedule) {
                      final hasSequences = scheduleProvider.shiftSequences
                          .any((seq) => seq.scheduleId == schedule.id);

                      return DropdownMenuItem<String>(
                        value: schedule.id,
                        child: Row(
                          children: [
                            Text(schedule.name),
                            if (!hasSequences)
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '(не настроен)',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        secondScheduleId = value;
                      });
                    },
                  ),

                  // Информационное сообщение
                  if (availableSecondSchedules.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Нет доступных графиков для сравнения',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: areSchedulesDifferent && availableSecondSchedules.isNotEmpty
                    ? () {
                  scheduleProvider.enableComparisonMode(firstScheduleId!, secondScheduleId!);
                  Navigator.pop(context);
                }
                    : null,
                child: const Text('Сопоставить'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showScheduleSelectionDialog(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();
    final scheduleProvider = context.read<ScheduleProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите график'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: settingsProvider.schedules.length + 1, // +1 для пункта сравнения
            itemBuilder: (context, index) {
              // Последний пункт - сопоставление графиков
              if (index == settingsProvider.schedules.length) {
                final isComparisonActive = scheduleProvider.isComparisonMode;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                  child: ListTile(
                    title: const Text('Сопоставление графиков'),
                    leading: const Icon(Icons.compare),
                    trailing: isComparisonActive
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    tileColor: isComparisonActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showComparisonSelectionDialog(context);
                    },
                  ),
                );
              }

              final schedule = settingsProvider.schedules[index];
              final hasSequences = scheduleProvider.shiftSequences
                  .any((seq) => seq.scheduleId == schedule.id);
              final isActive = !scheduleProvider.isComparisonMode &&
                  scheduleProvider.isScheduleActive(schedule.id);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                child: ListTile(
                  title: Text(schedule.name),
                  subtitle: hasSequences
                      ? const Text('Настроен', style: TextStyle(color: Colors.green))
                      : const Text('Не настроен', style: TextStyle(color: Colors.orange)),
                  trailing: isActive
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  tileColor: isActive
                      ? Colors.green.withValues(alpha: 0.1)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    // Устанавливаем активный график и отключаем режим сравнения
                    scheduleProvider.disableComparisonMode();
                    scheduleProvider.setActiveSchedule(schedule.id);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  // Обновленный метод для получения заголовка AppBar
  String _getAppBarTitle(Schedule? activeSchedule, ScheduleProvider scheduleProvider, SettingsProvider settingsProvider) {
    if (scheduleProvider.isComparisonMode) {
      final firstSchedule = settingsProvider.schedules.firstWhere(
            (s) => s.id == scheduleProvider.comparedScheduleIds[0],
        orElse: () => Schedule(id: '', name: 'Неизвестно', startDate: DateTime.now()),
      );
      final secondSchedule = settingsProvider.schedules.firstWhere(
            (s) => s.id == scheduleProvider.comparedScheduleIds[1],
        orElse: () => Schedule(id: '', name: 'Неизвестно', startDate: DateTime.now()),
      );
      return '${firstSchedule.name} / ${secondSchedule.name}';
    }

    if (activeSchedule != null) {
      return activeSchedule.name;
    }
    return 'Главная';
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final scheduleProvider = context.watch<ScheduleProvider>();

    // Получаем активный график
    final activeScheduleId = scheduleProvider.getActiveScheduleId();
    Schedule? activeSchedule;
    if (activeScheduleId != null) {
      activeSchedule = settingsProvider.schedules.firstWhere(
            (schedule) => schedule.id == activeScheduleId,
        orElse: () => settingsProvider.schedules.isNotEmpty
            ? settingsProvider.schedules.first
            : Schedule.createDefault(),
      );
    }

    // Получаем цвета в зависимости от режима
    final List<Color> periodicColors;
    final List<List<Color>> comparisonColors;

    if (scheduleProvider.isComparisonMode) {
      periodicColors = [];
      comparisonColors = scheduleProvider.getColorsForComparison(
        settingsProvider.workShifts,
        _currentDate,
      );
    } else {
      comparisonColors = [[], []];
      periodicColors = activeScheduleId != null && scheduleProvider.hasSchedules
          ? scheduleProvider.getColorsForSchedule(
          activeScheduleId,
          settingsProvider.workShifts,
          _currentDate
      )
          : _getDefaultColors(settingsProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(activeSchedule, scheduleProvider, settingsProvider)),
        actions: [
          if (settingsProvider.schedules.length > 1)
            IconButton(
              icon: Icon(scheduleProvider.isComparisonMode
                  ? Icons.compare
                  : Icons.calendar_today),
              onPressed: () => _showScheduleSelectionDialog(context),
              tooltip: scheduleProvider.isComparisonMode
                  ? 'Режим сравнения'
                  : 'Выбрать график',
            ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          _buildMonthSwitcher(activeScheduleId, settingsProvider, scheduleProvider),

          SizedBox(height: 8),

          // Легенда цветов (если включена)
          if (settingsProvider.showShiftNameLegend)
            _buildColorLegend(activeScheduleId, settingsProvider, scheduleProvider),

          if (settingsProvider.showShiftNameLegend)
            SizedBox(height: 8),

          // Календарь
          Expanded(
            flex: 3,
            child: CalendarWidget(
              currentDate: _currentDate,
              daysInMonth: _daysInMonth,
              firstWeekday: _firstWeekday,
              periodicColors: periodicColors.isNotEmpty
                  ? periodicColors
                  : [Colors.grey],
              selectedScheduleId: activeScheduleId,
              isComparisonMode: scheduleProvider.isComparisonMode,
              comparisonColors: comparisonColors,
              showShiftNames: settingsProvider.showShiftName,
              scheduleProvider: scheduleProvider,
              settingsProvider: settingsProvider,
            ),
          ),

          // Статистика (всегда показывается, независимо от легенды)
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

  // Построение бокового меню
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildDrawerItem(
            icon: Icons.home,
            title: 'Главная',
            onTap: () {
              Navigator.pop(context); // Закрыть Drawer
              // Уже на главной странице
            },
          ),
          _buildDrawerItem(
            icon: Icons.schedule,
            title: 'Создать график',
            onTap: () {
              Navigator.pop(context); // Закрыть Drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateSchedulePage()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Настройки',
            onTap: () {
              Navigator.pop(context); // Закрыть Drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.info,
            title: 'О приложении',
            onTap: () {
              Navigator.pop(context); // Закрыть Drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Шапка Drawer
  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: _primaryColor, // Используем основной цвет
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 30,
            child: Text(
              'SWS',
              style: TextStyle(
                color: _primaryColor, // Используем основной цвет для текста
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'График смен',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Версия $_appVersion',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Элемент меню
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  // Диалог выхода
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выход'),
          content: const Text('Вы уверены, что хотите выйти?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Здесь логика выхода
              },
              child: const Text('Выйти'),
            ),
          ],
        );
      },
    );
  }

  List<Color> _getDefaultColors(SettingsProvider settingsProvider) {
    if (settingsProvider.workShifts.isEmpty) {
      return [Colors.blue, Colors.green];
    }
    return settingsProvider.workShifts.map((shift) => shift.color).toList();
  }

  Widget _buildMonthSwitcher(
      String? activeScheduleId,
      SettingsProvider settingsProvider,
      ScheduleProvider scheduleProvider
      ) {
    return Container(
          color: _primaryLight,
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
        );
  }

  // Обновим метод _buildColorLegend
  Widget _buildColorLegend(
      String? activeScheduleId,
      SettingsProvider settingsProvider,
      ScheduleProvider scheduleProvider
      ) {

    // Если флаг легенды выключен - не показываем ничего
    if (!settingsProvider.showShiftNameLegend) {
      return const SizedBox.shrink();
    }

    if (scheduleProvider.isComparisonMode) {
      return _buildComparisonLegend(settingsProvider, scheduleProvider);
    }

    // Старая логика для одиночного графика
    final workShifts = settingsProvider.workShifts;

    final List<WorkShift> shiftsToShow = activeScheduleId != null && scheduleProvider.hasSchedules
        ? _getUsedShiftsInSchedule(workShifts, scheduleProvider, activeScheduleId)
        : workShifts;

    if (shiftsToShow.isEmpty) {
      return Container();
    }

    return Container(
      color: Colors.white, // Светлый вариант основного цвета для легенды
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: shiftsToShow.map((shift) {
          return Expanded(
            child: _buildLegendItem(shift.name, shift.color),
          );
        }).toList(),
      ),
    );
  }

  // Обновим метод _buildComparisonLegend
  Widget _buildComparisonLegend(SettingsProvider settingsProvider, ScheduleProvider scheduleProvider) {
    final firstScheduleId = scheduleProvider.comparedScheduleIds[0];
    final secondScheduleId = scheduleProvider.comparedScheduleIds[1];

    final firstSchedule = settingsProvider.schedules.firstWhere(
          (s) => s.id == firstScheduleId,
      orElse: () => Schedule(id: '', name: 'Неизвестно', startDate: DateTime.now()),
    );
    final secondSchedule = settingsProvider.schedules.firstWhere(
          (s) => s.id == secondScheduleId,
      orElse: () => Schedule(id: '', name: 'Неизвестно', startDate: DateTime.now()),
    );

    final firstShifts = _getUsedShiftsInSchedule(
        settingsProvider.workShifts,
        scheduleProvider,
        firstScheduleId
    );
    final secondShifts = _getUsedShiftsInSchedule(
        settingsProvider.workShifts,
        scheduleProvider,
        secondScheduleId
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                ...firstShifts.map((shift) =>
                    Expanded(child: _buildLegendItem(shift.name, shift.color))
                ),
              ],
            ),
          ),
          // Легенда для второго графика
          Row(
            children: [
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
              ...secondShifts.map((shift) =>
                  Expanded(child: _buildLegendItem(shift.name, shift.color))
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<WorkShift> _getUsedShiftsInSchedule(
      List<WorkShift> allShifts,
      ScheduleProvider scheduleProvider,
      String scheduleId
      ) {
    final usedShiftIds = scheduleProvider.shiftSequences
        .where((seq) => seq.scheduleId == scheduleId)
        .map((seq) => seq.workShiftId)
        .toSet();

    return allShifts.where((shift) => usedShiftIds.contains(shift.id)).toList();
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
            style: const TextStyle(fontSize: 12),
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