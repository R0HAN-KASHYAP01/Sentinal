import 'scheme.dart';

enum InstituteStatus { active, underReview, suspended }

extension InstituteStatusLabel on InstituteStatus {
  String get label {
    switch (this) {
      case InstituteStatus.active:
        return 'Active';
      case InstituteStatus.underReview:
        return 'Under Review';
      case InstituteStatus.suspended:
        return 'Suspended';
    }
  }
}

class InstituteInspection {
  final DateTime dateTime;
  final String inspectorName;
  final String status;
  final String reportSummary;

  const InstituteInspection({
    required this.dateTime,
    required this.inspectorName,
    required this.status,
    required this.reportSummary,
  });
}

class Institute {
  final String id;
  final String name;
  final SchemeType schemeType;
  final String category;
  final String location;
  final InstituteStatus status;
  final DateTime registrationDate;
  final double fundsAllocated;
  final double fundsUtilized;
  final String contactPerson;
  final String contactPhone;
  final String contactEmail;
  final InstituteInspection? lastInspection;

  const Institute({
    required this.id,
    required this.name,
    required this.schemeType,
    required this.category,
    required this.location,
    required this.status,
    required this.registrationDate,
    required this.fundsAllocated,
    required this.fundsUtilized,
    required this.contactPerson,
    required this.contactPhone,
    required this.contactEmail,
    this.lastInspection,
  });

  String get statusLabel => status.label;

  double get utilizationFraction {
    if (fundsAllocated <= 0) return 0;
    final f = fundsUtilized / fundsAllocated;
    if (f < 0) return 0;
    if (f > 1) return 1;
    return f;
  }
}