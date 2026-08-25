import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/referrals_repository.dart';
import 'referrals_event.dart';
import 'referrals_state.dart';

class ReferralsBloc extends Bloc<ReferralsEvent, ReferralsState> {
  final ReferralsRepository _referralsRepository;

  ReferralsBloc({ReferralsRepository? referralsRepository})
      : _referralsRepository = referralsRepository ?? ReferralsRepositoryImpl(),
        super(const ReferralsState()) {
    on<LoadReferrals>(_onLoadReferrals);
    on<FilterReferrals>(_onFilterReferrals);
  }

  Future<void> _onLoadReferrals(LoadReferrals event, Emitter<ReferralsState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    try {
      final response = await _referralsRepository.getReferrals();
      final allReferrals = response.data ?? const [];

      emit(state.copyWith(
        isLoading: false,
        allReferrals: allReferrals,
        filteredReferrals: allReferrals,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onFilterReferrals(FilterReferrals event, Emitter<ReferralsState> emit) {
    final filter = event.status;
    final filtered = filter == 'All'
        ? state.allReferrals
        : state.allReferrals.where((r) => r.status.toLowerCase() == filter.toLowerCase()).toList();

    emit(state.copyWith(
      selectedFilter: filter,
      filteredReferrals: filtered,
    ));
  }
}
