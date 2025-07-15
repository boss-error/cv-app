import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';
import 'template_selection_screen.dart';
import 'ios_settings_screen.dart';
import 'personal_info_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PersonalInfoScreen(),
    const TemplateSelectionScreen(),
    const IOSSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.themeMode == ThemeMode.dark;
        
        return CupertinoTabScaffold(
          backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
          tabBar: CupertinoTabBar(
            backgroundColor: isDark 
                ? const Color(0xFF1C1C1E).withOpacity(0.8)
                : const Color(0xFFF2F2F7).withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: isDark 
                    ? const Color(0xFF38383A)
                    : const Color(0xFFD1D1D6),
                width: 0.5,
              ),
            ),
            activeColor: const Color(0xFF007AFF),
            inactiveColor: isDark 
                ? const Color(0xFF8E8E93)
                : const Color(0xFF8E8E93),
            iconSize: 24,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                activeIcon: Icon(CupertinoIcons.home_fill),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person),
                activeIcon: Icon(CupertinoIcons.person_fill),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.doc_text),
                activeIcon: Icon(CupertinoIcons.doc_text_fill),
                label: 'Templates',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                activeIcon: Icon(CupertinoIcons.settings_solid),
                label: 'Settings',
              ),
            ],
          ),
          tabBuilder: (context, index) {
            return CupertinoTabView(
              builder: (context) => _screens[index],
            );
          },
        );
      },
    );
  }
}
