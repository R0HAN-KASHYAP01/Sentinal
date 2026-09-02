import 'package:flutter/material.dart';

/// A simple top page header used on non-dashboard screens
/// (kept separate from DashboardHeader, which is avatar/greeting based).
class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AppHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}