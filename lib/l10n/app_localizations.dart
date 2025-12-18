import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'График смен'**
  String get appTitle;

  /// No description provided for @aboutApp.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get aboutApp;

  /// No description provided for @swsApplication.
  ///
  /// In ru, this message translates to:
  /// **'SWS Application'**
  String get swsApplication;

  /// No description provided for @version.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version}'**
  String version(Object version);

  /// No description provided for @scheduleWorkShifts.
  ///
  /// In ru, this message translates to:
  /// **'График рабочих смен'**
  String get scheduleWorkShifts;

  /// No description provided for @copyright.
  ///
  /// In ru, this message translates to:
  /// **'© 2025 Nikita Yarovoi'**
  String get copyright;

  /// No description provided for @add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add;

  /// No description provided for @create.
  ///
  /// In ru, this message translates to:
  /// **'Создать'**
  String get create;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @change.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get change;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @createSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Создать график'**
  String get createSchedule;

  /// No description provided for @selectSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать график'**
  String get selectSchedule;

  /// No description provided for @firstWorkingDay.
  ///
  /// In ru, this message translates to:
  /// **'Первый рабочий день'**
  String get firstWorkingDay;

  /// No description provided for @addShift.
  ///
  /// In ru, this message translates to:
  /// **'Добавить смену'**
  String get addShift;

  /// No description provided for @shift.
  ///
  /// In ru, this message translates to:
  /// **'Смена'**
  String get shift;

  /// No description provided for @schedule.
  ///
  /// In ru, this message translates to:
  /// **'График'**
  String get schedule;

  /// No description provided for @vacation.
  ///
  /// In ru, this message translates to:
  /// **'Отпуск'**
  String get vacation;

  /// No description provided for @sickLeave.
  ///
  /// In ru, this message translates to:
  /// **'Больничный'**
  String get sickLeave;

  /// No description provided for @days.
  ///
  /// In ru, this message translates to:
  /// **'Дни'**
  String get days;

  /// No description provided for @workingTime.
  ///
  /// In ru, this message translates to:
  /// **'Рабочее время'**
  String get workingTime;

  /// No description provided for @fillRequiredFields.
  ///
  /// In ru, this message translates to:
  /// **'Заполните все обязательные* поля'**
  String get fillRequiredFields;

  /// No description provided for @selectShiftInRow.
  ///
  /// In ru, this message translates to:
  /// **'Выберите смену в строке {row}'**
  String selectShiftInRow(Object row);

  /// No description provided for @invalidDaysCountInRow.
  ///
  /// In ru, this message translates to:
  /// **'Некорректное количество дней в строке {row}'**
  String invalidDaysCountInRow(Object row);

  /// No description provided for @scheduleSaved.
  ///
  /// In ru, this message translates to:
  /// **'График сохранён'**
  String get scheduleSaved;

  /// No description provided for @settingsBarTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsBarTitle;

  /// No description provided for @showShiftName.
  ///
  /// In ru, this message translates to:
  /// **'Показывать название смены'**
  String get showShiftName;

  /// No description provided for @showShiftLegend.
  ///
  /// In ru, this message translates to:
  /// **'Показывать легенду календаря'**
  String get showShiftLegend;

  /// No description provided for @settingsSchedulesBarTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройка графиков'**
  String get settingsSchedulesBarTitle;

  /// No description provided for @settingsShiftsBarTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройка смен'**
  String get settingsShiftsBarTitle;

  /// No description provided for @renameSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать график'**
  String get renameSchedule;

  /// No description provided for @editScheduleTitle.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать график'**
  String get editScheduleTitle;

  /// No description provided for @deleteScheduleQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Удалить график?'**
  String get deleteScheduleQuestion;

  /// No description provided for @confirmDeleteSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить \"{name}\"?'**
  String confirmDeleteSchedule(Object name);

  /// No description provided for @createShiftTitle.
  ///
  /// In ru, this message translates to:
  /// **'Создать смены'**
  String get createShiftTitle;

  /// No description provided for @editShiftTitle.
  ///
  /// In ru, this message translates to:
  /// **'Редактирование смены'**
  String get editShiftTitle;

  /// No description provided for @deleteShiftQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Удалить смену?'**
  String get deleteShiftQuestion;

  /// No description provided for @confirmDeleteShift.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить \"{name}\"?'**
  String confirmDeleteShift(Object name);

  /// No description provided for @newScheduleName.
  ///
  /// In ru, this message translates to:
  /// **'График'**
  String get newScheduleName;

  /// No description provided for @shiftName.
  ///
  /// In ru, this message translates to:
  /// **'Название смены'**
  String get shiftName;

  /// No description provided for @shiftCategory.
  ///
  /// In ru, this message translates to:
  /// **'Категория:'**
  String get shiftCategory;

  /// No description provided for @workingDay.
  ///
  /// In ru, this message translates to:
  /// **'Рабочий день'**
  String get workingDay;

  /// No description provided for @dayOff.
  ///
  /// In ru, this message translates to:
  /// **'Выходной'**
  String get dayOff;

  /// No description provided for @colorForShift.
  ///
  /// In ru, this message translates to:
  /// **'Цвет для {name}'**
  String colorForShift(Object name);

  /// No description provided for @newShiftName.
  ///
  /// In ru, this message translates to:
  /// **'Новая смена'**
  String get newShiftName;

  /// No description provided for @addFirstShiftHint.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите + чтобы добавить первую смену'**
  String get addFirstShiftHint;

  /// No description provided for @homePageBarTitle.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get homePageBarTitle;

  /// No description provided for @notEnoughSchedules.
  ///
  /// In ru, this message translates to:
  /// **'Недостаточно графиков для настройки сравнения'**
  String get notEnoughSchedules;

  /// No description provided for @schedulesForComparisonNotConfigured.
  ///
  /// In ru, this message translates to:
  /// **'Один(оба) графика для сопоставления не настроен(-ы)'**
  String get schedulesForComparisonNotConfigured;

  /// No description provided for @scheduleComparisonMode.
  ///
  /// In ru, this message translates to:
  /// **'Режим сравнения'**
  String get scheduleComparisonMode;

  /// No description provided for @scheduleComparison.
  ///
  /// In ru, this message translates to:
  /// **'Сопоставление графиков'**
  String get scheduleComparison;

  /// No description provided for @noSchedulesAvailableForCompare.
  ///
  /// In ru, this message translates to:
  /// **'Нет доступных графиков для сравнения'**
  String get noSchedulesAvailableForCompare;

  /// No description provided for @unconfiguredScheduleSelected.
  ///
  /// In ru, this message translates to:
  /// **'Выбран в качестве активного ненастроенный график'**
  String get unconfiguredScheduleSelected;

  /// No description provided for @january.
  ///
  /// In ru, this message translates to:
  /// **'Январь'**
  String get january;

  /// No description provided for @february.
  ///
  /// In ru, this message translates to:
  /// **'Февраль'**
  String get february;

  /// No description provided for @march.
  ///
  /// In ru, this message translates to:
  /// **'Март'**
  String get march;

  /// No description provided for @april.
  ///
  /// In ru, this message translates to:
  /// **'Апрель'**
  String get april;

  /// No description provided for @may.
  ///
  /// In ru, this message translates to:
  /// **'Май'**
  String get may;

  /// No description provided for @june.
  ///
  /// In ru, this message translates to:
  /// **'Июнь'**
  String get june;

  /// No description provided for @july.
  ///
  /// In ru, this message translates to:
  /// **'Июль'**
  String get july;

  /// No description provided for @august.
  ///
  /// In ru, this message translates to:
  /// **'Август'**
  String get august;

  /// No description provided for @september.
  ///
  /// In ru, this message translates to:
  /// **'Сентябрь'**
  String get september;

  /// No description provided for @october.
  ///
  /// In ru, this message translates to:
  /// **'Октябрь'**
  String get october;

  /// No description provided for @november.
  ///
  /// In ru, this message translates to:
  /// **'Ноябрь'**
  String get november;

  /// No description provided for @december.
  ///
  /// In ru, this message translates to:
  /// **'Декабрь'**
  String get december;

  /// No description provided for @active.
  ///
  /// In ru, this message translates to:
  /// **'Активен'**
  String get active;

  /// No description provided for @firstScheduleTitleName.
  ///
  /// In ru, this message translates to:
  /// **'Первый график'**
  String get firstScheduleTitleName;

  /// No description provided for @secondScheduleTitleName.
  ///
  /// In ru, this message translates to:
  /// **'Второй график'**
  String get secondScheduleTitleName;

  /// No description provided for @swapSchedules.
  ///
  /// In ru, this message translates to:
  /// **'Поменять графики местами'**
  String get swapSchedules;

  /// No description provided for @configured.
  ///
  /// In ru, this message translates to:
  /// **'настроен'**
  String get configured;

  /// No description provided for @notConfigured.
  ///
  /// In ru, this message translates to:
  /// **'не настроен'**
  String get notConfigured;

  /// No description provided for @compare.
  ///
  /// In ru, this message translates to:
  /// **'сопоставить'**
  String get compare;

  /// No description provided for @durationText.
  ///
  /// In ru, this message translates to:
  /// **'{hour}ч {minutes}м'**
  String durationText(Object hour, Object minutes);

  /// No description provided for @selectTime.
  ///
  /// In ru, this message translates to:
  /// **'Выберите время'**
  String get selectTime;

  /// No description provided for @mondayAbr.
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get mondayAbr;

  /// No description provided for @tuesdayAbr.
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get tuesdayAbr;

  /// No description provided for @wednesdayAbr.
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get wednesdayAbr;

  /// No description provided for @thursdayAbr.
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get thursdayAbr;

  /// No description provided for @fridayAbr.
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get fridayAbr;

  /// No description provided for @saturdayAbr.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get saturdayAbr;

  /// No description provided for @sundayAbr.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get sundayAbr;

  /// No description provided for @settingsForDayAdded.
  ///
  /// In ru, this message translates to:
  /// **'Настройки для {day}.{month} добавлены'**
  String settingsForDayAdded(Object day, Object month);

  /// No description provided for @settingsForDayUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Настройки для {day}.{month} обновлены'**
  String settingsForDayUpdated(Object day, Object month);

  /// No description provided for @settingsForDayDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Настройки для {day}.{month} удалены'**
  String settingsForDayDeleted(Object day, Object month);

  /// No description provided for @period.
  ///
  /// In ru, this message translates to:
  /// **'Период'**
  String get period;

  /// No description provided for @workTimeDuration.
  ///
  /// In ru, this message translates to:
  /// **'Общее рабочее время'**
  String get workTimeDuration;

  /// No description provided for @deleted.
  ///
  /// In ru, this message translates to:
  /// **'удален'**
  String get deleted;

  /// No description provided for @addVacation.
  ///
  /// In ru, this message translates to:
  /// **'Добавить отпуск'**
  String get addVacation;

  /// No description provided for @addSickLeave.
  ///
  /// In ru, this message translates to:
  /// **'Добавить больничный'**
  String get addSickLeave;

  /// No description provided for @startDateTitleName.
  ///
  /// In ru, this message translates to:
  /// **'Дата начала'**
  String get startDateTitleName;

  /// No description provided for @endDateTitleName.
  ///
  /// In ru, this message translates to:
  /// **'Дата окончания'**
  String get endDateTitleName;

  /// No description provided for @selectDateHint.
  ///
  /// In ru, this message translates to:
  /// **'Выберите дату'**
  String get selectDateHint;

  /// No description provided for @comparisonModeWarningForVacation.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя добавить отпуск в режиме сравнения графиков. Сначала выберите один график.'**
  String get comparisonModeWarningForVacation;

  /// No description provided for @comparisonModeWarningForSickLeave.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя добавить больничный в режиме сравнения графиков. Сначала выберите один график.'**
  String get comparisonModeWarningForSickLeave;

  /// No description provided for @noActiveSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Сначала выберите активный график'**
  String get noActiveSchedule;

  /// No description provided for @endDateBeforeStartWarning.
  ///
  /// In ru, this message translates to:
  /// **'Дата окончания не может быть раньше даты начала'**
  String get endDateBeforeStartWarning;

  /// No description provided for @objectAdded.
  ///
  /// In ru, this message translates to:
  /// **'{object} - был добавлен'**
  String objectAdded(Object object);

  /// No description provided for @color.
  ///
  /// In ru, this message translates to:
  /// **'Цвет'**
  String get color;

  /// No description provided for @saturation.
  ///
  /// In ru, this message translates to:
  /// **'Насыщенность'**
  String get saturation;

  /// No description provided for @lightness.
  ///
  /// In ru, this message translates to:
  /// **'Яркость'**
  String get lightness;

  /// No description provided for @shiftColor.
  ///
  /// In ru, this message translates to:
  /// **'Цвет смены'**
  String get shiftColor;

  /// No description provided for @calendarDays.
  ///
  /// In ru, this message translates to:
  /// **'Календарные дни'**
  String get calendarDays;

  /// No description provided for @workingDays.
  ///
  /// In ru, this message translates to:
  /// **'Рабочие дни'**
  String get workingDays;

  /// No description provided for @selectShift.
  ///
  /// In ru, this message translates to:
  /// **'Выберите смену'**
  String get selectShift;

  /// No description provided for @numDays.
  ///
  /// In ru, this message translates to:
  /// **'Кол-во дней'**
  String get numDays;

  /// No description provided for @startWork.
  ///
  /// In ru, this message translates to:
  /// **'Начало работы'**
  String get startWork;

  /// No description provided for @endWork.
  ///
  /// In ru, this message translates to:
  /// **'Конец работы'**
  String get endWork;

  /// No description provided for @configure.
  ///
  /// In ru, this message translates to:
  /// **'Настроить'**
  String get configure;

  /// No description provided for @time.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get time;

  /// No description provided for @durationClipped.
  ///
  /// In ru, this message translates to:
  /// **'Длит'**
  String get durationClipped;

  /// No description provided for @workingTimeNotSet.
  ///
  /// In ru, this message translates to:
  /// **'Время не настроено'**
  String get workingTimeNotSet;

  /// No description provided for @workingTimeSetting.
  ///
  /// In ru, this message translates to:
  /// **'Настройка рабочего времени'**
  String get workingTimeSetting;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
