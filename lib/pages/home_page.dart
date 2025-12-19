import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext, WatchContext;
import 'package:sws/services/services.dart' show S;
import 'package:sws/widgets/month_switcher_widget.dart';
import 'package:sws/widgets/widgets.dart'
    show
        CalendarWidget,
        MainDrawer,
        ScheduleShiftsStatisticsWidget,
        showDaySettingsDialog,
        showExceptionDetailsDialog,
        showScheduleSelectionDialog;
import 'package:sws/providers/providers.dart'
    show
        CalendarWidgetProvider,
        HomePageProvider,
        ScheduleExceptionItemViewModel,
        ScheduleItemViewModel,
        WorkShiftItemViewModel,
        WorkingTimeViewModel;
import 'package:sws/widgets/work_shift_color_legend_widget.dart';

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
    const int minimumNumberSchedulesForSelectActive = 2;

    final ScheduleItemViewModel? activeSchedule = pageProvider.activeSchedule;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageProvider.getAppBarTitleText(
            defaultValue: S.of(context).homePageBarTitle,
          ),
        ),
        actions: <Widget>[
          if (pageProvider.hasSchedules() &&
              pageProvider.schedules.length >=
                  minimumNumberSchedulesForSelectActive)
            IconButton(
              icon: Icon(
                pageProvider.isComparisonMode
                    ? Icons.compare
                    : Icons.calendar_today,
              ),
              onPressed: () => showScheduleSelectionDialog(context),
              tooltip:
                  pageProvider.isComparisonMode
                      ? S.of(context).scheduleComparisonMode
                      : S.of(context).selectSchedule,
            ),
        ],
      ),
      drawer: const MainDrawer(color: _primaryColor),
      body: Column(
        children: <Widget>[
          MonthSwitcherWidget(
            colorWidget: _primaryLight,
            colorText: _textColor,
            currentDate: _currentDate,
            onNextMonthBtnClicked: _onNextMonthBtnClicked,
            onNowMonthBtnClicked: _onNowMonthBtnClicked,
            onPreviousMonthBtnClicked: _onPreviousMonthBtnClicked,
          ),

          WorkShiftColorLegendWidget(
            activeScheduleId: activeSchedule?.id,
            primaryLight: _primaryLight,
          ),

          Expanded(
            flex: 3,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  _onPreviousMonthBtnClicked();
                } else if (details.primaryVelocity! < 0) {
                  _onNextMonthBtnClicked();
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

          Expanded(
            flex: 1,
            child: ScheduleShiftsStatisticsWidget(currentDate: _currentDate),
          ),
        ],
      ),
    );
  }

  void _onDayCellTap(DateTime date, WorkShiftItemViewModel workShift) {
    final pageProvider = context.read<HomePageProvider>();
    if (pageProvider.hasExceptionForDateByActiveSchedule(date)) {
      final ScheduleExceptionItemViewModel scheduleException =
          pageProvider.getExceptionForDateByActiveSchedule(date)!;
      showExceptionDetailsDialog(
        context: context,
        day: date,
        scheduleException: scheduleException,
        workShift: workShift,
        isNotStaticShiftScheduleException: pageProvider
            .isNotStaticShiftScheduleException(scheduleException),
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
        workingTime: pageProvider.getWorkingTimeForWorkShiftInActiveSchedule(
          workShift,
        ),
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
      onDeleteExceptionBtnClick:
          () => pageProvider.removeScheduleException(scheduleException.id),
      onSaveExceptionBtnClick:
          (workShift, date, workingTime) =>
              pageProvider.updateScheduleException(
                scheduleException,
                workShift,
                date,
                workingTime,
              ),
    );
  }

  void _calculateCalendarData() {
    _daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    _firstWeekday = DateTime(_currentDate.year, _currentDate.month, 1).weekday;
  }

  void _onPreviousMonthBtnClicked() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      _calculateCalendarData();
    });
  }

  void _onNowMonthBtnClicked() {
    setState(() {
      _currentDate = DateTime.now();
      _calculateCalendarData();
    });
  }

  void _onNextMonthBtnClicked() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      _calculateCalendarData();
    });
  }
}
