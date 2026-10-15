import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/report_model.dart';
import 'report_peer_roster_tile.dart';

/// Circle peer roster section for ReportDetailsView.
class ReportDetailsRosterSection extends StatelessWidget {
  final List<ReportPeerRosterItem> peers;
  final String circleName;
  final bool isLoading;

  const ReportDetailsRosterSection({
    super.key,
    required this.peers,
    this.circleName = '',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Peer Roster & Breakdown',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text),
            ),
            const Spacer(),
            Text(
              '(${peers.length} Peers)',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (peers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'No active peer records recorded for this circle.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          )
        else
          ...peers.map((peer) => ReportPeerRosterTile(peer: peer, circleName: circleName)),
      ],
    );
  }
}
