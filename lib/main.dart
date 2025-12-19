import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart' show initializeDateFormatting;
import 'package:provider/provider.dart'
    show ChangeNotifierProvider, MultiProvider;
import 'package:sws/pages/pages.dart' show HomePage;
import 'package:sws/providers/model_providers/model_providers.dart'
    show
        ActiveSchedulesProvider,
        ScheduleExceptionProvider,
        ScheduleProvider,
        ShiftNameLegendSettingProvider,
        ShiftNameSettingProvider,
        ShiftSequenceProvider,
        WorkShiftProvider;
import 'package:sws/providers/providers.dart'
    show
        CalendarWidgetProvider,
        CreateSchedulePageProvider,
        HomePageProvider,
        ScheduleExceptionDialogsProvider,
        SettingsPageProvider,
        SettingsSchedulePageProvider,
        SettingsShiftsPageProvider,
        SnackBarMessageProvider;
import 'package:sws/services/services.dart'
    show S, ScheduleService, StorageService;
import 'package:sws/widgets/widgets.dart' show SnackBarHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.initialize();

  await ActiveSchedulesProvider.initialize();
  await ScheduleExceptionProvider.initialize();
  await ScheduleProvider.initialize();
  await ShiftNameLegendSettingProvider.initialize();
  await ShiftNameSettingProvider.initialize();
  await ShiftSequenceProvider.initialize();
  await WorkShiftProvider.initialize();

  await ScheduleService.initialize(
    activeSchedulesProvider: ActiveSchedulesProvider.instance,
    scheduleExceptionProvider: ScheduleExceptionProvider.instance,
    scheduleProvider: ScheduleProvider.instance,
    shiftSequenceProvider: ShiftSequenceProvider.instance,
    workShiftProvider: WorkShiftProvider.instance,
  );

  await HomePageProvider.initialize(
    activeSchedulesProvider: ActiveSchedulesProvider.instance,
    scheduleExceptionProvider: ScheduleExceptionProvider.instance,
    scheduleProvider: ScheduleProvider.instance,
    scheduleService: ScheduleService.instance,
    shiftNameLegendSettingProvider: ShiftNameLegendSettingProvider.instance,
    shiftNameSettingProvider: ShiftNameSettingProvider.instance,
    shiftSequenceProvider: ShiftSequenceProvider.instance,
    workShiftProvider: WorkShiftProvider.instance,
  );
  await CreateSchedulePageProvider.initialize(
    activeSchedulesProvider: ActiveSchedulesProvider.instance,
    scheduleProvider: ScheduleProvider.instance,
    workShiftProvider: WorkShiftProvider.instance,
    shiftSequenceProvider: ShiftSequenceProvider.instance,
  );
  await SettingsPageProvider.initialize(
    shiftNameLegendSettingProvider: ShiftNameLegendSettingProvider.instance,
    shiftNameSettingProvider: ShiftNameSettingProvider.instance,
  );
  await SettingsSchedulePageProvider.initialize(
    activeSchedulesProvider: ActiveSchedulesProvider.instance,
    scheduleProvider: ScheduleProvider.instance,
    shiftSequenceProvider: ShiftSequenceProvider.instance,
    scheduleExceptionProvider: ScheduleExceptionProvider.instance,
  );
  await SettingsShiftsPageProvider.initialize(
    scheduleExceptionProvider: ScheduleExceptionProvider.instance,
    scheduleService: ScheduleService.instance,
    shiftSequenceProvider: ShiftSequenceProvider.instance,
    workShiftProvider: WorkShiftProvider.instance,
  );
  await CalendarWidgetProvider.initialize(
    activeSchedulesProvider: ActiveSchedulesProvider.instance,
    scheduleExceptionProvider: ScheduleExceptionProvider.instance,
    scheduleProvider: ScheduleProvider.instance,
    scheduleService: ScheduleService.instance,
    shiftNameLegendSettingProvider: ShiftNameLegendSettingProvider.instance,
    shiftNameSettingProvider: ShiftNameSettingProvider.instance,
    shiftSequenceProvider: ShiftSequenceProvider.instance,
    workShiftProvider: WorkShiftProvider.instance,
  );
  await ScheduleExceptionDialogsProvider.initialize(
    activeSchedulesProvider: ActiveSchedulesProvider.instance,
    scheduleExceptionProvider: ScheduleExceptionProvider.instance,
    scheduleProvider: ScheduleProvider.instance,
    scheduleService: ScheduleService.instance,
    workShiftProvider: WorkShiftProvider.instance,
  );

  final locale = PlatformDispatcher.instance.locale;
  await initializeDateFormatting(locale.toString(), null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0E879C);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomePageProvider.instance),
        ChangeNotifierProvider(
          create: (context) => CreateSchedulePageProvider.instance,
        ),
        ChangeNotifierProvider(
          create: (context) => SettingsPageProvider.instance,
        ),
        ChangeNotifierProvider(
          create: (context) => SettingsSchedulePageProvider.instance,
        ),
        ChangeNotifierProvider(
          create: (context) => SettingsShiftsPageProvider.instance,
        ),
        ChangeNotifierProvider(
          create: (context) => CalendarWidgetProvider.instance,
        ),
        ChangeNotifierProvider(
          create: (context) => ScheduleExceptionDialogsProvider.instance,
        ),
        ChangeNotifierProvider(create: (context) => SnackBarMessageProvider()),
      ],
      child: MaterialApp(
        supportedLocales: S.supportedLocales,
        localizationsDelegates: S.localizationDelegates,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            primary: primaryColor,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            titleTextStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: .3,
              fontSize: 18,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          useMaterial3: true,
        ),
        home: SnackBarHandler(child: const HomePage()),
      ),
    );
  }
}
