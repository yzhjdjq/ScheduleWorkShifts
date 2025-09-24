import 'package:flutter/material.dart';

import 'package:sws/pages/aboutPage.dart';
import 'package:sws/pages/homePage.dart';
import 'package:sws/pages/profilePage.dart';
import 'package:sws/pages/settingsPage.dart';

class MainNavigatorPage extends StatefulWidget {
  const MainNavigatorPage({super.key});

  @override
  State<MainNavigatorPage> createState() => _MainNavigatorPageState();
}

class _MainNavigatorPageState extends State<MainNavigatorPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // Список страниц для отображения
  final List<Widget> _pages = [
    const HomePage(),
    const ProfilePage(),
    const SettingsPage(),
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: _buildDrawer(context),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _currentIndex,
      //   onTap: (index) {
      //     setState(() {
      //       _currentIndex = index;
      //       _pageController.jumpToPage(index);
      //     });
      //   },
      //   type: BottomNavigationBarType.fixed,
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Главная',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Профиль',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.settings),
      //       label: 'Настройки',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.info),
      //       label: 'О приложении',
      //     ),
      //   ],
      // ),
    );
  }

  // Построение бокового меню
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildDrawerItem(
            icon: Icons.home,
            title: 'Главная',
            index: 0,
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Профиль',
            index: 1,
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Настройки',
            index: 2,
          ),
          _buildDrawerItem(
            icon: Icons.info,
            title: 'О приложении',
            index: 3,
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.exit_to_app,
            title: 'Выйти',
            onTap: () {
              // Действие при выходе
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // Шапка Drawer
  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 30,
            child: Text(
              'SWS',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'График смен',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Версия 0.1.0',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Элемент меню
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    int? index,
    VoidCallback? onTap,
  }) {
    final isSelected = index == _currentIndex;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      onTap: onTap ?? () {
        if (index != null) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        }
        Navigator.pop(context); // Закрыть Drawer
      },
    );
  }

  // Заголовок AppBar в зависимости от страницы
  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0: return 'Главная';
      case 1: return 'Профиль';
      case 2: return 'Настройки';
      case 3: return 'О приложении';
      default: return 'SWS App';
    }
  }

  // Диалог выхода
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выход'),
          content: const Text('Вы уверены, что хотите выйти?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Здесь логика выхода
              },
              child: const Text('Выйти'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}