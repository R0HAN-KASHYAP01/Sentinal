import '../../../models/assignment.dart';
import '../../../models/inspection.dart';
import '../../../models/pmu_officer_summary.dart';

class MockPmuMonitoringData {
  MockPmuMonitoringData._();

  static final List<PmuOfficerSummary> officers = [
    PmuOfficerSummary(
      id: 'pmu-001',
      name: 'R. Sharma',
      department: 'Social Empowerment',
      designation: 'Inspection Officer',
      region: 'Sector 12, Dwarka',
      availability: OfficerAvailability.assigned,
      lastActivity: DateTime.now().subtract(const Duration(hours: 3)),
      assignments: [
        AssignmentSummary(
          projectName: 'Sunrise Child Care Centre',
          location: 'Sector 12, Dwarka',
          scheduledDateTime: DateTime.now().add(const Duration(hours: 2)),
          priority: Priority.high,
          status: AssignmentStatus.inProgress,
        ),
      ],
      inspections: [
        InspectionSummary(
          projectName: 'Sunrise Child Care Centre',
          inspectorName: 'R. Sharma',
          dateTime: DateTime.now().subtract(const Duration(hours: 3)),
          status: InspectionStatus.underReview,
          risk: RiskLevel.medium,
        ),
        InspectionSummary(
          projectName: 'Community Hall Trust',
          inspectorName: 'R. Sharma',
          dateTime: DateTime.now().subtract(const Duration(days: 1)),
          status: InspectionStatus.overdue,
          risk: RiskLevel.high,
        ),
      ],
    ),
    PmuOfficerSummary(
      id: 'pmu-002',
      name: 'A. Mehta',
      department: 'Educational',
      designation: 'Senior Inspection Officer',
      region: 'Karol Bagh',
      availability: OfficerAvailability.available,
      lastActivity: DateTime.now().subtract(const Duration(hours: 6)),
      assignments: const [],
      inspections: [
        InspectionSummary(
          projectName: 'Government Skill Development Institute',
          inspectorName: 'A. Mehta',
          dateTime: DateTime.now().subtract(const Duration(hours: 6)),
          status: InspectionStatus.approved,
          risk: RiskLevel.low,
        ),
      ],
    ),
    PmuOfficerSummary(
      id: 'pmu-003',
      name: 'K. Nair',
      department: 'Economical Development',
      designation: 'Inspection Officer',
      region: 'Rohini, Phase 3',
      availability: OfficerAvailability.offline,
      lastActivity: DateTime.now().subtract(const Duration(days: 1)),
      assignments: [
        AssignmentSummary(
          projectName: 'Community Rehabilitation Centre',
          location: 'Rohini, Phase 3',
          scheduledDateTime: DateTime.now().subtract(const Duration(hours: 1)),
          priority: Priority.medium,
          status: AssignmentStatus.overdue,
        ),
      ],
      inspections: [
        InspectionSummary(
          projectName: 'Community Rehabilitation Centre',
          inspectorName: 'K. Nair',
          dateTime: DateTime.now().subtract(const Duration(days: 1)),
          status: InspectionStatus.overdue,
          risk: RiskLevel.high,
        ),
        InspectionSummary(
          projectName: 'District Skill Centre',
          inspectorName: 'K. Nair',
          dateTime: DateTime.now().subtract(const Duration(days: 2)),
          status: InspectionStatus.submitted,
          risk: RiskLevel.medium,
        ),
      ],
    ),
    PmuOfficerSummary(
      id: 'pmu-004',
      name: 'S. Verma',
      department: 'Social Empowerment',
      designation: 'Inspection Officer',
      region: 'District Old Age Home',
      availability: OfficerAvailability.inInspection,
      lastActivity: DateTime.now().subtract(const Duration(minutes: 40)),
      assignments: [
        AssignmentSummary(
          projectName: 'District Old Age Home',
          location: 'Civil Lines',
          scheduledDateTime: DateTime.now().add(const Duration(hours: 1)),
          priority: Priority.low,
          status: AssignmentStatus.assigned,
        ),
      ],
      inspections: [
        InspectionSummary(
          projectName: 'District Old Age Home',
          inspectorName: 'S. Verma',
          dateTime: DateTime.now().subtract(const Duration(days: 2)),
          status: InspectionStatus.approved,
          risk: RiskLevel.low,
        ),
      ],
    ),
  ];
}