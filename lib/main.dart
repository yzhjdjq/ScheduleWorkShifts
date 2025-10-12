import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sws/pages/main_navigator_page.dart';
import 'package:sws/providers/settings_provider.dart';
import 'package:sws/services/storage_service.dart';

void main() async{
  await StorageService.initialize();
  await SettingsProvider.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsProvider.instance,
      child: MaterialApp(
        title: 'График смен',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: .3,
              fontSize: 18,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        home: const MainNavigatorPage(),
      ),
    );
  }
}
