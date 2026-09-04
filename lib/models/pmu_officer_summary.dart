import 'assignment.dart';
import 'inspection.dart';

enum OfficerAvailability { available, assigned, inInspection, offline }

extension OfficerAvailabilityLabel on OfficerAvailability {
  String get label {
    switch (this) {
      case OfficerAvailability.available:
        return 'Available';
      case OfficerAvailability.assigned:
        return 'Assigned';
      case OfficerAvailability.inInspection:
        return 'In Inspection';
      case OfficerAvailability.offline:
        return 'Offline';
    }
  }
}

enum WorkloadLevel { light, moderate, heavy }

extension WorkloadLevelLabel on WorkloadLevel {
  String get label {
    switch (this) {
      case WorkloadLevel.light:
        return 'Light';
      case WorkloadLevel.moderate:
        return 'Moderate';
      case WorkloadLevel.heavy:
        return 'Heavy';
    }
  }
}

class PmuOfficerSummary {
  final String id;
  final String name;
  final String? department;
  final String? designation;
  final String? region;
  final List<AssignmentSummary> assignments;
  final List<InspectionSummary> inspections;
  final OfficerAvailability availability;
  final DateTime? lastActivity;
  final bool rvcAvailable;

  const PmuOfficerSummary({
    required this.id,
    required this.name,
    this.department,
    this.designation,
    this.region,
    this.assignments = const [],
    this.inspections = const [],
    required this.availability,
    this.lastActivity,
    this.rvcAvailable = true,
  });

  // All counts below are derived from the real Assignment/Inspection lists
  // (same enums the PMU officer's own workflow uses) — never stored
  // separately, so they can never drift out of sync with the source data.

  int get assignmentsCount => assignments.length;

  int get completedInspectionsCount =>
      inspections.where((i) => i.status == InspectionStatus.approved).length;

  int get pendingInspectionsCount => inspections
      .where((i) => i.status == InspectionStatus.assigned ||
          i.status == InspectionStatus.inProgress ||
          i.status == InspectionStatus.submitted ||
          i.status == InspectionStatus.underReview)
      .length;

  int get overdueInspectionsCount =>
      inspections.where((i) => i.status == InspectionStatus.overdue).length;

  /// First assignment not yet completed, if any.
  AssignmentSummary? get currentAssignment {
    for (final a in assignments) {
      if (a.status != AssignmentStatus.completed) return a;
    }
    return null;
  }

  WorkloadLevel get workload {
    final active = pendingInspectionsCount + overdueInspectionsCount;
    if (active >= 4) return WorkloadLevel.heavy;
    if (active >= 2) return WorkloadLevel.moderate;
    return WorkloadLevel.light;
  }
}