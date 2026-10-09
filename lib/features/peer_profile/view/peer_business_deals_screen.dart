import 'package:flutter/material.dart';
import '../../member_activities/view/business_deals_view.dart';
import '../../peers/model/peer_model.dart';
import '../model/peer_profile_model.dart';

/// Full-screen display showing Business Deals (Given vs Received) for a peer directly from API.
class PeerBusinessDealsScreen extends StatelessWidget {
  final PeerModel peer;
  final PeerProfileDetailModel details;

  const PeerBusinessDealsScreen({
    super.key,
    required this.peer,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return BusinessDealsView(
      memberId: peer.id,
      memberName: peer.name,
    );
  }
}
