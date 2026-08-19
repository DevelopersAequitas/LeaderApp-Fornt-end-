import 'package:flutter/material.dart';
import '../../peers/model/peer_model.dart';
import '../model/peer_profile_model.dart';

@immutable
class PeerProfileState {
  final bool isLoading;
  final PeerModel? peer;
  final PeerProfileDetailModel? details;
  final int activeSubTab; // 0: Overview, 1: Activity, 2: Testimonials
  final String errorMessage;

  const PeerProfileState({
    this.isLoading = false,
    this.peer,
    this.details,
    this.activeSubTab = 0,
    this.errorMessage = '',
  });

  PeerProfileState copyWith({
    bool? isLoading,
    PeerModel? peer,
    PeerProfileDetailModel? details,
    int? activeSubTab,
    String? errorMessage,
  }) {
    return PeerProfileState(
      isLoading: isLoading ?? this.isLoading,
      peer: peer ?? this.peer,
      details: details ?? this.details,
      activeSubTab: activeSubTab ?? this.activeSubTab,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
