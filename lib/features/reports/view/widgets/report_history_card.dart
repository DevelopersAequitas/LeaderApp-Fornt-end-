import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_widgets.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../model/report_model.dart';
import '../report_details_view.dart';
import 'report_history_card_header.dart';

/// Card item displaying a past submitted report with type, status, author, and metrics.
/// Full export options are available in ReportDetailsView upon tapping the card.
class ReportHistoryCard extends StatelessWidget {
  final ReportModel report;
  const ReportHistoryCard({super.key, required this.report});

  Widget _metricChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: const GradientBoxBorder(
          gradient: AppColors.subtleCardBorderGradient,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GradientIcon(icon: icon, size: 12, gradient: AppColors.brandGradient),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          GradientText(
            value,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
            gradient: AppColors.brandGradient,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = report;
    final by = r.author.isNotEmpty ? r.author : (r.circleName.isNotEmpty ? r.circleName : "Circle Leadership");

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReportDetailsView(report: r))),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.015), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReportHistoryCardHeader(
              report: r,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                InitialsAvatar(
                  name: by,
                  imageUrl: r.authorAvatarUrl,
                  radius: 9,
                  fontSize: 7.5,
                  backgroundColor: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'By: $by · ${r.authorRole}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (r.attendancePercentage != null ||
                (r.dealsClosedValue?.isNotEmpty == true) ||
                (r.totalRevenue?.isNotEmpty == true)) ...[
              const SizedBox(height: 7),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (r.attendancePercentage != null)
                    _metricChip(
                      icon: Icons.how_to_reg_rounded,
                      label: 'Attendance',
                      value: r.formattedAttendance,
                    ),
                  if (r.dealsClosedValue?.isNotEmpty == true)
                    _metricChip(
                      icon: Icons.currency_rupee_rounded,
                      label: 'Deals',
                      value: r.dealsClosedValue!,
                    ),
                  if (r.totalRevenue?.isNotEmpty == true)
                    _metricChip(
                      icon: Icons.trending_up_rounded,
                      label: 'Revenue',
                      value: r.totalRevenue!,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Text(
              r.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.text.withValues(alpha: 0.85), fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Tap to view full report & peer roster ➔',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
