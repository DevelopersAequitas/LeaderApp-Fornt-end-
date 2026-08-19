import 'package:flutter/material.dart';
import '../model/referral_model.dart';

@immutable
class ReferralsState {
  final bool isLoading;
  final List<ReferralModel> allReferrals;
  final List<ReferralModel> filteredReferrals;
  final String selectedFilter; // 'All', 'Active', 'At Risk'
  final String errorMessage;

  const ReferralsState({
    this.isLoading = false,
    this.allReferrals = const [],
    this.filteredReferrals = const [],
    this.selectedFilter = 'All',
    this.errorMessage = '',
  });

  ReferralsState copyWith({
    bool? isLoading,
    List<ReferralModel>? allReferrals,
    List<ReferralModel>? filteredReferrals,
    String? selectedFilter,
    String? errorMessage,
  }) {
    return ReferralsState(
      isLoading: isLoading ?? this.isLoading,
      allReferrals: allReferrals ?? this.allReferrals,
      filteredReferrals: filteredReferrals ?? this.filteredReferrals,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
