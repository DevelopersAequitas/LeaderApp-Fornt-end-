import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/referrals_repository.dart';
import 'peers_by_coins_event.dart';
import 'peers_by_coins_state.dart';

class PeersByCoinsBloc extends Bloc<PeersByCoinsEvent, PeersByCoinsState> {
  final ReferralsRepository _referralsRepository;

  PeersByCoinsBloc({ReferralsRepository? referralsRepository})
      : _referralsRepository = referralsRepository ?? ReferralsRepositoryImpl(),
        super(const PeersByCoinsState()) {
    on<LoadPeersByCoins>(_onLoadPeersByCoins);
    on<FilterPeersByCoins>(_onFilterPeersByCoins);
  }

  Future<void> _onLoadPeersByCoins(LoadPeersByCoins event, Emitter<PeersByCoinsState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    try {
      final response = await _referralsRepository.getPeersByCoins();
      final allPeers = response.data ?? const [];

      emit(state.copyWith(
        isLoading: false,
        allPeers: allPeers,
        filteredPeers: allPeers,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
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
