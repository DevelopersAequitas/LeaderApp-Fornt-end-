import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/widgets/gradient_widgets.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../model/member_activity_model.dart';

/// Ultra-compact card rendering a single member activity.
class MemberActivityCard extends StatelessWidget {
  final MemberActivityModel activity;

  const MemberActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final name = activity.counterpartName.isNotEmpty
        ? activity.counterpartName
        : activity.title;

    final designationCompany = [
      if (activity.metadata['designation'] != null &&
          activity.metadata['designation'].toString().isNotEmpty)
        activity.metadata['designation'].toString(),
      if (activity.metadata['company_name'] != null &&
          activity.metadata['company_name'].toString().isNotEmpty)
        activity.metadata['company_name'].toString(),
    ].join(' : ');

    final subtitleParts = [
      if (designationCompany.isNotEmpty) designationCompany,
      if (activity.metadata['city'] != null &&
          activity.metadata['city'].toString().isNotEmpty)
        activity.metadata['city'].toString(),
    ].join(' • ');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GradientBorderContainer(
            borderWidth: 1.2,
            borderRadius: 7,
            padding: const EdgeInsets.all(6),
            child: GradientIcon(icon: activity.type.icon, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (activity.amount.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      GradientText(
                        activity.amount,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (activity.status.isNotEmpty &&
                        !activity.status.toLowerCase().contains('earned')) ...[
                      const SizedBox(width: 6),
                      _buildStatusPill(activity.status),
                    ],
                  ],
                ),
                if (subtitleParts.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitleParts,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
                if (activity.counterpartName.isNotEmpty &&
                    activity.title.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    activity.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else if (activity.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    activity.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    final value = status.toLowerCase();
    if (value.contains('cancel') ||
        value.contains('reject') ||
        value.contains('absent')) {
      return StatusPill.danger(label: status, fontSize: 9);
    }
    if (value.contains('pend') ||
        value.contains('schedul') ||
        value.contains('late')) {
      return StatusPill.warning(label: status, fontSize: 9);
    }
    if (value.contains('complet') ||
        value.contains('confirm') ||
        value.contains('clos') ||
        value.contains('present') ||
        value.contains('success')) {
      return StatusPill.active(label: status, fontSize: 9);
    }
    return StatusPill.info(label: status, fontSize: 9);
  }
}
