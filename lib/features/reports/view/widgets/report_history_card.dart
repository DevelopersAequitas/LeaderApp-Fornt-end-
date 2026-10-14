import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/reports_repository.dart';
import '../../model/report_model.dart';

/// Card item displaying a past submitted report with type, status, author, metrics, and download options.
class ReportHistoryCard extends StatefulWidget {
  final ReportModel report;

  const ReportHistoryCard({super.key, required this.report});

  @override
  State<ReportHistoryCard> createState() => _ReportHistoryCardState();
}

class _ReportHistoryCardState extends State<ReportHistoryCard> {
  bool _isDownloading = false;

  Color _getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'actioned':
        return const Color(0xFFDCFCE7);
      case 'submitted':
      case 'under review':
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
      case 'under review':
        return const Color(0xFFD97706);
      case 'rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Future<void> _handleDownloadPdf(String reportId) async {
    setState(() => _isDownloading = true);
    try {
      final res = await ReportsRepositoryImpl().getReportDownloadUrl(reportId);
      if (!mounted) return;
      setState(() => _isDownloading = false);
      if (res.success && res.data != null) {
        final download = res.data!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Opening ${download.fileName} (${download.fileSize.isNotEmpty ? download.fileSize : "PDF"})...',
            ),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );

        final uri = Uri.tryParse(download.downloadUrl);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message ?? 'Failed to get report download link.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showReportDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (_, scrollController) => FutureBuilder<ReportModel>(
          future: widget.report.id.isNotEmpty
              ? ReportsRepositoryImpl()
                  .getReportDetails(widget.report.id)
                  .then((res) => res.data ?? widget.report)
                  .catchError((_) => widget.report)
              : Future.value(widget.report),
          initialData: widget.report,
          builder: (context, snapshot) {
            final activeReport = snapshot.data ?? widget.report;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Header Row with Title, Period, Status & Download button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeReport.circleName.isNotEmpty
                                    ? activeReport.circleName
                                    : 'Circle Performance Report',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Period: ${activeReport.date} · ${activeReport.type}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (activeReport.districtName != null || activeReport.industryName != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '${activeReport.districtName ?? ""}${activeReport.districtName != null && activeReport.industryName != null ? " · " : ""}${activeReport.industryName ?? ""}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusBg(activeReport.status),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                activeReport.status,
                                style: TextStyle(
                                  color: _getStatusText(activeReport.status),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (activeReport.id.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => _handleDownloadPdf(activeReport.id),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFBFDBFE)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.picture_as_pdf_rounded, size: 13, color: AppColors.primary),
                                      SizedBox(width: 4),
                                      Text(
                                        'PDF',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 20),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // Submitter Info Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.person, color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activeReport.author.isNotEmpty ? activeReport.author : 'Circle Leader',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    Text(
                                      activeReport.authorRole,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Metrics Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                'Attendance',
                                activeReport.formattedAttendance,
                                Icons.how_to_reg_rounded,
                                const Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMetricCard(
                                'Deals Closed',
                                activeReport.dealsClosedValue ?? '₹0.0',
                                Icons.monetization_on_rounded,
                                const Color(0xFF16A34A),
                              ),
                            ),
                            if (activeReport.totalRevenue != null && activeReport.totalRevenue!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildMetricCard(
                                  'Revenue',
                                  activeReport.totalRevenue!,
                                  Icons.trending_up_rounded,
                                  const Color(0xFF9333EA),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Summary Section
                        const Text(
                          'Executive Summary & Notes',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            activeReport.content.isNotEmpty
                                ? activeReport.content
                                : 'No summary notes provided.',
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: AppColors.text,
                            ),
                          ),
                        ),

                        // Highlights Section
                        if (activeReport.highlights != null && activeReport.highlights!.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Text(
                            'Key Highlights & Wins',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Text(
                              activeReport.highlights!,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF065F46),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],

                        // Challenges Section
                        if (activeReport.challengesFaced != null && activeReport.challengesFaced!.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Text(
                            'Challenges Faced & Roadblocks',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: Text(
                              activeReport.challengesFaced!,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF991B1B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],

                        // Action Items Section
                        if (activeReport.actionItems != null && activeReport.actionItems!.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Text(
                            'Action Items & Next Steps',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Text(
                              activeReport.actionItems!,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF92400E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),
                        // Peer Roster & Membership Breakdown
                        Row(
                          children: [
                            const Text(
                              'Peer Roster & Membership Breakdown',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '(${activeReport.peersRoster.length} Peers)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (activeReport.peersRoster.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Text(
                              'Peer breakdown not attached or generated for this report cycle.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        else
                          ...activeReport.peersRoster.map((peer) => _buildPeerRosterItem(peer)),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeerRosterItem(ReportPeerRosterItem peer) {
    final isActive = peer.status.toLowerCase() == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFFF1F5F9),
                backgroundImage: peer.avatarUrl != null && peer.avatarUrl!.isNotEmpty
                    ? NetworkImage(peer.avatarUrl!)
                    : null,
                child: peer.avatarUrl == null || peer.avatarUrl!.isEmpty
                    ? Text(
                        peer.name.isNotEmpty ? peer.name[0].toUpperCase() : 'P',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  peer.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.text,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  peer.status,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isActive ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          if (peer.company.isNotEmpty || peer.designation.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '${peer.designation.isNotEmpty ? "${peer.designation} · " : ""}${peer.company}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 6),
          // Membership Dates Row
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                if (peer.platformMembershipStart.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.apps_rounded, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      const Text(
                        'Platform Validity: ',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${peer.platformMembershipStart} ➔ ${peer.platformMembershipEnd.isNotEmpty ? peer.platformMembershipEnd : "Active"}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                if (peer.circleJoiningDate.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.circle_outlined, size: 12, color: Color(0xFF16A34A)),
                      const SizedBox(width: 4),
                      const Text(
                        'Circle Membership: ',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${peer.circleJoiningDate} ➔ ${peer.circleRenewalDate.isNotEmpty ? peer.circleRenewalDate : "Active"}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Contribution Badges
          Row(
            children: [
              _buildSmallBadge('Att: ${peer.attendance}'),
              const SizedBox(width: 6),
              _buildSmallBadge('Deals: ${peer.dealsClosed}'),
              const SizedBox(width: 6),
              _buildSmallBadge('P2P: ${peer.p2pCount}'),
              const SizedBox(width: 6),
              _buildSmallBadge('Ref: ${peer.referralsCount}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w500,
          color: AppColors.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBg = _getStatusBg(widget.report.status);
    final statusText = _getStatusText(widget.report.status);

    return InkWell(
      onTap: () => _showReportDetailsModal(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                    widget.report.type,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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
                    widget.report.status,
                    style: TextStyle(
                      color: statusText,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                // Date
                Text(
                  widget.report.date,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.report.id.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: _isDownloading
                        ? null
                        : () => _handleDownloadPdf(widget.report.id),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: _isDownloading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.download_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // Author
            Text(
              'By: ${widget.report.author.isNotEmpty ? widget.report.author : 'Circle Leadership'} · ${widget.report.authorRole}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.report.attendancePercentage != null ||
                (widget.report.dealsClosedValue != null &&
                    widget.report.dealsClosedValue!.isNotEmpty)) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  if (widget.report.attendancePercentage != null)
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
                        'Attendance: ${widget.report.formattedAttendance}',
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (widget.report.dealsClosedValue != null &&
                      widget.report.dealsClosedValue!.isNotEmpty)
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
                        'Deals: ${widget.report.dealsClosedValue}',
                        style: const TextStyle(
                          color: Color(0xFF16A34A),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            // Content paragraph
            Text(
              widget.report.content,
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Tap to view full report & peer roster ➔',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
