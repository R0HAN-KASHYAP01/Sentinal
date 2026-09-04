import '../../../models/institute.dart';
import '../../../models/scheme.dart';
import 'package:flutter/material.dart';

class MockSchemesData {
  MockSchemesData._();

  static const List<Scheme> schemes = [
    Scheme(
      type: SchemeType.ngo,
      name: 'NGO Scheme',
      description: 'Funding and monitoring for registered non-governmental organizations.',
      icon: Icons.groups_outlined,
      color: Color(0xFF2A5C8A),
    ),
    Scheme(
      type: SchemeType.educational,
      name: 'Educational Scheme',
      description: 'Support for schools, vocational and special education institutes.',
      icon: Icons.school_outlined,
      color: Color(0xFF1E7A46),
    ),
    Scheme(
      type: SchemeType.economicDevelopment,
      name: 'Economic Development Scheme',
      description: 'Skill development, livelihood and microfinance initiatives.',
      icon: Icons.trending_up,
      color: Color(0xFFB56B00),
    ),
    Scheme(
      type: SchemeType.socialEmpowerment,
      name: 'Social Empowerment Scheme',
      description: 'Programs for community, disability and welfare empowerment.',
      icon: Icons.volunteer_activism_outlined,
      color: Color(0xFF6B3FA0),
    ),
  ];

  static final List<Institute> institutes = [
    // ---- NGO Scheme ----
    Institute(
      id: 'INST-2001',
      name: 'Sunrise Child Welfare NGO',
      schemeType: SchemeType.ngo,
      category: 'Child Welfare NGO',
      location: 'New Delhi',
      status: InstituteStatus.active,
      registrationDate: DateTime(2019, 4, 10),
      fundsAllocated: 4200000,
      fundsUtilized: 3650000,
      contactPerson: 'Rajesh Sharma',
      contactPhone: '+91 XXXXX XXXXX',
      contactEmail: 'contact@sunrisengo.example.com',
      lastInspection: InstituteInspection(
        dateTime: DateTime(2026, 8, 12, 11, 30),
        inspectorName: 'Anita Verma',
        status: 'Completed',
        reportSummary:
            'Facility found compliant with safety norms. Fund utilization records verified against receipts. No major discrepancies observed.',
      ),
    ),
    Institute(
      id: 'INST-2002',
      name: 'Women Empowerment Foundation',
      schemeType: SchemeType.ngo,
      category: 'Women Empowerment NGO',
      location: 'Bhopal',
      status: InstituteStatus.active,
      registrationDate: DateTime(2020, 1, 22),
      fundsAllocated: 3100000,
      fundsUtilized: 2870000,
      contactPerson: 'Sunita Rao',
      contactPhone: '+91 XXXXX XXXXX',
      contactEmail: 'contact@wef.example.com',
      lastInspection: InstituteInspection(
        dateTime: DateTime(2026, 8, 5, 10, 0),
        inspectorName: 'Sanjay Rathi',
        status: 'Completed',
        reportSummary:
            'Skill training center operating as per proposal. Attendance registers cross-checked. Minor documentation gaps flagged for follow-up.',
      ),
    ),
    Institute(
      id: 'INST-2003',
      name: 'Elder Care Trust',
      schemeType: SchemeType.ngo,
      category: 'Elderly Care NGO',
      location: 'Pune',
      status: InstituteStatus.underReview,
      registrationDate: DateTime(2018, 9, 3),
      fundsAllocated: 2600000,
      fundsUtilized: 2550000,
      contactPerson: 'Manoj Deshmukh',
      contactPhone: '+91 XXXXX XXXXX',
      contactEmail: 'contact@eldercaretrust.example.com',
      lastInspection: InstituteInspection(
        dateTime: DateTime(2026, 8, 20, 14, 15),
        inspectorName: 'Deepak Nair',
        status: 'Flagged',
        reportSummary:
            'Fund utilization nearing full allocation ahead of schedule. Additional documentation requested before next disbursement.',
      ),
    ),

    // ---- Educational Scheme ----
    Institute(
      id: 'INST-3001',
      name: 'Government Primary School No. 4',
      schemeType: SchemeType.educational,
      category: 'Primary School',
      location: 'Lucknow',
      status: InstituteStatus.active,
      registrationDate: DateTime(2017, 6, 15),
      fundsAllocated: 5400000,
      fundsUtilized: 4980000,
      contactPerson: 'Meena Kulkarni',
      contactPhone: '+91 XXXXX XXXXX',
      contactEmail: 'contact@gps4.example.com',
      lastInspection: InstituteInspection(
        dateTime: DateTime(2026, 7, 28, 9, 45),
        inspectorName: 'Vikram Singh',
        status: 'Completed',
        reportSummary:
            'Infrastructure and mid-day meal program reviewed. All records in order. Recommended minor repairs to classroom flooring.',
      ),
    ),
    Institute(
      id: 'INST-3002',
      name: 'National Vocational Training Institute',
      schemeType: SchemeType.educational,
      category: 'Vocational Training Institute',
      location: 'Ahmedabad',
      status: InstituteStatus.active,
      registrationDate: DateTime(2021, 2, 11),
      fundsAllocated: 6800000,
      fundsUtilized: 5100000,
      contactPerson: 'Kiran Patel',
      contactPhone: '+91 XXXXX XXXXX',
      contactEmail: 'contact@nvti.example.com',
      lastInspection: InstituteInspection(
        dateTime: DateTime(2026, 6, 30, 13, 0),
        inspectorName: 'Anita Verma',
        status: 'Completed',
        reportSummary:
            'Training equipment and enrollment data verified. Placement records for last batch reviewed and found satisfactory.',
      ),
    ),
    Institute(
      id: 'INST-3003',
      name: 'Special Education Resource Centre',
      schemeType: SchemeType.educational,
      category: 'Special Education Centre',
      location: 'Chennai',
      status: InstituteStatus.underReview,
      registrationDate: DateTime(2019, 11, 1),
      fundsAllocated: 3900000,
      fundsUtilized: 3200000,
      contactPerson: 'Lakshmi Iyer',
      contactPhone: '+91 XXXXX XXXXX',
      contactEmail: 'contact@serc.example.com',
      lastInspection: InstituteInspection(
        dateTime: DateTime(2026, 8, 1, 11, 0),
        inspectorName: 'Sanjay Rathi',
        status: 'Flagged',
        reportSummary:
            'Staff-to-student ratio below prescribed norm. Corrective action plan requested within 30 days.',
      ),
    ),

    // ---- Economic Development Scheme ----
    Institute(
      id: 'INST-4001',
      name: 'Rural Skill Development Centre',
      schemeType: SchemeType.economicDevelopment,
      category: 'Skill Development Centre',
      location: 'Jaipur',
      status: InstituteStatus.active,
      registrationDate: DateTime(2020, 5, 18),
      fundsAllocated: 4700000,
      fundsUtilized: 3900000,
      contactPerson: 'Vikram Singh',
      contactPhone: '+91 XXXXX XXXXX',
      contactEmail: 'contact@rsdc.example.com',
      lastInspection: InstituteInspection(
        dateTime: DateTime(2026, 7, 15, 10, 30),
        inspectorName: 'Meena Kulkarni',
        status: 'Completed',
        reportSummary:
            'Batch completion and job placement figures verified against partner employer records. No irregularities found.',
      ),
    ),
    Institute(
      id: 'INST-4002',
      name: 'Community Microfinance Institute',
      schemeType: SchemeType.economicDevelopment,
      category: 'Microfinance Institute',
      location: 'Hyderabad',
      status: InstituteStatus.active,
      registrationDate: DateTime(2018, 3, 9),
      fundsAllocated: 8200000,
      fundsUtilized: 6100000,
      contactPerson: 'Ravi Teja',
      contactPhone: '+91 XXXXX XXXXX',
      contactEmail: 'contact@cmi.example.com',
      lastInspection: InstituteInspection(
        dateTime: DateTime(2026, 8, 18, 15, 0),
        inspectorName: 'Deepak Nair',
        status: 'Completed',
        reportSummary:
            'Loan disbursement and repayment ledgers audited. Utilization on track with quarterly projections.',
      ),
    ),
    Institute(
      id: 'INST-4003',
      name: 'Rural Livelihood Mission Unit',
      schemeType: SchemeType.economicDevelopment,
      category: 'Rural Livelihood Mission',
      location: 'Patna',
      status: InstituteStatus.suspended,
      registrationDate: DateTime(2017, 12, 20),
      fundsAllocated: 5000000,
      fundsUtilized: 4950000,
      contactPerson: 'Suresh Kumar',
      contactPhone: '+91 XXXXX XXXXX',
      contactEmail: 'contact@rlmu.example.com',
      lastInspection: InstituteInspection(
        dateTime: DateTime(2026, 5, 22, 12, 0),
        inspectorName: 'Anita Verma',
        status: 'Flagged',
        reportSummary:
            'Significant discrepancies found between reported beneficiaries and field verification. Disbursement suspended pending inquiry.',
      ),
    ),

    // ---- Social Empowerment Scheme ----
    Institute(
      id: 'INST-5001',
      name: 'Community Empowerment Centre',
      schemeType: SchemeType.socialEmpowerment,
      category: 'Community Empowerment Centre',
      location: 'Bengaluru',
      status: InstituteStatus.active,
      registrationDate: DateTime(2021, 7, 7),
      fundsAllocated: 2900000,
      fundsUtilized: 2400000,
      contactPerson: 'Priya Nambiar',
      contactPhone: '+91 XXXXX XXXXX',
      contactEmail: 'contact@cec.example.com',
      lastInspection: InstituteInspection(
        dateTime: DateTime(2026, 8, 9, 10, 15),
        inspectorName: 'Vikram Singh',
        status: 'Completed',
        reportSummary:
            'Community outreach programs reviewed. Beneficiary feedback largely positive. No corrective action needed.',
      ),
    ),
    Institute(
      id: 'INST-5002',
      name: 'Disability Support & Welfare Centre',
      schemeType: SchemeType.socialEmpowerment,
      category: 'Disability Support Centre',
      location: 'Kolkata',
      status: InstituteStatus.active,
      registrationDate: DateTime(2019, 10, 14),
      fundsAllocated: 3600000,
      fundsUtilized: 3100000,
      contactPerson: 'Arjun Ghosh',
      contactPhone: '+91 XXXXX XXXXX',
      contactEmail: 'contact@dswc.example.com',
      lastInspection: InstituteInspection(
        dateTime: DateTime(2026, 7, 2, 9, 30),
        inspectorName: 'Meena Kulkarni',
        status: 'Completed',
        reportSummary:
            'Accessibility infrastructure and assistive equipment inventory verified. Minor maintenance items noted.',
      ),
    ),
    Institute(
      id: 'INST-5003',
      name: 'SC/ST Welfare Centre',
      schemeType: SchemeType.socialEmpowerment,
      category: 'SC/ST Welfare Centre',
      location: 'Nagpur',
      status: InstituteStatus.underReview,
      registrationDate: DateTime(2020, 8, 25),
      fundsAllocated: 4100000,
      fundsUtilized: 3300000,
      contactPerson: 'Sunil Waghmare',
      contactPhone: '+91 XXXXX XXXXX',
      contactEmail: 'contact@scstwc.example.com',
      lastInspection: InstituteInspection(
        dateTime: DateTime(2026, 8, 22, 16, 0),
        inspectorName: 'Sanjay Rathi',
        status: 'Flagged',
        reportSummary:
            'Scholarship disbursement timelines delayed. Review of beneficiary list requested from institute administration.',
      ),
    ),
  ];

  static List<Institute> institutesForScheme(SchemeType type) =>
      institutes.where((i) => i.schemeType == type).toList();

  static int countForScheme(SchemeType type) =>
      institutes.where((i) => i.schemeType == type).length;
}