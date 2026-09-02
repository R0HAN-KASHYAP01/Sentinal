import 'package:flutter/material.dart';
import '../../../services/session_service.dart';
import '../../../app/routes.dart';
import '../../../core/widgets/dashboard_header.dart';
import '../../../core/widgets/summary_stat_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/mock_dashboard_data.dart';
import 'widgets/assignment_card.dart';

class InspectorDashboardScreen extends StatelessWidget {
  const InspectorDashboardScreen({super.key});

  void _logout(BuildContext context) {
    SessionService.instance.clear();
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionService.instance.currentUser;
    final assignments = MockDashboardData.todaysAssignments;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DashboardHeader(
              greeting: 'Welcome back,',
              userName: user?.name ?? 'PMU Inspector',
              onNotificationTap: () {},
              onLogoutTap: () => _logout(context),
            ),
            const SizedBox(height: 24),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                SummaryStatCard(
                  icon: Icons.today,
                  label: "Today's Assignments",
                  count: '3',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.assignmentsPlaceholder),
                ),
                SummaryStatCard(
                  icon: Icons.error_outline,
                  label: 'Overdue',
                  count: '1',
                  accentColor: Colors.red,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.assignmentsPlaceholder),
                ),
                SummaryStatCard(
                  icon: Icons.upcoming_outlined,
                  label: 'Upcoming',
                  count: '5',
                  accentColor: Colors.orange,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.assignmentsPlaceholder),
                ),
                SummaryStatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Completed',
                  count: '18',
                  accentColor: Colors.green,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.assignmentsPlaceholder),
                ),
              ],
            ),

            const SizedBox(height: 28),
            SectionHeader(
              title: "Today's Assignments",
              actionLabel: 'View Assignments',
              onActionTap: () => Navigator.of(context).pushNamed(AppRoutes.assignmentsPlaceholder),
            ),
            const SizedBox(height: 12),

            if (assignments.isEmpty)
              const _EmptyState(message: 'No assignments scheduled for today.')
            else
              ...assignments.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AssignmentCard(assignment: a),
                ),
              ),

            const SizedBox(height: 20),

            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.map_outlined, size: 26, color: Colors.black54),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Nearby assignments on map',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.assignmentsPlaceholder),
                    child: const Text('View'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              label: 'Start Assigned Inspection',
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.inspectionWorkflowPlaceholder),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 13, color: Colors.black45),
        ),
      ),
    );
  }
}