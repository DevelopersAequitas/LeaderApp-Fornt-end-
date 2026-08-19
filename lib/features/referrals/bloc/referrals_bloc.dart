import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/referral_model.dart';
import 'referrals_event.dart';
import 'referrals_state.dart';

class ReferralsBloc extends Bloc<ReferralsEvent, ReferralsState> {
  ReferralsBloc() : super(const ReferralsState()) {
    on<LoadReferrals>(_onLoadReferrals);
    on<FilterReferrals>(_onFilterReferrals);
  }

  void _onLoadReferrals(LoadReferrals event, Emitter<ReferralsState> emit) {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    final mockReferrals = const [
      ReferralModel(
        rank: 1,
        name: 'Priya Sharma',
        initials: 'PS',
        company: 'TechVentures',
        referralCount: 8,
        category: 'Mumbai · AI & Machine Learning',
        status: 'Active',
        source: 'Direct',
        attendanceRate: '96%',
        p2pCount: 14,
        referralsCount: 8,
        dealsCount: '₹32k',
        coinsCount: 420,
      ),
      ReferralModel(
        rank: 2,
        name: 'Ananya Patel',
        initials: 'AP',
        company: 'HealthFirst',
        referralCount: 7,
        category: 'Mumbai · Web & App Development',
        status: 'Active',
        source: 'Direct',
        attendanceRate: '89%',
        p2pCount: 10,
        referralsCount: 7,
        dealsCount: '₹24k',
        coinsCount: 340,
      ),
      ReferralModel(
        rank: 3,
        name: 'James O\'Brien',
        initials: 'JO',
        company: 'FinTech Pvt',
        referralCount: 6,
        category: 'Mumbai · SaaS & Platforms',
        status: 'Active',
        source: 'App',
        attendanceRate: '92%',
        p2pCount: 12,
        referralsCount: 6,
        dealsCount: '₹28k',
        coinsCount: 380,
      ),
      ReferralModel(
        rank: 4,
        name: 'Marcus Lee',
        initials: 'ML',
        company: 'DevStudio',
        referralCount: 5,
        category: 'Mumbai · Web & App Development',
        status: 'Active',
        source: 'App',
        attendanceRate: '87%',
        p2pCount: 9,
        referralsCount: 5,
        dealsCount: '₹19k',
        coinsCount: 310,
      ),
      ReferralModel(
        rank: 5,
        name: 'Fatima Al-Rashid',
        initials: 'FA',
        company: 'LegalEdge',
        referralCount: 4,
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
      allReferrals: mockReferrals,
      filteredReferrals: mockReferrals,
    ));
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
