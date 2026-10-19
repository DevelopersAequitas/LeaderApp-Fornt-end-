import 'package:flutter/material.dart';
import '../../peers/model/peer_model.dart';

@immutable
abstract class PeerProfileEvent {
  const PeerProfileEvent();
}

/// Triggers loading of profile details for a given peer model.
class LoadPeerProfile extends PeerProfileEvent {
  final PeerModel peer;
  const LoadPeerProfile(this.peer);
}

/// Dispatched to toggle overview / activity / testimonials subtabs.
class ChangeProfileSubTab extends PeerProfileEvent {
  final int index;
  const ChangeProfileSubTab(this.index);
}

/// Dispatched to delete a member post.
class DeletePeerPost extends PeerProfileEvent {
  final String memberId;
  final String postId;

  const DeletePeerPost({
    required this.memberId,
    required this.postId,
  });
}

/// Dispatched to delete a member creative.
class DeletePeerCreative extends PeerProfileEvent {
  final String memberId;
  final String creativeId;

  const DeletePeerCreative({
    required this.memberId,
    required this.creativeId,
  });
}

