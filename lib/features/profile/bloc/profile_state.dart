import 'package:flutter/material.dart';
import '../model/profile_model.dart';

@immutable
class ProfileState {
  /// True when loading data or signing out.
  final bool isLoading;

  /// Loaded profile model.
  final UserProfileModel? userProfile;

  /// Role-wise leadership milestones and rewards.
  final List<LeaderMilestoneItemModel> milestones;

  /// Whether current leader role is eligible for milestones tracking.
  final bool isApplicableForMilestones;

  /// Total accrued / credited bonuses.
  final String totalEarnedBonuses;

  /// True when signout finishes.
  final bool isSignedOut;

  /// Loading error message if any.
  final String errorMessage;

  const ProfileState({
    this.isLoading = false,
    this.userProfile,
    this.milestones = const [],
    this.isApplicableForMilestones = false,
    this.totalEarnedBonuses = '₹0',
    this.isSignedOut = false,
    this.errorMessage = '',
  });

  /// Helper to copy the state with updated parameters.
  ProfileState copyWith({
    bool? isLoading,
    UserProfileModel? userProfile,
    List<LeaderMilestoneItemModel>? milestones,
    bool? isApplicableForMilestones,
    String? totalEarnedBonuses,
    bool? isSignedOut,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      userProfile: userProfile ?? this.userProfile,
      milestones: milestones ?? this.milestones,
      isApplicableForMilestones:
          isApplicableForMilestones ?? this.isApplicableForMilestones,
      totalEarnedBonuses: totalEarnedBonuses ?? this.totalEarnedBonuses,
      isSignedOut: isSignedOut ?? this.isSignedOut,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
