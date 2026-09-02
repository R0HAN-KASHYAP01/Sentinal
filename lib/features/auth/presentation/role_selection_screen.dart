import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../services/session_service.dart';
import '../../../app/routes.dart';
import '../../../core/widgets/app_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _selectRole(BuildContext context, UserRole role) {
    SessionService.instance.updateRole(role);

    Navigator.of(context).pushNamedAndRemoveUntil(
      role == UserRole.official
          ? AppRoutes.officialDashboard
          : AppRoutes.inspectorDashboard,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Choose how you want to continue',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            _RoleCard(
              icon: Icons.admin_panel_settings,
              title: 'DoSJE Official',
              points: const [
                'Monitor projects',
                'Review inspections',
                'View alerts',
                'View analytics',
              ],
              onTap: () => _selectRole(context, UserRole.official),
            ),
            const SizedBox(height: 16),
            _RoleCard(
              icon: Icons.fact_check,
              title: 'PMU / Inspector',
              points: const [
                'View assignments',
                'Perform inspections',
                'Capture evidence',
                'Submit reports',
              ],
              onTap: () => _selectRole(context, UserRole.inspector),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> points;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.points,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...points.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: Colors.black45),
                    const SizedBox(width: 8),
                    Text(p, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}