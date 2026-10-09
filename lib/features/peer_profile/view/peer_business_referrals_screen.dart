import 'package:flutter/material.dart';
import '../../member_activities/view/business_referrals_view.dart';
import '../../peers/model/peer_model.dart';
import '../model/peer_profile_model.dart';

/// Full-screen display showing Business Referrals (Given vs Received) for a peer directly from API.
class PeerBusinessReferralsScreen extends StatelessWidget {
  final PeerModel peer;
  final PeerProfileDetailModel details;

  const PeerBusinessReferralsScreen({
    super.key,
    required this.peer,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return BusinessReferralsView(
      memberId: peer.id,
      memberName: peer.name,
    );
  }
}
