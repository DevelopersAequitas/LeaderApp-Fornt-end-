import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/report_model.dart';

/// Summary, highlights, challenges, and action items block for ReportDetailsView.
class ReportDetailsSummarySection extends StatelessWidget {
  final ReportModel report;

  const ReportDetailsSummarySection({super.key, required this.report});

  Widget _buildBox(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.text,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBox(
          'Executive Summary & Notes',
          report.content.isNotEmpty ? report.content : 'No summary notes provided.',
        ),
        if (report.highlights?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          _buildBox(
            'Key Highlights',
            report.highlights!,
          ),
        ],
        if (report.challengesFaced?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          _buildBox(
            'Challenges Faced',
            report.challengesFaced!,
          ),
        ],
        if (report.actionItems?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          _buildBox(
            'Action Items & Next Steps',
            report.actionItems!,
          ),
        ],
      ],
    );
  }
}
