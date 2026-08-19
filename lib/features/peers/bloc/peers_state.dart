import 'package:flutter/material.dart';
import '../model/peer_model.dart';
import '../model/celebration_model.dart';

@immutable
class PeersState {
  final bool isLoading;
  final List<PeerModel> allPeers;
  final List<PeerModel> filteredPeers;
  final List<CelebrationModel> birthdays;
  final List<CelebrationModel> anniversaries;
  final int activeSubTab; // 0: Peers segment, 1: Celebrations segment
  final String searchQuery;
  final String selectedStatus; // "All", "Active", "At Risk"
  final String selectedSort; // "Impact", "Deals", "Coins", "Attendance"
  final String errorMessage;
  final String? selectedCircle;

  const PeersState({
    this.isLoading = false,
    this.allPeers = const [],
    this.filteredPeers = const [],
    this.birthdays = const [],
    this.anniversaries = const [],
    this.activeSubTab = 0,
    this.searchQuery = '',
    this.selectedStatus = 'All',
    this.selectedSort = 'Impact',
    this.errorMessage = '',
    this.selectedCircle,
  });

  /// Helper to copy the state with updated parameters.
  PeersState copyWith({
    bool? isLoading,
    List<PeerModel>? allPeers,
    List<PeerModel>? filteredPeers,
    List<CelebrationModel>? birthdays,
    List<CelebrationModel>? anniversaries,
    int? activeSubTab,
    String? searchQuery,
    String? selectedStatus,
    String? selectedSort,
    String? errorMessage,
    String? selectedCircle,
  }) {
    return PeersState(
      isLoading: isLoading ?? this.isLoading,
      allPeers: allPeers ?? this.allPeers,
      filteredPeers: filteredPeers ?? this.filteredPeers,
      birthdays: birthdays ?? this.birthdays,
      anniversaries: anniversaries ?? this.anniversaries,
      activeSubTab: activeSubTab ?? this.activeSubTab,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedSort: selectedSort ?? this.selectedSort,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCircle: selectedCircle ?? this.selectedCircle,
    );
  }
}
