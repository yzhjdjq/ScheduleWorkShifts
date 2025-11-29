import 'package:flutter/material.dart';

import 'package:sws/pages/about_page.dart' show AboutPage;
import 'package:sws/pages/create_schedule_page.dart' show CreateSchedulePage;
import 'package:sws/pages/settings_page.dart' show SettingsPage;
import 'package:sws/sws_metadata.dart' show SwsMetadata;
import 'package:sws/widgets/schedule_exception_dialogs_widgets.dart' show sickLeaveDialogWidget, vacationDialogWidget;

class MainDrawer extends StatelessWidget {
  final Color _primaryColor;

  const MainDrawer({super.key, required Color color}) : _primaryColor = color;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildDrawerItem(
            icon: Icons.schedule,
            title: 'Создать график',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateSchedulePage()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.beach_access,
            title: 'Отпуск',
            onTap: () {
              Navigator.pop(context);
              vacationDialogWidget(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.medical_services,
            title: 'Больничный',
            onTap: () {
              Navigator.pop(context);
              sickLeaveDialogWidget(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Настройки',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
            },
          ),
          _buildDrawerItem(
            icon: Icons.info,
            title: 'О приложении',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(color: _primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 30,
            child: Text('SWS', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          const Text('График смен', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text('Версия ${SwsMetadata.appVersion}', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, VoidCallback? onTap}) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}
