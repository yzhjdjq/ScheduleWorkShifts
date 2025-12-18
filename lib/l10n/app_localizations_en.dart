// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Shift Schedule';

  @override
  String get aboutApp => 'About App';

  @override
  String get swsApplication => 'SWS Application';

  @override
  String version(Object version) {
    return 'Version $version';
  }

  @override
  String get scheduleWorkShifts => 'Work Shift Schedule';

  @override
  String get copyright => '© 2025 Nikita Yarovoi';

  @override
  String get add => 'Add';

  @override
  String get create => 'Create';

  @override
  String get save => 'Save';

  @override
  String get change => 'Change';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get createSchedule => 'Create Schedule';

  @override
  String get selectSchedule => 'Select Schedule';

  @override
  String get firstWorkingDay => 'First Working Day';

  @override
  String get addShift => 'Add Shift';

  @override
  String get shift => 'Shift';

  @override
  String get schedule => 'Schedule';

  @override
  String get vacation => 'Vacation';

  @override
  String get sickLeave => 'Sick Leave';

  @override
  String get days => 'Days';

  @override
  String get workingTime => 'Working Time';

  @override
  String get fillRequiredFields => 'Fill in all required* fields';

  @override
  String selectShiftInRow(Object row) {
    return 'Select shift in row $row';
  }

  @override
  String invalidDaysCountInRow(Object row) {
    return 'Invalid number of days in row $row';
  }

  @override
  String get scheduleSaved => 'Schedule saved';

  @override
  String get settingsBarTitle => 'Settings';

  @override
  String get showShiftName => 'Show shift name';

  @override
  String get showShiftLegend => 'Show calendar legend';

  @override
  String get settingsSchedulesBarTitle => 'Schedule Settings';

  @override
  String get settingsShiftsBarTitle => 'Shift Settings';

  @override
  String get renameSchedule => 'Rename Schedule';

  @override
  String get editScheduleTitle => 'Edit Schedule';

  @override
  String get deleteScheduleQuestion => 'Delete schedule?';

  @override
  String confirmDeleteSchedule(Object name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get createShiftTitle => 'Create Shifts';

  @override
  String get editShiftTitle => 'Edit Shift';

  @override
  String get deleteShiftQuestion => 'Delete shift?';

  @override
  String confirmDeleteShift(Object name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get newScheduleName => 'Schedule';

  @override
  String get shiftName => 'Shift Name';

  @override
  String get shiftCategory => 'Category:';

  @override
  String get workingDay => 'Working Day';

  @override
  String get dayOff => 'Day Off';

  @override
  String colorForShift(Object name) {
    return 'Color for $name';
  }

  @override
  String get newShiftName => 'New Shift';

  @override
  String get addFirstShiftHint => 'Tap + to add the first shift';

  @override
  String get homePageBarTitle => 'Home';

  @override
  String get notEnoughSchedules => 'Not enough schedules to set up comparison';

  @override
  String get schedulesForComparisonNotConfigured => 'One or both comparison schedules are not configured';

  @override
  String get scheduleComparisonMode => 'Comparison Mode';

  @override
  String get scheduleComparison => 'Schedule Comparison';

  @override
  String get noSchedulesAvailableForCompare => 'No schedules available for comparison';

  @override
  String get unconfiguredScheduleSelected => 'An unconfigured schedule is selected as active';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get active => 'Active';

  @override
  String get firstScheduleTitleName => 'First Schedule';

  @override
  String get secondScheduleTitleName => 'Second Schedule';

  @override
  String get swapSchedules => 'Swap Schedules';

  @override
  String get configured => 'configured';

  @override
  String get notConfigured => 'not configured';

  @override
  String get compare => 'compare';

  @override
  String durationText(Object hour, Object minutes) {
    return '${hour}h ${minutes}m';
  }

  @override
  String get selectTime => 'Select time';

  @override
  String get mondayAbr => 'Mon';

  @override
  String get tuesdayAbr => 'Tue';

  @override
  String get wednesdayAbr => 'Wed';

  @override
  String get thursdayAbr => 'Thu';

  @override
  String get fridayAbr => 'Fri';

  @override
  String get saturdayAbr => 'Sat';

  @override
  String get sundayAbr => 'Sun';

  @override
  String settingsForDayAdded(Object day, Object month) {
    return 'Settings for $day.$month added';
  }

  @override
  String settingsForDayUpdated(Object day, Object month) {
    return 'Settings for $day.$month updated';
  }

  @override
  String settingsForDayDeleted(Object day, Object month) {
    return 'Settings for $day.$month deleted';
  }

  @override
  String get period => 'Period';

  @override
  String get workTimeDuration => 'Total Working Time';

  @override
  String get deleted => 'deleted';

  @override
  String get addVacation => 'Add Vacation';

  @override
  String get addSickLeave => 'Add Sick Leave';

  @override
  String get startDateTitleName => 'Start Date';

  @override
  String get endDateTitleName => 'End Date';

  @override
  String get selectDateHint => 'Select date';

  @override
  String get comparisonModeWarningForVacation => 'Cannot add vacation in schedule comparison mode. Please select a single schedule first.';

  @override
  String get comparisonModeWarningForSickLeave => 'Cannot add sick leave in schedule comparison mode. Please select a single schedule first.';

  @override
  String get noActiveSchedule => 'Please select an active schedule first';

  @override
  String get endDateBeforeStartWarning => 'End date cannot be earlier than start date';

  @override
  String objectAdded(Object object) {
    return '$object has been added';
  }

  @override
  String get color => 'Color';

  @override
  String get saturation => 'Saturation';

  @override
  String get lightness => 'Lightness';

  @override
  String get shiftColor => 'Shift Color';

  @override
  String get calendarDays => 'Calendar Days';

  @override
  String get workingDays => 'Working Days';

  @override
  String get selectShift => 'Select shift';

  @override
  String get numDays => 'Number of days';

  @override
  String get startWork => 'Start Work';

  @override
  String get endWork => 'End Work';

  @override
  String get configure => 'Configure';

  @override
  String get time => 'Time';

  @override
  String get durationClipped => 'Dur';

  @override
  String get workingTimeNotSet => 'Time not set';

  @override
  String get workingTimeSetting => 'Working Time Setup';
}
