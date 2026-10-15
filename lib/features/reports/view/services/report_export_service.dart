import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/peers_repository.dart';
import '../../../../data/repositories/reports_repository.dart';
import '../../../../data/repositories/teams_repository.dart';
import '../../../peers/model/peer_model.dart';
import '../../model/report_model.dart';

/// Helper service for loading full reports and generating PDF / Excel export files.
class ReportExportService {
  /// Fetches live peers for the report's circle with authentic profile photos.
  static Future<List<ReportPeerRosterItem>> fetchLivePeersForReport(
    ReportModel report, {
    bool force = false,
  }) async {
    if (!force &&
        report.peersRoster.isNotEmpty &&
        report.peersRoster.every((p) => p.avatarUrl != null && p.avatarUrl!.isNotEmpty)) {
      return report.peersRoster;
    }

    try {
      String targetCircleId = report.circleId;
      final circlesRes = await TeamsRepositoryImpl().getCircles();
      if (circlesRes.success && circlesRes.data != null && circlesRes.data!.isNotEmpty) {
        final circles = circlesRes.data!;
        if (targetCircleId.isEmpty || !circles.any((c) => c.id == targetCircleId)) {
          if (report.circleName.isNotEmpty) {
            final matched = circles.firstWhere(
              (c) =>
                  c.name.toLowerCase().trim() == report.circleName.toLowerCase().trim() ||
                  c.id.toLowerCase().trim() == report.circleName.toLowerCase().trim(),
              orElse: () => circles.first,
            );
            targetCircleId = matched.id;
          } else if (circles.isNotEmpty) {
            targetCircleId = circles.first.id;
          }
        }
      }

      List<PeerModel> fetchedPeers = [];
      if (targetCircleId.isNotEmpty) {
        final peersRes = await TeamsRepositoryImpl().getCirclePeers(targetCircleId);
        if (peersRes.success && peersRes.data != null && peersRes.data!.isNotEmpty) {
          fetchedPeers = peersRes.data!;
        }
      }

      // If circle peers endpoint returned empty or failed, fallback to global peers repository
      if (fetchedPeers.isEmpty) {
        final peersRes = await PeersRepositoryImpl().getPeers(
          circleId: targetCircleId.isNotEmpty ? targetCircleId : null,
        );
        if (peersRes.success && peersRes.data != null && peersRes.data!.isNotEmpty) {
          fetchedPeers = peersRes.data!;
        }
      }

      if (fetchedPeers.isNotEmpty) {
        return fetchedPeers.map((p) {
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
    } catch (_) {}

    return report.peersRoster;
  }

  /// Resolves the full report details and ensures live peer roster is attached with avatars.
  static Future<ReportModel> loadFullReport(ReportModel baseReport) async {
    ReportModel active = baseReport;

    if (baseReport.id.isNotEmpty) {
      try {
        final res = await ReportsRepositoryImpl().getReportDetails(baseReport.id);
        if (res.success && res.data != null) {
          active = res.data!;
        }
      } catch (_) {}
    }

    final hasPeers = active.peersRoster.isNotEmpty;
    final hasMissingAvatars = active.peersRoster.any((p) => p.avatarUrl == null || p.avatarUrl!.trim().isEmpty);

    if (!hasPeers || hasMissingAvatars) {
      final livePeers = await fetchLivePeersForReport(active, force: true);
      if (livePeers.isNotEmpty) {
        if (!hasPeers) {
          active = active.copyWith(peersRoster: livePeers);
        } else {
          final liveById = {for (final lp in livePeers) lp.peerId: lp};
          final liveByName = {for (final lp in livePeers) lp.name.trim().toLowerCase(): lp};
          final merged = active.peersRoster.map((p) {
            if (p.avatarUrl != null && p.avatarUrl!.trim().isNotEmpty) {
              return p;
            }
            final match = liveById[p.peerId] ?? liveByName[p.name.trim().toLowerCase()];
            if (match != null && match.avatarUrl != null && match.avatarUrl!.isNotEmpty) {
              return p.copyWith(avatarUrl: match.avatarUrl);
            }
            return p;
          }).toList();
          active = active.copyWith(peersRoster: merged);
        }
      }
    }

    return active;
  }

  /// Downloads or opens the authentic PDF report document.
  static Future<void> downloadPdf(BuildContext context, ReportModel report) async {
    try {
      if (report.id.isNotEmpty) {
        final res = await ReportsRepositoryImpl().getReportDownloadUrl(report.id);
        if (res.success && res.data != null && res.data!.downloadUrl.isNotEmpty) {
          final uri = Uri.tryParse(res.data!.downloadUrl);
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
            if (launched && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening ${res.data!.fileName}...'),
                  backgroundColor: AppColors.success,
                ),
              );
              return;
            }
          }
        }
      }

      List<ReportPeerRosterItem> targetPeers = report.peersRoster;
      if (targetPeers.isEmpty) {
        targetPeers = await fetchLivePeersForReport(report);
      }

      final htmlContent = _generateReportHtml(report, targetPeers);
      final dataUri = Uri.dataFromString(htmlContent, mimeType: 'text/html', encoding: utf8);
      bool launched = false;
      try {
        launched = await launchUrl(dataUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      if (!launched) {
        try {
          launched = await launchUrl(dataUri, mode: LaunchMode.platformDefault);
        } catch (_) {}
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(launched ? 'PDF ready! Use print/save as PDF.' : 'PDF generated.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF download failed: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  /// Exports and opens the Excel / CSV spreadsheet report.
  static Future<void> downloadExcel(BuildContext context, ReportModel report) async {
    try {
      if (report.id.isNotEmpty || report.circleId.isNotEmpty) {
        try {
          final res = await ReportsRepositoryImpl().exportReports(
            format: 'excel',
            circleId: report.circleId.isNotEmpty ? report.circleId : null,
          );
          if (res.success && res.data != null) {
            final downloadUrl = res.data!['download_url']?.toString() ??
                res.data!['url']?.toString() ??
                res.data!['file_url']?.toString() ??
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
                if (launched && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening Excel Sheet download link...'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  return;
                }
              }
            }
          }
        } catch (_) {}
      }

      List<ReportPeerRosterItem> targetPeers = report.peersRoster;
      if (targetPeers.isEmpty) {
        targetPeers = await fetchLivePeersForReport(report);
      }

      final csvContent = _generateCsvData(report, targetPeers);
      final dataUri = Uri.dataFromString('\uFEFF$csvContent', mimeType: 'text/csv', encoding: utf8);
      bool launched = false;
      try {
        launched = await launchUrl(dataUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      if (!launched) {
        try {
          launched = await launchUrl(dataUri, mode: LaunchMode.platformDefault);
        } catch (_) {}
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(launched ? 'Excel sheet opened successfully.' : 'Excel export ready.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel export failed: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  static String _escapeCsv(String val) {
    if (val.contains(',') || val.contains('"') || val.contains('\n') || val.contains('\r')) {
      return '"${val.replaceAll('"', '""')}"';
    }
    return val;
  }

  static String _generateCsvData(ReportModel report, List<ReportPeerRosterItem> peers) {
    final buffer = StringBuffer();
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
    if (report.highlights?.isNotEmpty == true) {
      buffer.writeln('Highlights,${_escapeCsv(report.highlights!.replaceAll("\n", " "))}');
    }
    if (report.challengesFaced?.isNotEmpty == true) {
      buffer.writeln('Challenges,${_escapeCsv(report.challengesFaced!.replaceAll("\n", " "))}');
    }
    if (report.actionItems?.isNotEmpty == true) {
      buffer.writeln('Action Items,${_escapeCsv(report.actionItems!.replaceAll("\n", " "))}');
    }
    buffer.writeln('');
    buffer.writeln('PEER ROSTER & BREAKDOWN');
    buffer.writeln('Peer ID,Name,Company,Designation,Status,Attendance,Deals Closed,P2P Meetings,Referrals Given');

    for (final p in peers) {
      buffer.writeln([
        _escapeCsv(p.peerId),
        _escapeCsv(p.name),
        _escapeCsv(p.company),
        _escapeCsv(p.designation),
        _escapeCsv(p.status),
        _escapeCsv(p.attendance),
        _escapeCsv(p.dealsClosed),
        p.p2pCount.toString(),
        p.referralsCount.toString(),
      ].join(','));
    }
    return buffer.toString();
  }

  static String _generateReportHtml(ReportModel report, List<ReportPeerRosterItem> peers) {
    final title = report.circleName.isNotEmpty ? report.circleName : 'Circle Performance Report';
    final peerRows = peers.map((p) => '''
      <tr>
        <td style="padding: 8px; border-bottom: 1px solid #E2E8F0;">${p.name.isNotEmpty ? p.name : p.company}</td>
        <td style="padding: 8px; border-bottom: 1px solid #E2E8F0;">${p.company}${p.designation.isNotEmpty ? " (${p.designation})" : ""}</td>
        <td style="padding: 8px; border-bottom: 1px solid #E2E8F0;">${p.status}</td>
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
  <title>$title</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 32px; color: #1E293B; }
    h1 { font-size: 20px; color: #0F172A; margin-bottom: 4px; }
    .meta { font-size: 13px; color: #64748B; margin-bottom: 20px; }
    .grid { display: flex; gap: 12px; margin-bottom: 24px; }
    .card { flex: 1; padding: 12px; border-radius: 8px; border: 1px solid #E2E8F0; background: #F8FAFC; }
    .card-label { font-size: 11px; color: #64748B; text-transform: uppercase; font-weight: 500; }
    .card-val { font-size: 16px; font-weight: 500; color: #0F172A; margin-top: 4px; }
    .section-title { font-size: 14px; font-weight: 500; margin-top: 20px; margin-bottom: 8px; }
    .box { padding: 12px; background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 8px; font-size: 13px; line-height: 1.5; }
    table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 12px; }
    th { text-align: left; padding: 8px; background: #F1F5F9; font-weight: 500; color: #475569; }
    @media print { body { margin: 0; } }
  </style>
</head>
<body>
  <h1>$title</h1>
  <div class="meta">Period: ${report.period ?? report.date} &bull; Type: ${report.type} &bull; Status: ${report.status} &bull; Author: ${report.author} (${report.authorRole})</div>
  <div class="grid">
    <div class="card"><div class="card-label">Attendance</div><div class="card-val">${report.formattedAttendance}</div></div>
    <div class="card"><div class="card-label">Deals Closed</div><div class="card-val">${report.dealsClosedValue ?? "-"}</div></div>
    <div class="card"><div class="card-label">Revenue</div><div class="card-val">${report.totalRevenue ?? "-"}</div></div>
  </div>
  <div class="section-title">Executive Summary</div>
  <div class="box">${report.content.isNotEmpty ? report.content : "No executive summary notes provided."}</div>
  ${report.highlights?.isNotEmpty == true ? '<div class="section-title">Key Highlights</div><div class="box">${report.highlights!}</div>' : ''}
  ${report.challengesFaced?.isNotEmpty == true ? '<div class="section-title">Challenges Faced</div><div class="box">${report.challengesFaced!}</div>' : ''}
  ${report.actionItems?.isNotEmpty == true ? '<div class="section-title">Action Items & Next Steps</div><div class="box">${report.actionItems!}</div>' : ''}
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
}
