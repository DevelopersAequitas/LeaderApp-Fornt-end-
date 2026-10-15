import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/report_model.dart';

/// Key performance metric cards section for ReportDetailsView.
class ReportDetailsMetricsSection extends StatelessWidget {
  final ReportModel report;

  const ReportDetailsMetricsSection({super.key, required this.report});

  Widget _buildCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.text,
            ),
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
            'Attendance',
            report.formattedAttendance,
            Icons.how_to_reg_rounded,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCard(
            'Deals',
            report.dealsClosedValue?.isNotEmpty == true ? report.dealsClosedValue! : '-',
            Icons.monetization_on_rounded,
            AppColors.primary,
          ),
        ),
        if (report.totalRevenue?.isNotEmpty == true) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _buildCard(
              'Revenue',
              report.totalRevenue!,
              Icons.trending_up_rounded,
              AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }
}
