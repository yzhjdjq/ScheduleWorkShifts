import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext, WatchContext;
import 'package:sws/providers/model_providers/model_providers.dart';
import 'package:sws/widgets/widgets.dart'
    show CalendarWidget, MainDrawer, ScheduleShiftsStatisticsWidget, showDaySettingsDialog, showExceptionDetailsDialog;
import 'package:sws/providers/providers.dart'
    show
        CalendarWidgetProvider,
        HomePageProvider,
        ScheduleItemViewModel,
        SnackBarMessageProvider,
        WorkShiftItemViewModel;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _currentDate;
  late int _daysInMonth;
  late int _firstWeekday;

  static const Color _primaryColor = Color(0xFF0E879C);
  static const Color _primaryLight = Color(0xFF4DA8B8);
  static const Color _textColor = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _calculateCalendarData();
  }

  @override
  Widget build(BuildContext context) {
    final pageProvider = context.watch<HomePageProvider>();

    final ScheduleItemViewModel? activeSchedule = pageProvider.activeSchedule;

    final List<Color> periodicColors;
    final List<List<Color>> comparisonColors;

    if (pageProvider.isComparisonMode) {
      periodicColors = [];
      comparisonColors = pageProvider.getColorsForComparison(_currentDate);
    } else {
      comparisonColors = [[], []];
      periodicColors = pageProvider.getColorsForActiveSchedule(_currentDate);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pageProvider.getAppBarTitleText()),
        actions: <Widget>[
          if (pageProvider.hasSchedules())
            IconButton(
              icon: Icon(pageProvider.isComparisonMode ? Icons.compare : Icons.calendar_today),
              onPressed: () => _showScheduleSelectionDialog(context),
              tooltip: pageProvider.isComparisonMode ? 'Режим сравнения' : 'Выбрать график',
            ),
        ],
      ),
      drawer: const MainDrawer(color: _primaryColor),
      body: Column(
        children: <Widget>[
          _buildMonthSwitcher(),

          const SizedBox(height: 8),

          if (pageProvider.showShiftNameLegend() && (periodicColors.isNotEmpty || comparisonColors.isNotEmpty))
            _buildColorLegend(activeSchedule?.id, pageProvider),

          if (pageProvider.showShiftNameLegend()) const SizedBox(height: 8),

          Expanded(
            flex: 3,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  _previousMonth();
                } else if (details.primaryVelocity! < 0) {
                  _nextMonth();
                }
              },
              child: CalendarWidget(
                currentDate: _currentDate,
                daysInMonth: _daysInMonth,
                firstWeekday: _firstWeekday,
                onDayCellTap: _onDayCellTap,
                calendarProvider: context.read<CalendarWidgetProvider>(),
              ),
            ),
          ),

          Expanded(flex: 1, child: ScheduleShiftsStatisticsWidget(currentDate: _currentDate)),
        ],
      ),
    );
  }

  void _onDayCellTap(DateTime date, WorkShiftItemViewModel workShift) {
    final pageProvider = context.read<HomePageProvider>();
    if (pageProvider.hasExceptionForDateByActiveSchedule(date)) {
      final ScheduleExceptionItemViewModel scheduleException = pageProvider.getExceptionForDateByActiveSchedule(date)!;
      showExceptionDetailsDialog(
        context: context,
        day: date,
        scheduleException: scheduleException,
        workShift: workShift,
        isNotStaticShiftScheduleException: pageProvider.isNotStaticShiftScheduleException(scheduleException),
        onEditBtnClick: _onEditDayScheduleExceptionBtnClick,
        onDeleteBtnClick: (se) => pageProvider.removeScheduleException(se.id),
      );
    } else {
      showDaySettingsDialog(
        context: context,
        day: date,
        selectedShift: workShift,
        selectedShiftIsException: false,
        workShifts: pageProvider.workShifts,
        workingTime: pageProvider.getWorkingTimeForWorkShift(workShift),
        onDeleteExceptionBtnClick: () {},
        onSaveExceptionBtnClick: pageProvider.addScheduleExceptionForDay,
      );
    }
  }

  void _onEditDayScheduleExceptionBtnClick(
    ScheduleExceptionItemViewModel scheduleException,
    DateTime day,
    WorkShiftItemViewModel workShift,
  ) {
    final pageProvider = context.read<HomePageProvider>();
    showDaySettingsDialog(
      context: context,
      day: day,
      selectedShift: workShift,
      selectedShiftIsException: true,
      workShifts: pageProvider.workShifts,
      workingTime: scheduleException.workingTime ?? WorkingTimeViewModel(),
      onDeleteExceptionBtnClick: () => pageProvider.removeScheduleException(scheduleException.id),
      onSaveExceptionBtnClick:
          (workShift, date, workingTime) =>
              pageProvider.updateScheduleException(scheduleException, workShift, date, workingTime),
    );
  }

  void _showComparisonSelectionDialog(BuildContext context) {
    final pageProvider = context.read<HomePageProvider>();

    final (firstSchedule, secondSchedule) = pageProvider.getSchedulesForComparisonSetting();

    if (firstSchedule == secondSchedule) {
      context.read<SnackBarMessageProvider>().showWarning('Недостаточно графиков для настройки сравнения');
      return;
    }

    var (firstScheduleState, secondScheduleState) = (firstSchedule, secondSchedule);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              final availableSecondSchedules = pageProvider.getAvailableSchedulesForComparison(firstScheduleState);

              if (firstScheduleState.id == secondScheduleState.id) {
                secondScheduleState = availableSecondSchedules.firstOrNull ?? secondScheduleState;
              }

              final areSchedulesDifferent = firstScheduleState.id != secondScheduleState.id;

              void swapSchedules() {
                setState(() {
                  final temp = firstScheduleState;
                  firstScheduleState = secondScheduleState;
                  secondScheduleState = temp;
                });
              }

              return AlertDialog(
                title: const Text('Сопоставление графиков'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Первый график', border: OutlineInputBorder()),
                        value: firstScheduleState.id,
                        items:
                            pageProvider.schedules.map((schedule) {
                              final hasSequences = pageProvider.isScheduleHasSequences(schedule);

                              return DropdownMenuItem<String>(
                                value: schedule.id,
                                child: Row(
                                  children: <Widget>[
                                    Text(schedule.name),
                                    if (!hasSequences)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          '(не настроен)',
                                          style: TextStyle(color: Colors.orange, fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            if (value == null) {
                              firstScheduleState = firstSchedule;
                            } else {
                              final schedule = pageProvider.getScheduleById(value);
                              firstScheduleState = schedule ?? firstSchedule;
                            }
                            final newAvailableSchedules = pageProvider.getAvailableSchedulesForComparison(
                              firstScheduleState,
                            );
                            secondScheduleState = newAvailableSchedules.firstOrNull ?? secondSchedule;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

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

                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Второй график', border: OutlineInputBorder()),
                        value: secondScheduleState.id,
                        items:
                            availableSecondSchedules.map((schedule) {
                              final hasSequences = pageProvider.isScheduleHasSequences(schedule);

                              return DropdownMenuItem<String>(
                                value: schedule.id,
                                child: Row(
                                  children: <Widget>[
                                    Text(schedule.name),
                                    if (!hasSequences)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          '(не настроен)',
                                          style: TextStyle(color: Colors.orange, fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            if (value == null) {
                              secondScheduleState = secondSchedule;
                            } else {
                              final schedule = pageProvider.getScheduleById(value);
                              secondScheduleState = schedule ?? secondSchedule;
                            }
                          });
                        },
                      ),

                      if (availableSecondSchedules.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Нет доступных графиков для сравнения',
                            style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                  TextButton(
                    onPressed:
                        areSchedulesDifferent && availableSecondSchedules.isNotEmpty
                            ? () {
                              if (!pageProvider.isScheduleHasSequences(firstScheduleState) ||
                                  !pageProvider.isScheduleHasSequences(secondScheduleState)) {
                                context.read<SnackBarMessageProvider>().showWarning(
                                  'Один(оба) графика для сопоставления не настроен(-ы)',
                                );
                              }
                              pageProvider.enableComparisonMode(firstScheduleState, secondScheduleState);
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
    final pageProvider = context.read<HomePageProvider>();
    const int countListItemForComparisonMenu = 1;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Выберите график'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: pageProvider.schedules.length + countListItemForComparisonMenu,
                itemBuilder: (context, index) {
                  if (index == pageProvider.schedules.length) {
                    final isComparisonActive = pageProvider.isComparisonMode;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12), bottom: Radius.circular(12)),
                      ),
                      elevation: 1,
                      child: ListTile(
                        title: const Text('Сопоставление графиков'),
                        leading: const Icon(Icons.compare),
                        trailing: isComparisonActive ? const Icon(Icons.check, color: Colors.green) : null,
                        tileColor: isComparisonActive ? Colors.green.withValues(alpha: 0.1) : null,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12), bottom: Radius.circular(12)),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _showComparisonSelectionDialog(context);
                        },
                      ),
                    );
                  }

                  final schedule = pageProvider.schedules[index];
                  final hasSequences = pageProvider.isScheduleHasSequences(schedule);
                  final isActive = !pageProvider.isComparisonMode && pageProvider.isScheduleActive(schedule);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12), bottom: Radius.circular(12)),
                    ),
                    elevation: 1,
                    child: ListTile(
                      title: Text(schedule.name),
                      subtitle:
                          hasSequences
                              ? const Text('Настроен', style: TextStyle(color: Colors.green))
                              : const Text('Не настроен', style: TextStyle(color: Colors.orange)),
                      trailing: isActive ? const Icon(Icons.check, color: Colors.green) : null,
                      tileColor: isActive ? Colors.green.withValues(alpha: 0.1) : null,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12), bottom: Radius.circular(12)),
                      ),
                      onTap: () {
                        if (!hasSequences) {
                          context.read<SnackBarMessageProvider>().showWarning(
                            'Выбрана в качестве активной ненастроенный график',
                          );
                        }
                        pageProvider.onActiveScheduleChange(schedule);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
            actions: <Widget>[TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена'))],
          ),
    );
  }

  Widget _buildMonthSwitcher() {
    return Container(
      color: _primaryLight,
      padding: const EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(icon: const Icon(Icons.chevron_left, color: _textColor), onPressed: _previousMonth),
          Expanded(
            child: GestureDetector(
              onTap: _nowMonth,
              child: Text(
                _getMonthYearText(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textColor, fontSize: 20, fontWeight: FontWeight.normal),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.chevron_right, color: _textColor), onPressed: _nextMonth),
        ],
      ),
    );
  }

  Widget _buildColorLegend(String? activeScheduleId, HomePageProvider pageProvider) {
    if (!pageProvider.showShiftNameLegend() || !pageProvider.hasSchedules() || activeScheduleId == null) {
      return const SizedBox.shrink();
    }

    if (pageProvider.isComparisonMode) {
      return _buildComparisonLegend(pageProvider);
    }

    final List<WorkShiftItemViewModel> shiftsToShow = pageProvider.getUsedShiftsInSchedule(activeScheduleId);

    if (shiftsToShow.isEmpty) {
      return Container();
    }

    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            shiftsToShow.map((shift) {
              return Expanded(child: _buildLegendItem(shift.name, shift.color));
            }).toList(),
      ),
    );
  }

  Widget _buildComparisonLegend(HomePageProvider pageProvider) {
    final firstSchedule = pageProvider.comparedSchedules.first;
    final secondSchedule = pageProvider.comparedSchedules.last;
    final (firstShifts, secondShifts) = pageProvider.getUsedShiftsInComparedSchedules();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    firstSchedule.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                ...firstShifts.map((shift) => Expanded(child: _buildLegendItem(shift.name, shift.color))),
              ],
            ),
          ),
          // Легенда для второго графика
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(4)),
                child: Text(
                  secondSchedule.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              ...secondShifts.map((shift) => Expanded(child: _buildLegendItem(shift.name, shift.color))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Flexible(child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
      ],
    );
  }

  void _calculateCalendarData() {
    _daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    _firstWeekday = DateTime(_currentDate.year, _currentDate.month, 1).weekday;
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
    const List<String> months = <String>[
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];
    return '${months[_currentDate.month - 1]} ${_currentDate.year}';
  }
}
