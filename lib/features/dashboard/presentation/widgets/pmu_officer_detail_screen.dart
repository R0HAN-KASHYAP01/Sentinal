import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../models/assignment.dart';
import '../../../../models/pmu_officer_summary.dart';
import 'assignment_card.dart';
import 'recent_inspection_card.dart';

class PmuOfficerDetailScreen extends StatelessWidget {
  final PmuOfficerSummary officer;

  const PmuOfficerDetailScreen({super.key, required this.officer});

  Color _availabilityColor(OfficerAvailability a) {
    switch (a) {
      case OfficerAvailability.available:
        return const Color(0xFF1E7A46);
      case OfficerAvailability.assigned:
        return const Color(0xFF2A5C8A);
      case OfficerAvailability.inInspection:
        return const Color(0xFFB56B00);
      case OfficerAvailability.offline:
        return const Color(0xFF5B6472);
    }
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return 'No recent activity';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final currentAssignment = officer.currentAssignment;

    return Scaffold(
      appBar: AppBar(title: Text(officer.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (officer.designation != null)
                      Text(officer.designation!, style: Theme.of(context).textTheme.titleMedium),
                    if (officer.department != null)
                      Text(officer.department!, style: Theme.of(context).textTheme.bodyMedium),
                    if (officer.region != null)
                      Text(officer.region!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              StatusBadge(
                label: officer.availability.label,
                color: _availabilityColor(officer.availability),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Last activity: ${_timeAgo(officer.lastActivity)}',
              style: Theme.of(context).textTheme.bodySmall),

          // Current assignment — links into the existing assignments route,
          // the only assignment-detail entry point the app currently has.
          if (currentAssignment != null) ...[
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pushNamed(context, AppRoutes.assignmentsPlaceholder),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Assignment', style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(currentAssignment.projectName, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(currentAssignment.status.label, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _StatTile(label: 'Assignments', value: '${officer.assignmentsCount}'),
              _StatTile(label: 'Completed Inspections', value: '${officer.completedInspectionsCount}'),
              _StatTile(label: 'Pending Inspections', value: '${officer.pendingInspectionsCount}'),
              _StatTile(
                label: 'Overdue Inspections',
                value: '${officer.overdueInspectionsCount}',
                valueColor: officer.overdueInspectionsCount > 0 ? Colors.redAccent : null,
              ),
            ],
          ),

          // Assignments — reuses the existing AssignmentCard used on the
          // PMU officer's own dashboard, so status/priority colors match.
          if (officer.assignments.isNotEmpty) ...[
            const SizedBox(height: 24),
            const SectionHeader(title: 'Assignments'),
            const SizedBox(height: 10),
            ...officer.assignments.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AssignmentCard(assignment: a),
              ),
            ),
          ],

          // Inspections — reuses the existing RecentInspectionCard.
          if (officer.inspections.isNotEmpty) ...[
            const SizedBox(height: 24),
            const SectionHeader(title: 'Inspections'),
            const SizedBox(height: 10),
            ...officer.inspections.map(
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RecentInspectionCard(inspection: i),
              ),
            ),
          ],

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: officer.rvcAvailable
                ? () => Navigator.pushNamed(context, AppRoutes.rvcPlaceholder)
                : null,
            icon: const Icon(Icons.video_call_outlined),
            label: const Text('Start RVC'),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatTile({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0D5DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: valueColor)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}