import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/report_model.dart';

/// Top row of the report card displaying badges, date, and quick export icons.
class ReportHistoryCardHeader extends StatelessWidget {
  final ReportModel report;
  final bool isDownloadingPdf;
  final bool isExportingExcel;
  final VoidCallback? onDownloadPdf;
  final VoidCallback? onDownloadExcel;

  const ReportHistoryCardHeader({
    super.key,
    required this.report,
    this.isDownloadingPdf = false,
    this.isExportingExcel = false,
    this.onDownloadPdf,
    this.onDownloadExcel,
  });

  Color _getStatusBg(String status) {
    final s = status.toLowerCase();
    if (s == 'approved' || s == 'actioned') return const Color(0xFFDCFCE7);
    if (s == 'submitted' || s == 'under review') return const Color(0xFFFEF3C7);
    if (s == 'rejected') return const Color(0xFFFEE2E2);
    return const Color(0xFFEFF6FF);
  }

  Color _getStatusText(String status) {
    final s = status.toLowerCase();
    if (s == 'approved' || s == 'actioned') return const Color(0xFF16A34A);
    if (s == 'submitted' || s == 'under review') return const Color(0xFFD97706);
    if (s == 'rejected') return const Color(0xFFDC2626);
    return const Color(0xFF2563EB);
  }

  @override
  Widget build(BuildContext context) {
    final showStatus = report.status.isNotEmpty &&
        report.status.trim().toLowerCase().replaceAll(' ', '') != 'underreview';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF3FB),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            report.type,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (showStatus) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _getStatusBg(report.status),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              report.status,
              style: TextStyle(
                color: _getStatusText(report.status),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        const Spacer(),
        Text(
          report.period ?? report.date,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
