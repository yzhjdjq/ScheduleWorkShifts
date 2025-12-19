import 'package:flutter/material.dart';
import 'package:sws/pages/pages.dart'
    show AboutPage, CreateSchedulePage, SettingsPage;
import 'package:sws/services/services.dart' show S;
import 'package:sws/sws_metadata.dart' show SwsMetadata;
import 'package:sws/widgets/widgets.dart'
    show sickLeaveDialogWidget, vacationDialogWidget;

class MainDrawer extends StatelessWidget {
  final Color _primaryColor;

  const MainDrawer({super.key, required Color color}) : _primaryColor = color;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _MainDrawerHeader(primaryColor: _primaryColor),
          _buildDrawerItem(
            icon: Icons.schedule,
            title: S.of(context).createSchedule,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateSchedulePage(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.beach_access,
            title: S.of(context).vacation,
            onTap: () {
              Navigator.pop(context);
              vacationDialogWidget(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.medical_services,
            title: S.of(context).sickLeave,
            onTap: () {
              Navigator.pop(context);
              sickLeaveDialogWidget(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            title: S.of(context).settingsBarTitle,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.info,
            title: S.of(context).aboutApp,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}

class _MainDrawerHeader extends StatelessWidget {
  final Color _primaryColor;

  const _MainDrawerHeader({required Color primaryColor})
    : _primaryColor = primaryColor;

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(color: _primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 30,
            child: Text(
              'SWS',
              style: TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            S.of(context).appTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            S.of(context).version(SwsMetadata.appVersion),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
