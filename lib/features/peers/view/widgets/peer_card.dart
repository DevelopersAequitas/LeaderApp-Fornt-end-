import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/peer_model.dart';

/// Renders a Material 3 compliant peer tile with dynamic metrics and status tags.
class PeerCard extends StatelessWidget {
  final PeerModel peer;
  final String selectedSort;

  const PeerCard({
    super.key,
    required this.peer,
    required this.selectedSort,
  });

  @override
  Widget build(BuildContext context) {
    String badgeText = '';
    Color badgeColor = AppColors.infoBg;
    Color badgeTextColor = AppColors.primary;

    if (selectedSort == 'Impact') {
      badgeText = '${peer.impactCount} lives';
      badgeColor = AppColors.successBg;
      badgeTextColor = AppColors.success;
    } else if (selectedSort == 'Deals') {
      badgeText = peer.dealsFormatted;
      badgeColor = AppColors.warningBg;
      badgeTextColor = AppColors.warning;
    } else if (selectedSort == 'Coins') {
      badgeText = '${peer.coins} coins';
      badgeColor = AppColors.coinBg;
      badgeTextColor = AppColors.coinColor;
    } else if (selectedSort == 'Attendance') {
      badgeText = '${peer.attendance} attendance';
      badgeColor = AppColors.attendanceBg;
      badgeTextColor = AppColors.attendanceColor;
    } else if (peer.impactCount > 0) {
      badgeText = '${peer.impactCount} lives';
      badgeColor = AppColors.successBg;
      badgeTextColor = AppColors.success;
    }

    Color statusBg = AppColors.successBg;
    Color statusText = AppColors.success;
    final normStatus = peer.status.toLowerCase();
    if (normStatus.contains('risk')) {
      statusBg = AppColors.dangerBg;
      statusText = AppColors.danger;
    } else if (normStatus.contains('attention') ||
        normStatus.contains('pending')) {
      statusBg = AppColors.warningBg;
      statusText = AppColors.warning;
    }

    final companyDesignation = [
      if (peer.designation != null && peer.designation!.isNotEmpty)
        peer.designation!,
      if (peer.company.isNotEmpty) peer.company,
    ].join(' · ');

    final industryCity = [
      if (peer.industry != null && peer.industry!.isNotEmpty)
        peer.industry!
      else if (peer.tags.isNotEmpty)
        peer.tags,
      if (peer.location.isNotEmpty) peer.location,
    ].join(' · ');

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.peerProfile, arguments: peer);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InitialsAvatar(
              name: peer.name,
              radius: 20,
              backgroundColor: normStatus.contains('risk')
                  ? AppColors.danger
                  : const Color(0xFF1E3C72),
              fontSize: 12,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          peer.name,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (badgeText.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeTextColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      if (peer.status.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            peer.status,
                            style: TextStyle(
                              color: statusText,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (companyDesignation.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      companyDesignation,
                      style: const TextStyle(
                        color: Color(0xFF1E3C72),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (industryCity.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      industryCity,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
