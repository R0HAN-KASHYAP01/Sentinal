enum RiskLevel { low, medium, high }

enum InspectionStatus {
  assigned,
  inProgress,
  submitted,
  underReview,
  approved,
  overdue,
}

extension InspectionStatusLabel on InspectionStatus {
  String get label {
    switch (this) {
      case InspectionStatus.assigned:
        return 'Assigned';
      case InspectionStatus.inProgress:
        return 'In Progress';
      case InspectionStatus.submitted:
        return 'Submitted';
      case InspectionStatus.underReview:
        return 'Under Review';
      case InspectionStatus.approved:
        return 'Approved';
      case InspectionStatus.overdue:
        return 'Overdue';
    }
  }
}

extension RiskLevelLabel on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High';
    }
  }
}

class InspectionSummary {
  final String projectName;
  final String inspectorName;
  final DateTime dateTime;
  final InspectionStatus status;
  final RiskLevel risk;

  const InspectionSummary({
    required this.projectName,
    required this.inspectorName,
    required this.dateTime,
    required this.status,
    required this.risk,
  });
}