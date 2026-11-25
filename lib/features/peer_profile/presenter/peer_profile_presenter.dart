import 'package:flutter/material.dart';
import '../../peers/model/peer_model.dart';
import '../bloc/peer_profile_bloc.dart';
import '../bloc/peer_profile_event.dart';
import '../bloc/peer_profile_state.dart';
import '../model/peer_profile_model.dart';

/// Top-level navigable sections on the Founder-Level Peer Profile.
enum PeerProfileSection {
  overview('Overview', Icons.dashboard_outlined),
  business('Business', Icons.business_center_outlined),
  organization('Organization', Icons.account_tree_outlined),
  leadership('Leadership', Icons.workspace_premium_outlined),
  collaborations('Collaborations', Icons.handshake_outlined),
  lifeImpact('Life Impact', Icons.volunteer_activism_outlined),
  performance('Performance', Icons.insights_outlined),
  activity('Activity', Icons.timeline_rounded);

  final String label;
  final IconData icon;

  const PeerProfileSection(this.label, this.icon);
}

/// Contract interface defining Peer Profile view actions.
abstract class PeerProfileViewContract {
  void onProfileLoading();
  void onProfileLoaded();
  void onProfileError(String error);
  void onSubTabChanged(int index);
}

/// Presenter coordinating section visibility, permissions & transitions for Peer Profile.
class PeerProfilePresenter {
  final PeerProfileViewContract? view;
  final PeerProfileBloc? bloc;

  const PeerProfilePresenter({this.view, this.bloc});

  /// Returns only sections that contain genuine backend data for [peer] & [details].
  static List<PeerProfileSection> resolveVisibleSections(
    PeerModel peer,
    PeerProfileDetailModel? details,
  ) {
    final sections = <PeerProfileSection>[PeerProfileSection.overview];
    if (details == null) return sections;

    if (details.business?.hasAnyData == true ||
        details.bio.isNotEmpty ||
        details.tags.isNotEmpty ||
        peer.company.trim().isNotEmpty) {
      sections.add(PeerProfileSection.business);
    }

    if (details.organization?.hasAnyData == true ||
        peer.circle.trim().isNotEmpty) {
      sections.add(PeerProfileSection.organization);
    }

    if (details.leadership?.hasAnyData == true) {
      sections.add(PeerProfileSection.leadership);
    }

    if (details.collaborationsInfo?.hasAnyData == true ||
        details.referralsGiven > 0 ||
        details.referralsReceived > 0 ||
        details.collaborationsCount > 0) {
      sections.add(PeerProfileSection.collaborations);
    }

    if (details.lifeImpact?.hasAnyData == true ||
        details.impactCount > 0 ||
        peer.impactCount > 0) {
      sections.add(PeerProfileSection.lifeImpact);
    }

    if (details.performance?.hasAnyData == true ||
        details.p2pSessions > 0 ||
        details.testimonials.isNotEmpty ||
        details.posts.isNotEmpty) {
      sections.add(PeerProfileSection.performance);
    }

    if (details.timeline.isNotEmpty || details.activities.isNotEmpty) {
      sections.add(PeerProfileSection.activity);
    }

    return sections;
  }

  /// Checks whether contact shortcuts may be shown without leaking masked fields.
  static bool canShowContactActions(
    PeerModel peer,
    PeerProfileDetailModel? details, {
    required bool hasPermission,
  }) {
    if (!hasPermission) return false;
    final idModel = details?.identity;
    if (idModel != null && !idModel.contactAuthorized) return false;
    final phone = (idModel?.phone ?? details?.phone ?? peer.phone ?? '').trim();
    final email = (idModel?.email ?? details?.email ?? peer.email ?? '').trim();
    final hasUnmaskedPhone = phone.isNotEmpty && !phone.contains('***');
    final hasUnmaskedEmail = email.isNotEmpty && !email.contains('***');
    return hasUnmaskedPhone || hasUnmaskedEmail;
  }

  void load(PeerModel peer) {
    bloc?.add(LoadPeerProfile(peer));
  }

  void changeSubTab(int index) {
    bloc?.add(ChangeProfileSubTab(index));
  }

  void deletePost(String memberId, String postId) {
    bloc?.add(DeletePeerPost(memberId: memberId, postId: postId));
  }

  void deleteCreative(String memberId, String creativeId) {
    bloc?.add(DeletePeerCreative(memberId: memberId, creativeId: creativeId));
  }

  void handleStateChange(PeerProfileState state) {
    view?.onSubTabChanged(state.activeSubTab);

    if (state.isLoading) {
      view?.onProfileLoading();
    } else {
      view?.onProfileLoaded();
    }

    if (state.errorMessage.isNotEmpty) {
      view?.onProfileError(state.errorMessage);
    }
  }
}
