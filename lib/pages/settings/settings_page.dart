import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Consumer;
import 'package:sws/providers/providers.dart' show SettingsPageProvider;
import 'package:sws/pages/settings/settings.dart' show SettingsSchedulesPage, SettingsShiftsPage;
import 'package:sws/services/services.dart' show S;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).settingsBarTitle)),
      body: Consumer<SettingsPageProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              SwitchListTile(
                title: Text(S.of(context).showShiftName),
                value: settings.showShiftName,
                onChanged: (value) {
                  settings.showShiftName = value;
                },
              ),
              const Divider(),

              SwitchListTile(
                title: Text(S.of(context).showShiftLegend),
                value: settings.showShiftNameLegend,
                onChanged: (value) {
                  settings.showShiftNameLegend = value;
                },
              ),
              const Divider(),

              ListTile(
                title: Text(S.of(context).settingsSchedulesBarTitle),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsSchedulesPage()));
                },
              ),
              const Divider(),

              ListTile(
                title: Text(S.of(context).settingsShiftsBarTitle),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsShiftsPage()));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
