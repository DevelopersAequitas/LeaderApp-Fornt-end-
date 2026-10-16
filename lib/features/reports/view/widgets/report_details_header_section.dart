import 'package:flutter/material.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../model/report_model.dart';

/// Header section for ReportDetailsView displaying circle name, period, status, and author.
class ReportDetailsHeaderSection extends StatelessWidget {
  final ReportModel report;

  const ReportDetailsHeaderSection({super.key, required this.report});

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

  String? _resolveAuthorAvatar() {
    if (report.authorAvatarUrl != null && report.authorAvatarUrl!.trim().isNotEmpty) {
      return report.authorAvatarUrl!.trim();
    }
    // Check if the author is the currently logged-in user
    final session = SessionManager().currentSession;
    if (session.name.isNotEmpty &&
        report.author.toLowerCase().contains(session.name.toLowerCase())) {
      final userAv = session.avatarUrl ?? session.profilePhotoUrl;
      if (userAv != null && userAv.isNotEmpty) return userAv;
    }
    // Check if any peer in roster matches the author
    for (final p in report.peersRoster) {
      if (p.name.trim().toLowerCase() == report.author.trim().toLowerCase() ||
          report.author.trim().toLowerCase().contains(p.name.trim().toLowerCase())) {
        if (p.avatarUrl != null && p.avatarUrl!.isNotEmpty) {
          return p.avatarUrl;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authorAvatar = _resolveAuthorAvatar();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.circleName.isNotEmpty ? report.circleName : 'Circle Performance Report',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Period: ${report.period ?? report.date} · ${report.type}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (report.status.isNotEmpty &&
                  report.status.trim().toLowerCase().replaceAll(' ', '') != 'underreview') ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusBg(report.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    report.status,
                    style: TextStyle(
                      color: _getStatusText(report.status),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              InitialsAvatar(
                name: report.author.isNotEmpty ? report.author : 'Circle Leadership',
                imageUrl: authorAvatar,
                radius: 18,
                backgroundColor: AppColors.primary,
                fontSize: 12,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.author.isNotEmpty ? report.author : 'Circle Leadership',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      report.authorRole.isNotEmpty ? report.authorRole : 'Submitted by Leadership',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (report.peersRoster.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  height: 28,
                  width: (report.peersRoster.take(4).length * 18.0) + 16,
                  child: Stack(
                    children: [
                      for (int i = 0; i < report.peersRoster.take(4).length; i++)
                        Positioned(
                          left: i * 18.0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: InitialsAvatar(
                              name: report.peersRoster[i].name,
                              imageUrl: report.peersRoster[i].avatarUrl,
                              radius: 12,
                              fontSize: 8.5,
                              backgroundColor: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${report.peersRoster.length} Peers in this report',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
