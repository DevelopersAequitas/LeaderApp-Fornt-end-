import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/coin_balance_model.dart';
import 'peers_by_coins_event.dart';
import 'peers_by_coins_state.dart';

class PeersByCoinsBloc extends Bloc<PeersByCoinsEvent, PeersByCoinsState> {
  PeersByCoinsBloc() : super(const PeersByCoinsState()) {
    on<LoadPeersByCoins>(_onLoadPeersByCoins);
    on<FilterPeersByCoins>(_onFilterPeersByCoins);
  }

  void _onLoadPeersByCoins(LoadPeersByCoins event, Emitter<PeersByCoinsState> emit) {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    final mockPeers = const [
      CoinBalanceModel(
        rank: 1,
        name: 'Priya Sharma',
        initials: 'PS',
        company: 'TechVentures',
        coins: 420,
        category: 'Mumbai · AI & Machine Learning',
        status: 'Active',
        source: 'Direct',
        attendanceRate: '96%',
        p2pCount: 14,
        referralsCount: 8,
        dealsCount: '₹32k',
        coinsCount: 420,
      ),
      CoinBalanceModel(
        rank: 2,
        name: 'James O\'Brien',
        initials: 'JO',
        company: 'FinTech Pvt',
        coins: 380,
        category: 'Mumbai · SaaS & Platforms',
        status: 'Active',
        source: 'App',
        attendanceRate: '92%',
        p2pCount: 12,
        referralsCount: 6,
        dealsCount: '₹28k',
        coinsCount: 380,
      ),
      CoinBalanceModel(
        rank: 3,
        name: 'Ananya Patel',
        initials: 'AP',
        company: 'HealthFirst',
        coins: 340,
        category: 'Mumbai · Web & App Development',
        status: 'Active',
        source: 'Direct',
        attendanceRate: '89%',
        p2pCount: 10,
        referralsCount: 7,
        dealsCount: '₹24k',
        coinsCount: 340,
      ),
      CoinBalanceModel(
        rank: 4,
        name: 'Marcus Lee',
        initials: 'ML',
        company: 'DevStudio',
        coins: 310,
        category: 'Mumbai · Web & App Development',
        status: 'Active',
        source: 'App',
        attendanceRate: '87%',
        p2pCount: 9,
        referralsCount: 5,
        dealsCount: '₹19k',
        coinsCount: 310,
      ),
      CoinBalanceModel(
        rank: 5,
        name: 'Fatima Al-Rashid',
        initials: 'FA',
        company: 'LegalEdge',
        coins: 280,
        category: 'Mumbai · Legal & Compliance',
        status: 'At Risk',
        source: 'Direct',
        attendanceRate: '78%',
        p2pCount: 6,
        referralsCount: 4,
        dealsCount: '₹12k',
        coinsCount: 220,
      ),
    ];

    emit(state.copyWith(
      isLoading: false,
      allPeers: mockPeers,
      filteredPeers: mockPeers,
    ));
  }

  void _onFilterPeersByCoins(FilterPeersByCoins event, Emitter<PeersByCoinsState> emit) {
    final filter = event.status;
    final filtered = filter == 'All'
        ? state.allPeers
        : state.allPeers.where((p) => p.status.toLowerCase() == filter.toLowerCase()).toList();

    emit(state.copyWith(
      selectedFilter: filter,
      filteredPeers: filtered,
    ));
  }
}
