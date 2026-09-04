import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../models/institute.dart';

class InstituteStatusChip extends StatelessWidget {
  final InstituteStatus status;
  const InstituteStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late Color color;
    switch (status) {
      case InstituteStatus.active:
        color = AppColors.success;
        break;
      case InstituteStatus.underReview:
        color = AppColors.warning;
        break;
      case InstituteStatus.suspended:
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}