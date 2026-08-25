import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/report_model.dart';

/// Card item displaying a past submitted report with type, status, author, and metrics.
class ReportHistoryCard extends StatelessWidget {
  final ReportModel report;

  const ReportHistoryCard({super.key, required this.report});

  Color _getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'actioned':
        return const Color(0xFFDCFCE7);
      case 'submitted':
        return const Color(0xFFFEF3C7);
      case 'rejected':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  Color _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'actioned':
        return const Color(0xFF16A34A);
      case 'submitted':
        return const Color(0xFFD97706);
      case 'rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBg = _getStatusBg(report.status);
    final statusText = _getStatusText(report.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            children: [
              // Type Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF3FB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  report.type,
                  style: const TextStyle(
                    color: Color(0xFF1E3C72),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  report.status,
                  style: TextStyle(
                    color: statusText,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              // Date
              Text(
                report.date,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Author
          Text(
            'By: ${report.author.isNotEmpty ? report.author : 'Circle Leadership'}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (report.attendancePercentage != null ||
              (report.dealsClosedValue != null &&
                  report.dealsClosedValue!.isNotEmpty)) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                if (report.attendancePercentage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Attendance: ${report.attendancePercentage}%',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (report.dealsClosedValue != null &&
                    report.dealsClosedValue!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Deals: ${report.dealsClosedValue}',
                      style: const TextStyle(
                        color: Color(0xFF16A34A),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          // Content paragraph
          Text(
            report.content,
            style: TextStyle(
              color: AppColors.text.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
