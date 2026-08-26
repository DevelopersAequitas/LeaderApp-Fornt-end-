import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/referrals_bloc.dart';
import '../bloc/referrals_state.dart';
import '../model/referral_model.dart';
import '../presenter/referrals_presenter.dart';
import 'widgets/referral_card.dart';
import 'widgets/referrals_filter_bar.dart';

/// Screen component rendering peers ranked by referrals with clean Material 3 design and space management.
class ReferralsView extends StatefulWidget {
  const ReferralsView({super.key});

  @override
  State<ReferralsView> createState() => _ReferralsViewState();
}

class _ReferralsViewState extends State<ReferralsView>
    implements ReferralsViewContract {
  late final ReferralsBloc _bloc;
  late final ReferralsPresenter _presenter;

  bool _isLoading = false;
  List<ReferralModel> _referrals = const [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _bloc = ReferralsBloc();
    _presenter = ReferralsPresenter(view: this, bloc: _bloc);
    _presenter.load();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // --- ReferralsViewContract Implementations ---

  @override
  void onReferralsLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void onReferralsLoaded() {
    setState(() {
      _isLoading = false;
      _referrals = _bloc.state.filteredReferrals;
      _selectedFilter = _bloc.state.selectedFilter;
    });
  }

  @override
  void onReferralsError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _onPeerTap(ReferralModel referral) {
    Navigator.of(context).pushNamed(
      AppRoutes.peerProfile,
      arguments: referral,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allList = _bloc.state.allReferrals;
    final activeCount =
        allList.where((r) => r.status.toLowerCase() == 'active').length;
    final atRiskCount =
        allList.where((r) => r.status.toLowerCase() == 'at risk').length;

    return BlocProvider<ReferralsBloc>.value(
      value: _bloc,
      child: BlocListener<ReferralsBloc, ReferralsState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: const CustomAppBar(
            title: 'Peers by Referrals',
            showBackButton: true,
          ),
          body: _isLoading && allList.isEmpty
              ? const CenteredLoadingIndicator(height: 300)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Filter Chips Bar
                    ReferralsFilterBar(
                      selectedFilter: _selectedFilter,
                      onFilterSelected: (status) =>
                          _presenter.filterStatus(status),
                      allCount: allList.length,
                      activeCount: activeCount,
                      atRiskCount: atRiskCount,
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    // Referrals List
                    Expanded(
                      child: _referrals.isEmpty
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
                                      Icons.people_outline_rounded,
                                      color: AppColors.textSecondary,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _selectedFilter == 'All'
                                        ? 'No peer referrals found'
                                        : 'No $_selectedFilter peers found',
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Referral activities and peer stats will show here.',
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
                              itemCount: _referrals.length,
                              itemBuilder: (context, index) {
                                final item = _referrals[index];
                                return ReferralCard(
                                  referral: item,
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
