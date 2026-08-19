import 'package:flutter/material.dart';
import '../model/coin_balance_model.dart';

@immutable
class PeersByCoinsState {
  final bool isLoading;
  final List<CoinBalanceModel> allPeers;
  final List<CoinBalanceModel> filteredPeers;
  final String selectedFilter; // 'All', 'Active', 'At Risk'
  final String errorMessage;

  const PeersByCoinsState({
    this.isLoading = false,
    this.allPeers = const [],
    this.filteredPeers = const [],
    this.selectedFilter = 'All',
    this.errorMessage = '',
  });

  PeersByCoinsState copyWith({
    bool? isLoading,
    List<CoinBalanceModel>? allPeers,
    List<CoinBalanceModel>? filteredPeers,
    String? selectedFilter,
    String? errorMessage,
  }) {
    return PeersByCoinsState(
      isLoading: isLoading ?? this.isLoading,
      allPeers: allPeers ?? this.allPeers,
      filteredPeers: filteredPeers ?? this.filteredPeers,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
