import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/role_selection_screen.dart';
import '../features/dashboard/presentation/official_shell_screen.dart';
import '../features/dashboard/presentation/inspector_shell_screen.dart';
import '../core/widgets/module_placeholder_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String roleSelection = '/role-selection';
  static const String officialDashboard = '/official-dashboard';
  static const String inspectorDashboard = '/inspector-dashboard';

  static const String projectsPlaceholder = '/projects';
  static const String inspectionsPlaceholder = '/inspections';
  static const String cctvPlaceholder = '/cctv';
  static const String analyticsPlaceholder = '/analytics';
  static const String assignmentsPlaceholder = '/assignments';
  static const String inspectionWorkflowPlaceholder = '/inspection-workflow';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        roleSelection: (context) => const RoleSelectionScreen(),
        officialDashboard: (context) => const OfficialShellScreen(),
        inspectorDashboard: (context) => const InspectorShellScreen(),

        projectsPlaceholder: (context) => const ModulePlaceholderScreen(
              title: 'Projects',
              message: 'Projects module will be implemented in a later phase.',
            ),
        inspectionsPlaceholder: (context) => const ModulePlaceholderScreen(
              title: 'Inspections',
              message: 'Inspections module will be implemented in a later phase.',
            ),
        cctvPlaceholder: (context) => const ModulePlaceholderScreen(
              title: 'CCTV',
              message: 'CCTV module will be implemented in a later phase.',
            ),
        analyticsPlaceholder: (context) => const ModulePlaceholderScreen(
              title: 'Analytics',
              message: 'Analytics module will be implemented in a later phase.',
            ),
        assignmentsPlaceholder: (context) => const ModulePlaceholderScreen(
              title: 'Assignments',
              message: 'Assignment list will be implemented in a later phase.',
            ),
        inspectionWorkflowPlaceholder: (context) => const ModulePlaceholderScreen(
              title: 'Inspection Workflow',
              message: 'Inspection Workflow — coming in the next phase.',
            ),
      };
}