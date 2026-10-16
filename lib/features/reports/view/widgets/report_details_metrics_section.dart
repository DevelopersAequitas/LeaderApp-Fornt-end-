import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_widgets.dart';
import '../../model/report_model.dart';

/// Key performance metric cards section for ReportDetailsView with brand gradient styling.
class ReportDetailsMetricsSection extends StatelessWidget {
  final ReportModel report;

  const ReportDetailsMetricsSection({super.key, required this.report});

  Widget _buildCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const GradientBoxBorder(
          gradient: AppColors.subtleCardBorderGradient,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientIcon(
                icon: icon,
                size: 16,
                gradient: AppColors.brandGradient,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GradientText(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            gradient: AppColors.brandGradient,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            label: 'Attendance',
            value: report.formattedAttendance,
            icon: Icons.how_to_reg_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCard(
            label: 'Deals',
            value: report.dealsClosedValue?.isNotEmpty == true ? report.dealsClosedValue! : '-',
            icon: Icons.currency_rupee_rounded,
          ),
        ),
        if (report.totalRevenue?.isNotEmpty == true) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _buildCard(
              label: 'Revenue',
              value: report.totalRevenue!,
              icon: Icons.trending_up_rounded,
            ),
          ),
        ],
      ],
    );
  }
}
