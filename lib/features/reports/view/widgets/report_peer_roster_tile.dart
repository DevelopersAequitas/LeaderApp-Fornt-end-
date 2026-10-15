import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../model/report_model.dart';

/// Single peer item tile conforming to standard peer profile display pattern.
class ReportPeerRosterTile extends StatelessWidget {
  final ReportPeerRosterItem peer;
  final String circleName;

  const ReportPeerRosterTile({super.key, required this.peer, this.circleName = ''});

  Widget _metric(String label, String value) {
    return Text.rich(TextSpan(
      text: '$label: ',
      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      children: [
        TextSpan(text: value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.text)),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final des = peer.designation.trim();
    final comp = peer.company.trim();
    final subtitle = des.isNotEmpty && comp.isNotEmpty ? '$des · $comp' : (des.isNotEmpty ? des : comp);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.peerProfile, arguments: peer.toPeerModel(circleName)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InitialsAvatar(
                      name: peer.name.toUpperCase(),
                      imageUrl: peer.avatarUrl,
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      fontSize: 12,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            peer.name.toUpperCase(),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle.isNotEmpty)
                            Text(
                              subtitle,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (peer.status.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          peer.status,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metric('Att', peer.attendance.isNotEmpty ? peer.attendance : '-'),
                    _metric('Deals', peer.dealsClosed.isNotEmpty ? peer.dealsClosed : '-'),
                    _metric('P2P', '${peer.p2pCount}'),
                    _metric('Ref', '${peer.referralsCount}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
