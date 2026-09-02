import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/role_selection_screen.dart';
import '../features/auth/presentation/official_dashboard_placeholder.dart';
import '../features/auth/presentation/inspector_dashboard_placeholder.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String roleSelection = '/role-selection';
  static const String officialDashboard = '/official-dashboard';
  static const String inspectorDashboard = '/inspector-dashboard';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        roleSelection: (context) => const RoleSelectionScreen(),
        officialDashboard: (context) => const OfficialDashboardPlaceholder(),
        inspectorDashboard: (context) => const InspectorDashboardPlaceholder(),
      };
}