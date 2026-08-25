import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../peers/model/peer_model.dart';
import '../../../peers/view/widgets/peer_card.dart';

/// Renders the unified shared PeerCard list for Circle Details.
class CirclePeersSection extends StatelessWidget {
  final List<PeerModel> peers;
  final bool isLoading;

  const CirclePeersSection({
    super.key,
    required this.peers,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (peers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline_rounded,
                size: 40,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 8),
              const Text(
                'No peers enrolled in this circle yet.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: peers
          .map(
            (peer) => PeerCard(
              peer: peer,
              selectedSort: 'Impact',
            ),
          )
          .toList(),
    );
  }
}
