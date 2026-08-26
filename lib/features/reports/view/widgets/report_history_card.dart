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

  void _showReportDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.circleName.isNotEmpty
                                ? report.circleName
                                : 'Circle Performance Report',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Period: ${report.date} · ${report.type}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusBg(report.status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        report.status,
                        style: TextStyle(
                          color: _getStatusText(report.status),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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
                            backgroundColor: Color(0xFF1E3C72),
                            child: Icon(Icons.person, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report.author.isNotEmpty ? report.author : 'Circle Leader',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppColors.text,
                                  ),
                                ),
                                Text(
                                  report.authorRole,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
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
                            '${report.attendancePercentage ?? 100}%',
                            Icons.how_to_reg_rounded,
                            const Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricCard(
                            'Deals Closed',
                            report.dealsClosedValue ?? '₹0.0',
                            Icons.monetization_on_rounded,
                            const Color(0xFF16A34A),
                          ),
                        ),
                        if (report.totalRevenue != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricCard(
                              'Revenue',
                              report.totalRevenue!,
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
                        fontWeight: FontWeight.w700,
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
                        report.content.isNotEmpty
                            ? report.content
                            : 'No summary notes provided.',
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: AppColors.text,
                        ),
                      ),
                    ),

                    if (report.actionItems != null && report.actionItems!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Action Items & Next Steps',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
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
                          report.actionItems!,
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
                          'Peer Roster & Membership Dates',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '(${report.peersRoster.length} Peers)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (report.peersRoster.isEmpty)
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
                      ...report.peersRoster.map((peer) => _buildPeerRosterItem(peer)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
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
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeerRosterItem(ReportPeerRosterItem peer) {
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
              Expanded(
                child: Text(
                  peer.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.text,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: peer.status.toLowerCase() == 'active'
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  peer.status,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: peer.status.toLowerCase() == 'active'
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFD97706),
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
                        'Peers App Validity: ',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${peer.platformMembershipStart} ➔ ${peer.platformMembershipEnd.isNotEmpty ? peer.platformMembershipEnd : "Active"}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E3C72),
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
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${peer.circleJoiningDate} ➔ ${peer.circleRenewalDate.isNotEmpty ? peer.circleRenewalDate : "Active"}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
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
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBg = _getStatusBg(report.status);
    final statusText = _getStatusText(report.status);

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
              'By: ${report.author.isNotEmpty ? report.author : 'Circle Leadership'} · ${report.authorRole}',
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
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Tap to view full report & peer roster ➔',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3C72),
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
