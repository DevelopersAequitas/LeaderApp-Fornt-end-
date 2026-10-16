import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../model/report_model.dart';
import '../report_details_view.dart';
import '../services/report_export_service.dart';
import 'report_history_card_header.dart';

/// Card item displaying a past submitted report with type, status, author, metrics, and download options.
class ReportHistoryCard extends StatefulWidget {
  final ReportModel report;
  const ReportHistoryCard({super.key, required this.report});

  @override
  State<ReportHistoryCard> createState() => _ReportHistoryCardState();
}

class _ReportHistoryCardState extends State<ReportHistoryCard> {
  bool _isDownloadingPdf = false;
  bool _isExportingExcel = false;

  Future<void> _handlePdf() async {
    setState(() => _isDownloadingPdf = true);
    await ReportExportService.downloadPdf(context, widget.report);
    if (mounted) setState(() => _isDownloadingPdf = false);
  }

  Future<void> _handleExcel() async {
    setState(() => _isExportingExcel = true);
    await ReportExportService.downloadExcel(context, widget.report);
    if (mounted) setState(() => _isExportingExcel = false);
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: const TextStyle(color: AppColors.text, fontSize: 10, fontWeight: FontWeight.w500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
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
              isDownloadingPdf: _isDownloadingPdf,
              isExportingExcel: _isExportingExcel,
              onDownloadPdf: _handlePdf,
              onDownloadExcel: _handleExcel,
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
            if (r.attendancePercentage != null || (r.dealsClosedValue?.isNotEmpty == true)) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  if (r.attendancePercentage != null) _chip('Attendance: ${r.formattedAttendance}'),
                  if (r.dealsClosedValue?.isNotEmpty == true) _chip('Deals: ${r.dealsClosedValue}'),
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
