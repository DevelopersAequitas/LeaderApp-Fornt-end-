import 'package:flutter/material.dart';
import '../../member_activities/view/coins_view.dart';
import '../../peers/model/peer_model.dart';
import '../model/peer_profile_model.dart';

/// Full-screen display showing Coins Activity History for a peer directly from API.
class PeerCoinsScreen extends StatelessWidget {
  final PeerModel peer;
  final PeerProfileDetailModel details;

  const PeerCoinsScreen({
    super.key,
    required this.peer,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return CoinsView(
      memberId: peer.id,
      memberName: peer.name,
      coinBalance: details.coinsEarned,
    );
  }
}
