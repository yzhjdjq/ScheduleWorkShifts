import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart' show initializeDateFormatting;
import 'package:provider/provider.dart' show ChangeNotifierProvider, MultiProvider;

import 'package:sws/pages/pages.dart' show HomePage;
import 'package:sws/providers/stores/stores.dart'
    show ScheduleStore, WorkShiftStore, ShiftSequenceStore, ScheduleExceptionStore;
import 'package:sws/providers/providers.dart' show SettingsProvider, ScheduleProvider;
import 'package:sws/services/services.dart' show StorageService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.initialize();
  await ScheduleStore.initialize();
  await WorkShiftStore.initialize();
  await ShiftSequenceStore.initialize(scheduleStore: ScheduleStore.instance);
  await ScheduleExceptionStore.initialize();
  await SettingsProvider.initialize(
    scheduleStore: ScheduleStore.instance,
    workShiftStore: WorkShiftStore.instance,
    shiftSequenceStore: ShiftSequenceStore.instance,
    scheduleExceptionStore: ScheduleExceptionStore.instance,
  );
  await ScheduleProvider.initialize(
    scheduleStore: ScheduleStore.instance,
    workShiftStore: WorkShiftStore.instance,
    shiftSequenceStore: ShiftSequenceStore.instance,
    scheduleExceptionStore: ScheduleExceptionStore.instance,
  );
  await initializeDateFormatting('ru', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0E879C);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider.instance),
        ChangeNotifierProvider(create: (context) => ScheduleProvider.instance),
      ],
      child: MaterialApp(
        title: 'График смен',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, primary: primaryColor),
          appBarTheme: AppBarTheme(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            titleTextStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: .3, fontSize: 18),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
