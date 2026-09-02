import 'package:flutter/material.dart';
import 'inspector_home_screen.dart';
import '../../../core/widgets/module_placeholder_screen.dart';
import '../../../core/widgets/profile_placeholder_screen.dart';

class InspectorShellScreen extends StatefulWidget {
  const InspectorShellScreen({super.key});

  @override
  State<InspectorShellScreen> createState() => _InspectorShellScreenState();
}

class _InspectorShellScreenState extends State<InspectorShellScreen> {
  int _index = 0;

  final _screens = const [
    InspectorHomeScreen(),
    ModulePlaceholderScreen(
      title: 'Assignments',
      message: 'Assignment list will be implemented in a later phase.',
    ),
    ModulePlaceholderScreen(
      title: 'Inspection Workflow',
      message: 'Inspection Workflow — coming in the next phase.',
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
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Assignments'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check), label: 'Inspections'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}