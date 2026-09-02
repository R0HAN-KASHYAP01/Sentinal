import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../models/project.dart';

class StatusChip extends StatelessWidget {
  final ProjectStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == ProjectStatus.active;
    final color = isActive ? AppColors.success : AppColors.warning;
    final label = isActive ? 'Active' : 'Under Review';
    return _Chip(color: color, label: label);
  }
}

class RiskChip extends StatelessWidget {
  final RiskLevel risk;
  const RiskChip({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String label;
    switch (risk) {
      case RiskLevel.low:
        color = AppColors.success;
        label = 'Low Risk';
        break;
      case RiskLevel.medium:
        color = AppColors.warning;
        label = 'Medium Risk';
        break;
      case RiskLevel.high:
        color = AppColors.error;
        label = 'High Risk';
        break;
    }
    return _Chip(color: color, label: label);
  }
}

class _Chip extends StatelessWidget {
  final Color color;
  final String label;
  const _Chip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}