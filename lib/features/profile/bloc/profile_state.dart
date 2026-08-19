import 'package:flutter/material.dart';
import '../model/profile_model.dart';

@immutable
class ProfileState {
  /// True when loading data or signing out.
  final bool isLoading;

  /// Loaded profile model.
  final UserProfileModel? userProfile;

  /// True when signout finishes.
  final bool isSignedOut;

  /// Loading error message if any.
  final String errorMessage;

  const ProfileState({
    this.isLoading = false,
    this.userProfile,
    this.isSignedOut = false,
    this.errorMessage = '',
  });

  /// Helper to copy the state with updated parameters.
  ProfileState copyWith({
    bool? isLoading,
    UserProfileModel? userProfile,
    bool? isSignedOut,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      userProfile: userProfile ?? this.userProfile,
      isSignedOut: isSignedOut ?? this.isSignedOut,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
