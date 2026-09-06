// FILE: lib/features/dashboard/presentation/inspector_shell_screen.dart

import 'package:flutter/material.dart';

import 'assignments_screen.dart';
import 'inspection_history_screen.dart';
import 'inspector_home_screen.dart';
import 'inspector_profile_screen.dart';

class InspectorShellScreen extends StatefulWidget {
  const InspectorShellScreen({super.key});

  @override
  State<InspectorShellScreen> createState() => _InspectorShellScreenState();
}

class _InspectorShellScreenState extends State<InspectorShellScreen> {
  int _index = 0;

  final _screens = const [
    InspectorHomeScreen(),
    AssignmentsScreen(),
    InspectionHistoryScreen(),
    InspectorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() {
            _index = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Inspections',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}