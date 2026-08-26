import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/peers_by_coins_bloc.dart';
import '../bloc/peers_by_coins_state.dart';
import '../model/coin_balance_model.dart';
import '../presenter/peers_by_coins_presenter.dart';
import 'widgets/peer_coin_card.dart';
import 'widgets/peers_by_coins_filter_bar.dart';

/// Screen component rendering peers ranked by coin balances with Material 3 design.
class PeersByCoinsView extends StatefulWidget {
  const PeersByCoinsView({super.key});

  @override
  State<PeersByCoinsView> createState() => _PeersByCoinsViewState();
}

class _PeersByCoinsViewState extends State<PeersByCoinsView>
    implements PeersByCoinsViewContract {
  late final PeersByCoinsBloc _bloc;
  late final PeersByCoinsPresenter _presenter;

  bool _isLoading = false;
  List<CoinBalanceModel> _peers = const [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _bloc = PeersByCoinsBloc();
    _presenter = PeersByCoinsPresenter(view: this, bloc: _bloc);
    _presenter.load();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // --- PeersByCoinsViewContract Implementations ---

  @override
  void onPeersByCoinsLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void onPeersByCoinsLoaded() {
    setState(() {
      _isLoading = false;
      _peers = _bloc.state.filteredPeers;
      _selectedFilter = _bloc.state.selectedFilter;
    });
  }

  @override
  void onPeersByCoinsError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _onPeerTap(CoinBalanceModel peer) {
    Navigator.of(context).pushNamed(
      AppRoutes.peerProfile,
      arguments: peer,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allList = _bloc.state.allPeers;
    final activeCount =
        allList.where((p) => p.status.toLowerCase() == 'active').length;
    final atRiskCount =
        allList.where((p) => p.status.toLowerCase() == 'at risk').length;

    return BlocProvider<PeersByCoinsBloc>.value(
      value: _bloc,
      child: BlocListener<PeersByCoinsBloc, PeersByCoinsState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: CustomAppBar(
            title: 'Peers by Coins',
            subtitle: '${allList.length} peers ranked',
            showBackButton: true,
          ),
          body: _isLoading && allList.isEmpty
              ? const CenteredLoadingIndicator(height: 300)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Filter Chips Bar
                    PeersByCoinsFilterBar(
                      selectedFilter: _selectedFilter,
                      onFilterSelected: (status) =>
                          _presenter.filterStatus(status),
                      allCount: allList.length,
                      activeCount: activeCount,
                      atRiskCount: atRiskCount,
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    // Ranked Peers List
                    Expanded(
                      child: _peers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.monetization_on_outlined,
                                      color: AppColors.textSecondary,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _selectedFilter == 'All'
                                        ? 'No peers found'
                                        : 'No $_selectedFilter peers found',
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Peer coin balances and ranking positions will show here.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: 6, bottom: 24),
                              itemCount: _peers.length,
                              itemBuilder: (context, index) {
                                final item = _peers[index];
                                return PeerCoinCard(
                                  peer: item,
                                  onTap: () => _onPeerTap(item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
