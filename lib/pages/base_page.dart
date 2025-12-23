import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:releaf/pages/leaderboard_page.dart';
import 'package:releaf/pages/calendar_page.dart';
import 'package:releaf/pages/friends_page.dart';
import 'package:releaf/pages/home_page.dart';
import 'package:releaf/pages/profile_page.dart';
import 'package:releaf/pages/settings_page.dart';
import 'package:releaf/providers/avatar_provider.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> navItems = [
    {
      "icon": Icons.home_outlined,
      "selectedIcon": Icons.home,
      "label": "Home",
      "page": HomePage(),
    },
    {
      "icon": Icons.calendar_month_outlined,
      "selectedIcon": Icons.calendar_month,
      "label": "Calendar",
      "page": CalendarPage(),
    },
    {
      "icon": Icons.leaderboard_outlined,
      "selectedIcon": Icons.leaderboard,
      "label": "Leaderboard",
      "page": LeaderboardPage(),
    },
    {
      "icon": Icons.people_outlined,
      "selectedIcon": Icons.people,
      "label": "Friends",
      "page": FriendsPage(),
    },
    {
      "icon": Icons.settings_outlined,
      "selectedIcon": Icons.settings,
      "label": "Settings",
      "page": SettingsPage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              navItems[_currentIndex]['label'],
              style: context.text.titleSmall,
            ),
            Spacer(),
            GestureDetector(
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfilePage())),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: context.watch<AvatarProvider>().imageProvider,
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: navItems
            .map(
              (item) => Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                child: item['page'] as Widget,
              ),
            )
            .toList(),
      ),
      bottomNavigationBar: NavigationBar(
        // height: 65,
        height: 55,
        destinations: navItems.map((item) {
          return NavigationDestination(
            icon: Icon(item['icon']),
            selectedIcon: Icon(item['selectedIcon']),
            label: '',
            // label: item['label'],
          );
        }).toList(),
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            if (_currentIndex == index) return;
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
