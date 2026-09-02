import 'package:flutter/material.dart';
import 'official_home_screen.dart';
import '../../../core/widgets/module_placeholder_screen.dart';
import '../../../core/widgets/profile_placeholder_screen.dart';

class OfficialShellScreen extends StatefulWidget {
  const OfficialShellScreen({super.key});

  @override
  State<OfficialShellScreen> createState() => _OfficialShellScreenState();
}

class _OfficialShellScreenState extends State<OfficialShellScreen> {
  int _index = 0;

  final _screens = const [
    OfficialHomeScreen(),
    ModulePlaceholderScreen(
      title: 'Projects',
      message: 'Projects module will be implemented in a later phase.',
    ),
    ModulePlaceholderScreen(
      title: 'Inspections',
      message: 'Inspections module will be implemented in a later phase.',
    ),
    ProfilePlaceholderScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.apartment_outlined), selectedIcon: Icon(Icons.apartment), label: 'Projects'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check), label: 'Inspections'),
          NavigationDestination(icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}