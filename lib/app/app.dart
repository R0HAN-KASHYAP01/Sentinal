import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';

class SmartMonitoringApp extends StatelessWidget {
  const SmartMonitoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Monitoring',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}