// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'График смен';

  @override
  String get aboutApp => 'О приложении';

  @override
  String get swsApplication => 'SWS Application';

  @override
  String version(Object version) {
    return 'Версия $version';
  }

  @override
  String get scheduleWorkShifts => 'График рабочих смен';

  @override
  String get copyright => '© 2025 Nikita Yarovoi';

  @override
  String get add => 'Добавить';

  @override
  String get create => 'Создать';

  @override
  String get save => 'Сохранить';

  @override
  String get change => 'Изменить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get createSchedule => 'Создать график';

  @override
  String get selectSchedule => 'Выбрать график';

  @override
  String get firstWorkingDay => 'Первый рабочий день';

  @override
  String get addShift => 'Добавить смену';

  @override
  String get shift => 'Смена';

  @override
  String get schedule => 'График';

  @override
  String get vacation => 'Отпуск';

  @override
  String get sickLeave => 'Больничный';

  @override
  String get days => 'Дни';

  @override
  String get workingTime => 'Рабочее время';

  @override
  String get fillRequiredFields => 'Заполните все обязательные* поля';

  @override
  String selectShiftInRow(Object row) {
    return 'Выберите смену в строке $row';
  }

  @override
  String invalidDaysCountInRow(Object row) {
    return 'Некорректное количество дней в строке $row';
  }

  @override
  String get scheduleSaved => 'График сохранён';

  @override
  String get settingsBarTitle => 'Настройки';

  @override
  String get showShiftName => 'Показывать название смены';

  @override
  String get showShiftLegend => 'Показывать легенду календаря';

  @override
  String get settingsSchedulesBarTitle => 'Настройка графиков';

  @override
  String get settingsShiftsBarTitle => 'Настройка смен';

  @override
  String get renameSchedule => 'Переименовать график';

  @override
  String get editScheduleTitle => 'Редактировать график';

  @override
  String get deleteScheduleQuestion => 'Удалить график?';

  @override
  String confirmDeleteSchedule(Object name) {
    return 'Вы уверены, что хотите удалить \"$name\"?';
  }

  @override
  String get createShiftTitle => 'Создать смены';

  @override
  String get editShiftTitle => 'Редактирование смены';

  @override
  String get deleteShiftQuestion => 'Удалить смену?';

  @override
  String confirmDeleteShift(Object name) {
    return 'Вы уверены, что хотите удалить \"$name\"?';
  }

  @override
  String get newScheduleName => 'График';

  @override
  String get shiftName => 'Название смены';

  @override
  String get shiftCategory => 'Категория:';

  @override
  String get workingDay => 'Рабочий день';

  @override
  String get dayOff => 'Выходной';

  @override
  String colorForShift(Object name) {
    return 'Цвет для $name';
  }

  @override
  String get newShiftName => 'Новая смена';

  @override
  String get addFirstShiftHint => 'Нажмите + чтобы добавить первую смену';

  @override
  String get homePageBarTitle => 'Главная';

  @override
  String get notEnoughSchedules => 'Недостаточно графиков для настройки сравнения';

  @override
  String get schedulesForComparisonNotConfigured => 'Один(оба) графика для сопоставления не настроен(-ы)';

  @override
  String get scheduleComparisonMode => 'Режим сравнения';

  @override
  String get scheduleComparison => 'Сопоставление графиков';

  @override
  String get noSchedulesAvailableForCompare => 'Нет доступных графиков для сравнения';

  @override
  String get unconfiguredScheduleSelected => 'Выбран в качестве активного ненастроенный график';

  @override
  String get january => 'Январь';

  @override
  String get february => 'Февраль';

  @override
  String get march => 'Март';

  @override
  String get april => 'Апрель';

  @override
  String get may => 'Май';

  @override
  String get june => 'Июнь';

  @override
  String get july => 'Июль';

  @override
  String get august => 'Август';

  @override
  String get september => 'Сентябрь';

  @override
  String get october => 'Октябрь';

  @override
  String get november => 'Ноябрь';

  @override
  String get december => 'Декабрь';

  @override
  String get active => 'Активен';

  @override
  String get firstScheduleTitleName => 'Первый график';

  @override
  String get secondScheduleTitleName => 'Второй график';

  @override
  String get swapSchedules => 'Поменять графики местами';

  @override
  String get configured => 'настроен';

  @override
  String get notConfigured => 'не настроен';

  @override
  String get compare => 'сопоставить';

  @override
  String durationText(Object hour, Object minutes) {
    return '$hourч $minutesм';
  }

  @override
  String get selectTime => 'Выберите время';

  @override
  String get mondayAbr => 'Пн';

  @override
  String get tuesdayAbr => 'Вт';

  @override
  String get wednesdayAbr => 'Ср';

  @override
  String get thursdayAbr => 'Чт';

  @override
  String get fridayAbr => 'Пт';

  @override
  String get saturdayAbr => 'Сб';

  @override
  String get sundayAbr => 'Вс';

  @override
  String settingsForDayAdded(Object day, Object month) {
    return 'Настройки для $day.$month добавлены';
  }

  @override
  String settingsForDayUpdated(Object day, Object month) {
    return 'Настройки для $day.$month обновлены';
  }

  @override
  String settingsForDayDeleted(Object day, Object month) {
    return 'Настройки для $day.$month удалены';
  }

  @override
  String get period => 'Период';

  @override
  String get workTimeDuration => 'Общее рабочее время';

  @override
  String get deleted => 'удален';

  @override
  String get addVacation => 'Добавить отпуск';

  @override
  String get addSickLeave => 'Добавить больничный';

  @override
  String get startDateTitleName => 'Дата начала';

  @override
  String get endDateTitleName => 'Дата окончания';

  @override
  String get selectDateHint => 'Выберите дату';

  @override
  String get comparisonModeWarningForVacation => 'Нельзя добавить отпуск в режиме сравнения графиков. Сначала выберите один график.';

  @override
  String get comparisonModeWarningForSickLeave => 'Нельзя добавить больничный в режиме сравнения графиков. Сначала выберите один график.';

  @override
  String get noActiveSchedule => 'Сначала выберите активный график';

  @override
  String get endDateBeforeStartWarning => 'Дата окончания не может быть раньше даты начала';

  @override
  String objectAdded(Object object) {
    return '$object - был добавлен';
  }

  @override
  String get color => 'Цвет';

  @override
  String get saturation => 'Насыщенность';

  @override
  String get lightness => 'Яркость';

  @override
  String get shiftColor => 'Цвет смены';

  @override
  String get calendarDays => 'Календарные дни';

  @override
  String get workingDays => 'Рабочие дни';

  @override
  String get selectShift => 'Выберите смену';

  @override
  String get numDays => 'Кол-во дней';

  @override
  String get startWork => 'Начало работы';

  @override
  String get endWork => 'Конец работы';

  @override
  String get configure => 'Настроить';

  @override
  String get time => 'Время';

  @override
  String get durationClipped => 'Длит';

  @override
  String get workingTimeNotSet => 'Время не настроено';

  @override
  String get workingTimeSetting => 'Настройка рабочего времени';
}
