import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sws/providers/settings_provider.dart';
import 'package:sws/pages/settings_schedules_page.dart';
import 'package:sws/pages/settings_shifts_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Флаг: показывать название смены
              SwitchListTile(
                title: const Text('Показывать название смены'),
                value: settings.showShiftName,
                onChanged: (value) {
                  settings.showShiftName = value;
                },
              ),
              const Divider(),

              // Подменю: Настройка графиков
              ListTile(
                title: const Text('Настройка графиков'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsSchedulesPage(),
                    ),
                  );
                },
              ),
              const Divider(),

              // Подменю: Настройка смен
              ListTile(
                title: const Text('Настройка смен'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsShiftsPage(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}