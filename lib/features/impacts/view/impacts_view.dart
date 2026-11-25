import 'package:flutter/material.dart';
import '../../leader_activities/view/leader_activities_view.dart';

/// Unified Life Impacts entry screen delegating to [LeaderActivitiesView]
/// so Pending / Approved / Rejected moderation and filters stay consistent.
class ImpactsView extends StatelessWidget {
  final String? circleId;

  const ImpactsView({super.key, this.circleId});

  @override
  Widget build(BuildContext context) {
    return LeaderActivitiesView(
      activityType: 'impacts',
      circleId: circleId,
    );
  }
}
