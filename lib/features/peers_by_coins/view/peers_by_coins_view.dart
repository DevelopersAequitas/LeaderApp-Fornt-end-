// ==============================================================================
// File: lib/features/peers_by_coins/view/peers_by_coins_view.dart
// Description: Executive Gamification & Peer Coin Balance Leaderboard
// Framework: Flutter | Architecture: MVP View Layer (100% Pure StatelessWidget + BLoC)
// Features:
//   - Tiered coin balance ranking (Gold, Silver, Bronze badges)
//   - Filter bar with status counts (All, Active, At Risk)
//   - Peer coin transactions, earned reward breakdowns, and profile deep linking
//   - Pure BLoC reactive state rendering
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/peers_by_coins_bloc.dart';
import '../bloc/peers_by_coins_event.dart';
import '../bloc/peers_by_coins_state.dart';
import '../model/coin_balance_model.dart';
import 'widgets/peer_coin_card.dart';
import 'widgets/peers_by_coins_filter_bar.dart';

/// Screen component rendering peers ranked by coin balances.
/// Pure StatelessWidget powered 100% by BLoC state machine.
class PeersByCoinsView extends StatelessWidget {
  const PeersByCoinsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PeersByCoinsBloc>(
      create: (context) =>
          PeersByCoinsBloc()..add(const LoadPeersByCoins()),
      child: const _PeersByCoinsContent(),
    );
  }
}

class _PeersByCoinsContent extends StatelessWidget {
  const _PeersByCoinsContent();

  void _onPeerTap(BuildContext context, CoinBalanceModel peer) {
    Navigator.of(context).pushNamed(
      AppRoutes.peerProfile,
      arguments: peer,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PeersByCoinsBloc>();

    return BlocListener<PeersByCoinsBloc, PeersByCoinsState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage && curr.errorMessage.isNotEmpty,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: AppColors.danger,
          ),
        );
      },
      child: BlocBuilder<PeersByCoinsBloc, PeersByCoinsState>(
        builder: (context, state) {
          final peers = state.filteredPeers;
          final allPeers = state.allPeers;

          final activeCount = allPeers.where((p) => p.status.toLowerCase() == 'active').length;
          final atRiskCount = allPeers.where((p) => p.status.toLowerCase() == 'at risk').length;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: 'Peers by Coins',
              subtitle: '${allPeers.length} members ranked',
              showBackButton: true,
            ),
            body: Column(
              children: [
                PeersByCoinsFilterBar(
                  selectedFilter: state.selectedFilter,
                  allCount: allPeers.length,
                  activeCount: activeCount,
                  atRiskCount: atRiskCount,
                  onFilterSelected: (status) =>
                      bloc.add(FilterPeersByCoins(status)),
                ),
                Expanded(
                  child: state.isLoading && allPeers.isEmpty
                      ? const CenteredLoadingIndicator(height: 300)
                      : RefreshIndicator(
                          onRefresh: () async {
                            bloc.add(const LoadPeersByCoins());
                          },
                          child: peers.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.monetization_on_outlined,
                                          color: AppColors.textSecondary,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No peer balances found',
                                        style: TextStyle(
                                          color: AppColors.text,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Try adjusting your search query or status filter.',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 24,
                                  ),
                                  itemCount: peers.length,
                                  itemBuilder: (context, index) {
                                    final item = peers[index];
                                    return PeerCoinCard(
                                      peer: item,
                                      onTap: () => _onPeerTap(context, item),
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
