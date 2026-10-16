import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/peers_repository.dart';
import '../../../../data/repositories/reports_repository.dart';
import '../../../../data/repositories/teams_repository.dart';
import '../../../peers/model/peer_model.dart';
import '../../model/report_model.dart';

/// Native platform bridge for saving files directly into the user's Downloads folder
/// and launching Android intents (Open with Excel/Sheets/Chrome or Share) without data URI issues.
class NativeFileExportHelper {
  static const MethodChannel _channel = MethodChannel('com.unity.leadersapp/file_export');

  /// Saves bytes directly to the Android public Downloads directory (/storage/emulated/0/Download).
  static Future<String?> saveFileToDownloads({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
  }) async {
    if (!Platform.isAndroid) return null;
    try {
      final res = await _channel.invokeMethod<String>('saveFileToDownloads', {
        'fileName': fileName,
        'bytes': Uint8List.fromList(bytes),
        'mimeType': mimeType,
      });
      return res;
    } catch (_) {
      return null;
    }
  }

  /// Opens the file with native app chooser (Google Sheets, Microsoft Excel, Chrome, etc.).
  static Future<bool> openFile({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
  }) async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('openFile', {
        'fileName': fileName,
        'bytes': Uint8List.fromList(bytes),
        'mimeType': mimeType,
      });
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens native share sheet for the file.
  static Future<bool> shareFile({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
  }) async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('shareFile', {
        'fileName': fileName,
        'bytes': Uint8List.fromList(bytes),
        'mimeType': mimeType,
      });
      return res ?? false;
    } catch (_) {
      return false;
    }
  }
}

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
        return fetchedPeers
            .where((p) => !ReportModel.isDummyPeer(p.name, p.id))
            .map((p) {
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

    return report.peersRoster
        .where((p) => !ReportModel.isDummyPeer(p.name, p.peerId))
        .toList();
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

    // Cleanse any dummy peer records (e.g. Siddharth Verma, Pooja Sharma)
    final cleanRoster = active.peersRoster
        .where((p) => !ReportModel.isDummyPeer(p.name, p.peerId))
        .toList();
    if (cleanRoster.length != active.peersRoster.length) {
      active = active.copyWith(peersRoster: cleanRoster);
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

  /// Downloads or opens the authentic PDF report document with an explicit download / save-as-PDF action.
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
            if (launched && context.mounted) {
              _showPdfNoticeBottomSheet(
                context: context,
                report: report,
                url: res.data!.downloadUrl,
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
      final htmlBytes = utf8.encode(htmlContent);
      final safeCircle = (report.circleName.isNotEmpty ? report.circleName : 'circle')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final fileName = '${safeCircle}_report_${DateTime.now().millisecondsSinceEpoch}.html';

      // 1. Save HTML to Downloads folder
      final savedLocation = await NativeFileExportHelper.saveFileToDownloads(
        fileName: fileName,
        bytes: htmlBytes,
        mimeType: 'text/html',
      );

      // 2. Open HTML in browser via FileProvider (safe on Android)
      await NativeFileExportHelper.openFile(
        fileName: fileName,
        bytes: htmlBytes,
        mimeType: 'text/html',
      );

      if (context.mounted) {
        _showPdfNoticeBottomSheet(
          context: context,
          report: report,
          fileName: fileName,
          htmlBytes: htmlBytes,
          savedLocation: savedLocation,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF generation failed: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  /// Exports report into a real CSV file and downloads it to the device with an interactive confirmation sheet.
  static Future<void> downloadExcel(BuildContext context, ReportModel report) async {
    try {
      List<ReportPeerRosterItem> targetPeers = report.peersRoster;
      if (targetPeers.isEmpty) {
        targetPeers = await fetchLivePeersForReport(report);
      }

      final csvContent = _generateCsvData(report, targetPeers);
      final csvBytes = utf8.encode('\uFEFF$csvContent');
      final safeCircle = (report.circleName.isNotEmpty ? report.circleName : 'circle')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final fileName = '${safeCircle}_performance_report_${DateTime.now().millisecondsSinceEpoch}.csv';

      // 1. Physically save the .csv file directly to the device's Downloads directory
      String? savedLocation = await NativeFileExportHelper.saveFileToDownloads(
        fileName: fileName,
        bytes: csvBytes,
        mimeType: 'text/csv',
      );

      // Fallback: write to local storage
      if (savedLocation == null) {
        final savedFile = await _saveFileToDevice(
          fileName: fileName,
          content: '\uFEFF$csvContent',
        );
        savedLocation = savedFile?.path;
      }

      // 2. Open interactive BottomSheet dialog with Open in Excel and Share options
      if (context.mounted) {
        _showExportSuccessBottomSheet(
          context: context,
          report: report,
          fileName: fileName,
          csvBytes: csvBytes,
          peerCount: targetPeers.length,
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

  /// Writes file directly to device storage (/storage/emulated/0/Download on Android or system temp).
  static Future<File?> _saveFileToDevice({
    required String fileName,
    required String content,
  }) async {
    try {
      final List<Directory> candidates = [];
      if (Platform.isAndroid) {
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (downloadDir.existsSync()) {
          candidates.add(downloadDir);
        }
      }
      candidates.add(Directory.systemTemp);

      for (final dir in candidates) {
        try {
          final file = File('${dir.path}/$fileName');
          await file.writeAsString(content, flush: true);
          return file;
        } catch (_) {}
      }
    } catch (_) {}
    return null;
  }

  /// Displays an interactive modal bottom sheet with Open in Excel / Sheets and Share options.
  static void _showExportSuccessBottomSheet({
    required BuildContext context,
    required ReportModel report,
    required String fileName,
    required List<int> csvBytes,
    required int peerCount,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Icon(
                        Icons.table_chart_rounded,
                        color: Color(0xFF16A34A),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Excel / CSV Export',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            report.circleName.isNotEmpty
                                ? report.circleName
                                : 'Circle Performance Report',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.analytics_outlined, size: 18, color: Color(0xFF16A34A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$peerCount Peers Included • Attendance: ${report.formattedAttendance}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    NativeFileExportHelper.openFile(
                      fileName: fileName,
                      bytes: csvBytes,
                      mimeType: 'text/csv',
                    );
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Open in Excel / Google Sheets'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    NativeFileExportHelper.shareFile(
                      fileName: fileName,
                      bytes: csvBytes,
                      mimeType: 'text/csv',
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('Share File (WhatsApp, Email, Drive)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Displays notice when opening PDF in browser with instructions.
  static void _showPdfNoticeBottomSheet({
    required BuildContext context,
    required ReportModel report,
    String? url,
    String? fileName,
    List<int>? htmlBytes,
    String? savedLocation,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PDF Report Opened in Browser',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            report.circleName.isNotEmpty ? report.circleName : 'Circle Performance Report',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, size: 20, color: AppColors.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'In your browser, tap "📥 Download as PDF / Print" or select "Save as PDF" to download the document.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF334155),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (fileName != null && htmlBytes != null) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      NativeFileExportHelper.openFile(
                        fileName: fileName,
                        bytes: htmlBytes,
                        mimeType: 'text/html',
                      );
                    },
                    icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                    label: const Text('Open Again in Browser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      NativeFileExportHelper.shareFile(
                        fileName: fileName,
                        bytes: htmlBytes,
                        mimeType: 'text/html',
                      );
                    },
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Share Report HTML'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @visibleForTesting
  static String generateCsvData(ReportModel report, List<ReportPeerRosterItem> peers) {
    return _generateCsvData(report, peers);
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
    final csvContent = _generateCsvData(report, peers);
    final base64Csv = base64Encode(utf8.encode('\uFEFF$csvContent'));
    final safeFileName = '${(report.circleName.isNotEmpty ? report.circleName : "report").replaceAll(RegExp(r"[^a-zA-Z0-9_\-]"), "_")}.csv';

    final peerRows = peers.map((p) => '''
      <tr>
        <td style="padding: 10px 12px; border-bottom: 1px solid #E2E8F0; font-weight: 500;">${p.name.isNotEmpty ? p.name : p.company}</td>
        <td style="padding: 10px 12px; border-bottom: 1px solid #E2E8F0; color: #475569;">${p.company}${p.designation.isNotEmpty ? " &bull; ${p.designation}" : ""}</td>
        <td style="padding: 10px 12px; border-bottom: 1px solid #E2E8F0;"><span style="display:inline-block; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 500; background: #F1F5F9; color: #334155;">${p.status}</span></td>
        <td style="padding: 10px 12px; border-bottom: 1px solid #E2E8F0; text-align: center; font-weight: 600;">${p.attendance}</td>
        <td style="padding: 10px 12px; border-bottom: 1px solid #E2E8F0; text-align: right; font-weight: 600; color: #16A34A;">${p.dealsClosed}</td>
        <td style="padding: 10px 12px; border-bottom: 1px solid #E2E8F0; text-align: center;">${p.p2pCount}</td>
        <td style="padding: 10px 12px; border-bottom: 1px solid #E2E8F0; text-align: center;">${p.referralsCount}</td>
      </tr>
    ''').join('');

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      margin: 0;
      padding: 0 0 40px 0;
      color: #1E293B;
      background: #FFFFFF;
    }
    .action-banner {
      background: #0F172A;
      color: #FFFFFF;
      padding: 12px 20px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      position: sticky;
      top: 0;
      z-index: 100;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    .action-title {
      font-size: 14px;
      font-weight: 600;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .action-buttons {
      display: flex;
      gap: 8px;
    }
    .btn {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 8px 14px;
      font-size: 13px;
      font-weight: 600;
      border-radius: 6px;
      border: none;
      cursor: pointer;
      text-decoration: none;
      white-space: nowrap;
      transition: background 0.2s, transform 0.1s;
    }
    .btn-pdf {
      background: #2563EB;
      color: #FFFFFF;
    }
    .btn-pdf:hover {
      background: #1D4ED8;
    }
    .btn-csv {
      background: #16A34A;
      color: #FFFFFF;
    }
    .btn-csv:hover {
      background: #15803D;
    }
    .content-wrap {
      max-width: 900px;
      margin: 0 auto;
      padding: 24px 20px;
    }
    h1 {
      font-size: 22px;
      color: #0F172A;
      margin: 0 0 6px 0;
    }
    .meta {
      font-size: 13px;
      color: #64748B;
      margin-bottom: 24px;
      line-height: 1.5;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 12px;
      margin-bottom: 24px;
    }
    .card {
      padding: 14px 16px;
      border-radius: 8px;
      border: 1px solid #E2E8F0;
      background: #F8FAFC;
    }
    .card-label {
      font-size: 11px;
      color: #64748B;
      text-transform: uppercase;
      font-weight: 600;
      letter-spacing: 0.5px;
    }
    .card-val {
      font-size: 18px;
      font-weight: 700;
      color: #0F172A;
      margin-top: 4px;
    }
    .section-title {
      font-size: 15px;
      font-weight: 600;
      color: #0F172A;
      margin-top: 24px;
      margin-bottom: 10px;
    }
    .box {
      padding: 14px 16px;
      background: #F8FAFC;
      border: 1px solid #E2E8F0;
      border-radius: 8px;
      font-size: 13px;
      line-height: 1.6;
      color: #334155;
    }
    .table-container {
      width: 100%;
      overflow-x: auto;
      border: 1px solid #E2E8F0;
      border-radius: 8px;
      margin-top: 10px;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 12px;
      min-width: 600px;
    }
    th {
      text-align: left;
      padding: 10px 12px;
      background: #F1F5F9;
      font-weight: 600;
      color: #475569;
      border-bottom: 1px solid #E2E8F0;
    }
    @media (max-width: 600px) {
      .grid { grid-template-columns: 1fr; }
      .action-banner { flex-direction: column; align-items: stretch; }
      .action-buttons { width: 100%; }
      .btn { flex: 1; justify-content: center; }
    }
    @media print {
      .no-print { display: none !important; }
      body { margin: 0; padding: 12px; }
      .card { border: 1px solid #CBD5E1; }
      .table-container { border: none; overflow: visible; }
      table { min-width: 100%; }
    }
  </style>
</head>
<body>
  <div class="action-banner no-print">
    <div class="action-title">$title</div>
    <div class="action-buttons">
      <button onclick="window.print()" class="btn btn-pdf">📥 Download as PDF / Print</button>
      <button onclick="downloadCsv()" class="btn btn-csv">📊 Download CSV (Excel)</button>
    </div>
  </div>

  <div class="content-wrap">
    <h1>$title</h1>
    <div class="meta">
      Period: <strong>${report.period ?? report.date}</strong> &bull; Type: <strong>${report.type}</strong> &bull; Status: <strong>${report.status}</strong><br>
      Submitted By: <strong>${report.author}</strong> (${report.authorRole})
    </div>

    <div class="grid">
      <div class="card">
        <div class="card-label">Attendance</div>
        <div class="card-val">${report.formattedAttendance}</div>
      </div>
      <div class="card">
        <div class="card-label">Deals Closed</div>
        <div class="card-val">${report.dealsClosedValue ?? "-"}</div>
      </div>
      <div class="card">
        <div class="card-label">Revenue Generated</div>
        <div class="card-val">${report.totalRevenue ?? "-"}</div>
      </div>
    </div>

    <div class="section-title">Executive Summary</div>
    <div class="box">${report.content.isNotEmpty ? report.content : "No executive summary notes provided."}</div>

    ${report.highlights?.isNotEmpty == true ? '<div class="section-title">Key Highlights</div><div class="box">${report.highlights!}</div>' : ''}
    ${report.challengesFaced?.isNotEmpty == true ? '<div class="section-title">Challenges Faced</div><div class="box">${report.challengesFaced!}</div>' : ''}
    ${report.actionItems?.isNotEmpty == true ? '<div class="section-title">Action Items & Next Steps</div><div class="box">${report.actionItems!}</div>' : ''}

    <div class="section-title">Peer Roster & Individual Contributions (${peers.length} Peers)</div>
    <div class="table-container">
      <table>
        <thead>
          <tr>
            <th>Peer Name</th>
            <th>Company & Role</th>
            <th>Status</th>
            <th style="text-align:center;">Attendance</th>
            <th style="text-align:right;">Deals Closed</th>
            <th style="text-align:center;">P2P</th>
            <th style="text-align:center;">Referrals</th>
          </tr>
        </thead>
        <tbody>
          ${peerRows.isNotEmpty ? peerRows : '<tr><td colspan="7" style="padding:16px; text-align:center; color:#94A3B8;">No circle peers recorded.</td></tr>'}
        </tbody>
      </table>
    </div>
  </div>

  <script>
    function downloadCsv() {
      try {
        const raw = atob("$base64Csv");
        const bytes = new Uint8Array(raw.length);
        for (let i = 0; i < raw.length; i++) {
          bytes[i] = raw.charCodeAt(i);
        }
        const blob = new Blob([bytes], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = "$safeFileName";
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        setTimeout(() => URL.revokeObjectURL(url), 1000);
      } catch (err) {
        alert("Failed to download CSV: " + err);
      }
    }
  </script>
</body>
</html>
''';
  }
}
