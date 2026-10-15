import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/reports_repository.dart';
import '../../../../data/repositories/teams_repository.dart';
import '../../model/report_model.dart';

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

  /// Fetches live peers for the report's circle when not pre-attached by the backend.
  Future<List<ReportPeerRosterItem>> _fetchLivePeersForReport(ReportModel report) async {
    if (report.peersRoster.isNotEmpty) {
      return report.peersRoster;
    }

    try {
      String targetCircleId = report.circleId;

      // If circleId is missing or empty, match circle by name from the circles repository
      if (targetCircleId.isEmpty) {
        final circlesRes = await TeamsRepositoryImpl().getCircles();
        if (circlesRes.success && circlesRes.data != null && circlesRes.data!.isNotEmpty) {
          if (report.circleName.isNotEmpty) {
            final matched = circlesRes.data!.firstWhere(
              (c) =>
                  c.name.toLowerCase().trim() == report.circleName.toLowerCase().trim() ||
                  c.id.toLowerCase().trim() == report.circleName.toLowerCase().trim(),
              orElse: () => circlesRes.data!.first,
            );
            targetCircleId = matched.id;
          } else {
            targetCircleId = circlesRes.data!.first.id;
          }
        }
      }

      if (targetCircleId.isNotEmpty) {
        final peersRes = await TeamsRepositoryImpl().getCirclePeers(targetCircleId);
        if (peersRes.success && peersRes.data != null && peersRes.data!.isNotEmpty) {
          return peersRes.data!.map((p) {
            return ReportPeerRosterItem(
              peerId: p.id,
              name: p.name,
              avatarUrl: p.avatarUrl,
              company: p.company,
              designation: p.designation ?? '',
              status: p.status,
              platformMembershipStart: p.joinedDate ?? '',
              platformMembershipEnd: '',
              circleJoiningDate: p.joinedDate ?? '',
              circleRenewalDate: '',
              attendance: p.attendance,
              dealsClosed: p.dealsFormatted,
              p2pCount: p.p2pMeetings ?? 0,
              referralsCount: p.referralsGiven ?? 0,
            );
          }).toList();
        }
      }
    } catch (_) {}

    return report.peersRoster;
  }

  /// Resolves the full report details and ensures live peer roster is loaded.
  Future<ReportModel> _loadFullReport(ReportModel baseReport) async {
    ReportModel active = baseReport;

    if (baseReport.id.isNotEmpty) {
      try {
        final res = await ReportsRepositoryImpl().getReportDetails(baseReport.id);
        if (res.success && res.data != null) {
          active = res.data!;
        }
      } catch (_) {}
    }

    if (active.peersRoster.isEmpty) {
      final livePeers = await _fetchLivePeersForReport(active);
      if (livePeers.isNotEmpty) {
        active = active.copyWith(peersRoster: livePeers);
      }
    }

    return active;
  }

  /// Downloads or displays the authentic PDF report.
  Future<void> _handleDownloadPdf(String reportId, {ReportModel? report, List<ReportPeerRosterItem>? peers}) async {
    setState(() => _isDownloadingPdf = true);
    try {
      final targetReport = report ?? widget.report;

      // 1. Try backend report download URL first
      if (reportId.isNotEmpty) {
        final res = await ReportsRepositoryImpl().getReportDownloadUrl(reportId);
        if (res.success && res.data != null && res.data!.downloadUrl.isNotEmpty) {
          final download = res.data!;
          final uri = Uri.tryParse(download.downloadUrl);
          if (uri != null) {
            bool launched = false;
            try {
              launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {}
            if (!launched) {
              try {
                launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
              } catch (_) {}
            }
            if (launched) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Opening ${download.fileName.isNotEmpty ? download.fileName : "PDF Document"}...',
                    ),
                    backgroundColor: const Color(0xFF16A34A),
                  ),
                );
              }
              return;
            }
          }
        }
      }

      // 2. Fallback: generate printable HTML/PDF report
      List<ReportPeerRosterItem> targetPeers = peers ?? targetReport.peersRoster;
      if (targetPeers.isEmpty) {
        targetPeers = await _fetchLivePeersForReport(targetReport);
      }

      final htmlContent = _generateReportHtml(targetReport, targetPeers);
      final dataUri = Uri.dataFromString(
        htmlContent,
        mimeType: 'text/html',
        encoding: utf8,
      );

      bool launched = false;
      try {
        launched = await launchUrl(dataUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      if (!launched) {
        try {
          launched = await launchUrl(dataUri, mode: LaunchMode.platformDefault);
        } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              launched
                  ? 'PDF Report ready! Use browser print/save as PDF.'
                  : 'PDF Report generated for ${targetReport.circleName.isNotEmpty ? targetReport.circleName : "Circle"}.',
            ),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF download failed: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDownloadingPdf = false);
    }
  }

  /// Exports and downloads the live Excel / CSV report with peer roster breakdown.
  Future<void> _handleDownloadExcel(ReportModel report, [List<ReportPeerRosterItem>? peers]) async {
    setState(() => _isExportingExcel = true);
    try {
      // 1. Try server-side export first
      if (report.id.isNotEmpty || report.circleId.isNotEmpty) {
        try {
          final res = await ReportsRepositoryImpl().exportReports(
            format: 'excel',
            circleId: report.circleId.isNotEmpty ? report.circleId : null,
          );
          if (res.success && res.data != null) {
            final data = res.data!;
            final downloadUrl = data['download_url']?.toString() ??
                data['url']?.toString() ??
                data['file_url']?.toString() ??
                '';
            if (downloadUrl.isNotEmpty) {
              final uri = Uri.tryParse(downloadUrl);
              if (uri != null) {
                bool launched = false;
                try {
                  launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {}
                if (!launched) {
                  try {
                    launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
                  } catch (_) {}
                }
                if (launched) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening Excel Sheet download link...'),
                        backgroundColor: Color(0xFF16A34A),
                      ),
                    );
                  }
                  return;
                }
              }
            }
          }
        } catch (_) {}
      }

      // 2. Generate live Excel CSV spreadsheet with UTF-8 BOM
      List<ReportPeerRosterItem> targetPeers = (peers != null && peers.isNotEmpty) ? peers : report.peersRoster;
      if (targetPeers.isEmpty) {
        targetPeers = await _fetchLivePeersForReport(report);
      }

      final buffer = StringBuffer();
      // Overview header
      buffer.writeln('CIRCLE PERFORMANCE REPORT');
      buffer.writeln('Circle Name,${_escapeCsv(report.circleName)}');
      buffer.writeln('Period,${_escapeCsv(report.period ?? report.date)}');
      buffer.writeln('Type,${_escapeCsv(report.type)}');
      buffer.writeln('Status,${_escapeCsv(report.status)}');
      buffer.writeln('Submitted By,${_escapeCsv(report.author)} (${_escapeCsv(report.authorRole)})');
      buffer.writeln('Attendance,${_escapeCsv(report.formattedAttendance)}');
      buffer.writeln('Deals Closed,${_escapeCsv(report.dealsClosedValue ?? "-")}');
      buffer.writeln('Total Revenue,${_escapeCsv(report.totalRevenue ?? "-")}');
      buffer.writeln('Executive Summary,${_escapeCsv(report.content.replaceAll("\n", " "))}');
      if (report.highlights != null && report.highlights!.isNotEmpty) {
        buffer.writeln('Highlights,${_escapeCsv(report.highlights!.replaceAll("\n", " "))}');
      }
      if (report.challengesFaced != null && report.challengesFaced!.isNotEmpty) {
        buffer.writeln('Challenges,${_escapeCsv(report.challengesFaced!.replaceAll("\n", " "))}');
      }
      if (report.actionItems != null && report.actionItems!.isNotEmpty) {
        buffer.writeln('Action Items,${_escapeCsv(report.actionItems!.replaceAll("\n", " "))}');
      }
      buffer.writeln('');

      // Peer Roster table
      buffer.writeln('PEER ROSTER & BREAKDOWN');
      buffer.writeln('Peer ID,Name,Company,Designation,Status,Platform Joining,Circle Joining,Attendance,Deals Closed,P2P Meetings,Referrals Given');

      for (final p in targetPeers) {
        buffer.writeln([
          _escapeCsv(p.peerId),
          _escapeCsv(p.name),
          _escapeCsv(p.company),
          _escapeCsv(p.designation),
          _escapeCsv(p.status),
          _escapeCsv(p.platformMembershipStart),
          _escapeCsv(p.circleJoiningDate),
          _escapeCsv(p.attendance),
          _escapeCsv(p.dealsClosed),
          p.p2pCount.toString(),
          p.referralsCount.toString(),
        ].join(','));
      }

      final csvString = buffer.toString();
      final dataUri = Uri.dataFromString(
        '\uFEFF$csvString',
        mimeType: 'text/csv',
        encoding: utf8,
      );

      bool launched = false;
      try {
        launched = await launchUrl(dataUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      if (!launched) {
        try {
          launched = await launchUrl(dataUri, mode: LaunchMode.platformDefault);
        } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              launched
                  ? 'Excel sheet exported and opened successfully.'
                  : 'Excel export ready with ${targetPeers.length} circle peers.',
            ),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel export failed: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExportingExcel = false);
    }
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _generateReportHtml(ReportModel report, List<ReportPeerRosterItem> peers) {
    final circleTitle = report.circleName.isNotEmpty ? report.circleName : 'Circle Performance Report';
    final peerRows = peers.map((p) => '''
      <tr>
        <td style="padding: 8px; border-bottom: 1px solid #E2E8F0;">${p.name.isNotEmpty ? p.name : p.company}</td>
        <td style="padding: 8px; border-bottom: 1px solid #E2E8F0;">${p.company}${p.designation.isNotEmpty ? " (${p.designation})" : ""}</td>
        <td style="padding: 8px; border-bottom: 1px solid #E2E8F0;">
          <span style="display:inline-block; padding: 2px 6px; border-radius: 4px; font-size: 11px; background-color: ${p.status.toLowerCase() == 'active' ? '#DCFCE7' : '#FEF3C7'}; color: ${p.status.toLowerCase() == 'active' ? '#16A34A' : '#D97706'}; font-weight: 600;">
            ${p.status}
          </span>
        </td>
        <td style="padding: 8px; border-bottom: 1px solid #E2E8F0; text-align: center;">${p.attendance}</td>
        <td style="padding: 8px; border-bottom: 1px solid #E2E8F0; text-align: right;">${p.dealsClosed}</td>
        <td style="padding: 8px; border-bottom: 1px solid #E2E8F0; text-align: center;">${p.p2pCount}</td>
        <td style="padding: 8px; border-bottom: 1px solid #E2E8F0; text-align: center;">${p.referralsCount}</td>
      </tr>
    ''').join('');

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>$circleTitle</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 32px; color: #1E293B; }
    h1 { font-size: 20px; color: #0F172A; margin-bottom: 4px; }
    .meta { font-size: 13px; color: #64748B; margin-bottom: 20px; }
    .grid { display: flex; gap: 12px; margin-bottom: 24px; }
    .card { flex: 1; padding: 12px; border-radius: 8px; border: 1px solid #E2E8F0; background: #F8FAFC; }
    .card-label { font-size: 11px; color: #64748B; text-transform: uppercase; font-weight: 600; }
    .card-val { font-size: 16px; font-weight: 700; color: #0F172A; margin-top: 4px; }
    .section-title { font-size: 14px; font-weight: 700; margin-top: 20px; margin-bottom: 8px; }
    .box { padding: 12px; background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 8px; font-size: 13px; line-height: 1.5; }
    table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 12px; }
    th { text-align: left; padding: 8px; background: #F1F5F9; font-weight: 600; color: #475569; }
    @media print { body { margin: 0; } }
  </style>
</head>
<body>
  <h1>$circleTitle</h1>
  <div class="meta">Period: ${report.period ?? report.date} &bull; Type: ${report.type} &bull; Status: ${report.status} &bull; Author: ${report.author} (${report.authorRole})</div>
  <div class="grid">
    <div class="card"><div class="card-label">Attendance</div><div class="card-val">${report.formattedAttendance}</div></div>
    <div class="card"><div class="card-label">Deals Closed</div><div class="card-val">${report.dealsClosedValue ?? "-"}</div></div>
    <div class="card"><div class="card-label">Revenue</div><div class="card-val">${report.totalRevenue ?? "-"}</div></div>
  </div>
  <div class="section-title">Executive Summary</div>
  <div class="box">${report.content.isNotEmpty ? report.content : "No executive summary notes provided."}</div>
  ${report.highlights?.isNotEmpty == true ? '<div class="section-title">Highlights</div><div class="box" style="background:#ECFDF5; border-color:#A7F3D0;">${report.highlights!}</div>' : ''}
  ${report.challengesFaced?.isNotEmpty == true ? '<div class="section-title">Challenges</div><div class="box" style="background:#FEF2F2; border-color:#FECACA;">${report.challengesFaced!}</div>' : ''}
  ${report.actionItems?.isNotEmpty == true ? '<div class="section-title">Action Items</div><div class="box" style="background:#FFFBEB; border-color:#FDE68A;">${report.actionItems!}</div>' : ''}
  <div class="section-title">Peer Roster (${peers.length} Peers)</div>
  <table>
    <thead>
      <tr>
        <th>Peer Name</th>
        <th>Company & Role</th>
        <th>Status</th>
        <th style="text-align:center;">Attendance</th>
        <th style="text-align:right;">Deals</th>
        <th style="text-align:center;">P2P</th>
        <th style="text-align:center;">Referrals</th>
      </tr>
    </thead>
    <tbody>
      ${peerRows.isNotEmpty ? peerRows : '<tr><td colspan="7" style="padding:16px; text-align:center; color:#94A3B8;">No circle peers recorded.</td></tr>'}
    </tbody>
  </table>
</body>
</html>
''';
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
          future: _loadFullReport(widget.report),
          initialData: widget.report,
          builder: (context, snapshot) {
            final activeReport = snapshot.data ?? widget.report;
            final isPeerLoading = snapshot.connectionState == ConnectionState.waiting &&
                activeReport.peersRoster.isEmpty;

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
                  // Header Row with Title, Period, Status & Action Download Buttons
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
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Period: ${activeReport.period ?? activeReport.date} · ${activeReport.type}',
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
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // PDF Action Button
                                InkWell(
                                  onTap: () => _handleDownloadPdf(
                                    activeReport.id,
                                    report: activeReport,
                                    peers: activeReport.peersRoster,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFBFDBFE)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.picture_as_pdf_rounded, size: 12, color: AppColors.primary),
                                        SizedBox(width: 3),
                                        Text(
                                          'PDF',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Excel Action Button
                                InkWell(
                                  onTap: () => _handleDownloadExcel(
                                    activeReport,
                                    activeReport.peersRoster,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFA7F3D0)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.table_chart_rounded, size: 12, color: Color(0xFF16A34A)),
                                        SizedBox(width: 3),
                                        Text(
                                          'Excel',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF16A34A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                      activeReport.author.isNotEmpty
                                          ? activeReport.author
                                          : (activeReport.circleName.isNotEmpty
                                              ? '${activeReport.circleName} Circle Leadership'
                                              : SessionManager().currentSession.name),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    Text(
                                      activeReport.authorRole.isNotEmpty
                                          ? activeReport.authorRole
                                          : 'Circle Leadership',
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
                                (activeReport.dealsClosedValue != null && activeReport.dealsClosedValue!.isNotEmpty)
                                    ? activeReport.dealsClosedValue!
                                    : '-',
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
                            fontWeight: FontWeight.w500,
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
                              fontWeight: FontWeight.w500,
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
                              fontWeight: FontWeight.w500,
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
                              fontWeight: FontWeight.w500,
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
                                fontWeight: FontWeight.w500,
                                color: AppColors.text,
                              ),
                            ),
                            const Spacer(),
                            if (isPeerLoading)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
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

                        if (isPeerLoading)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Loading live circle peer roster...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (activeReport.peersRoster.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Text(
                              'No active peer records found for this circle.',
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
              fontWeight: FontWeight.w500,
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
    final peerDisplayName = peer.name.isNotEmpty
        ? peer.name
        : (peer.company.isNotEmpty ? peer.company : (peer.peerId.isNotEmpty ? 'Peer #${peer.peerId}' : 'Peer'));

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
                        peerDisplayName.isNotEmpty ? peerDisplayName[0].toUpperCase() : 'P',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  peerDisplayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: AppColors.text,
                  ),
                ),
              ),
              if (peer.status.isNotEmpty)
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
                      fontWeight: FontWeight.w500,
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
          if (peer.platformMembershipStart.isNotEmpty || peer.circleJoiningDate.isNotEmpty) ...[
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
                            fontWeight: FontWeight.w500,
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
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          Builder(
            builder: (context) {
              final badges = <Widget>[];
              if (peer.attendance.isNotEmpty && peer.attendance != '-') {
                badges.add(_buildSmallBadge('Att: ${peer.attendance}'));
              }
              if (peer.dealsClosed.isNotEmpty && peer.dealsClosed != '-' && peer.dealsClosed != '₹0') {
                badges.add(_buildSmallBadge('Deals: ${peer.dealsClosed}'));
              }
              if (peer.p2pCount > 0) {
                badges.add(_buildSmallBadge('P2P: ${peer.p2pCount}'));
              }
              if (peer.referralsCount > 0) {
                badges.add(_buildSmallBadge('Ref: ${peer.referralsCount}'));
              }

              if (badges.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: badges,
                ),
              );
            },
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
                      fontWeight: FontWeight.w500,
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                // Date
                Text(
                  widget.report.period ?? widget.report.date,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                // PDF Action Icon
                InkWell(
                  onTap: _isDownloadingPdf
                      ? null
                      : () => _handleDownloadPdf(widget.report.id, report: widget.report),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: _isDownloadingPdf
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.picture_as_pdf_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                  ),
                ),
                const SizedBox(width: 4),
                // Excel Action Icon
                InkWell(
                  onTap: _isExportingExcel
                      ? null
                      : () => _handleDownloadExcel(widget.report),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: _isExportingExcel
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.table_chart_rounded,
                            size: 14,
                            color: Color(0xFF16A34A),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Author
            Text(
              'By: ${widget.report.author.isNotEmpty ? widget.report.author : (widget.report.circleName.isNotEmpty ? widget.report.circleName : "Circle Leadership")} · ${widget.report.authorRole}',
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
                          fontWeight: FontWeight.w500,
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
            const SizedBox(height: 8),
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
