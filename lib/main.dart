import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:sws/pages/home_page.dart';
import 'package:sws/providers/schedule_exception_store.dart';
import 'package:sws/providers/schedule_provider.dart';
import 'package:sws/providers/schedule_store.dart' show ScheduleStore;
import 'package:sws/providers/settings_provider.dart';
import 'package:sws/providers/shift_sequence_store.dart';
import 'package:sws/providers/work_shift_store.dart' show WorkShiftStore;
import 'package:sws/services/storage_service.dart';

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
