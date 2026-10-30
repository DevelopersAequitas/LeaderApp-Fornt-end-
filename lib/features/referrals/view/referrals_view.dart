// ==============================================================================
// File: lib/features/referrals/view/referrals_view.dart
// Description: Member Referral Exchange, Conversion Ranks & Deals Network
// Framework: Flutter | Architecture: MVP View Layer
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/referrals_bloc.dart';
import '../bloc/referrals_event.dart';
import '../bloc/referrals_state.dart';
import '../model/referral_model.dart';
import 'widgets/referral_card.dart';
import 'widgets/referrals_filter_bar.dart';

class ReferralsView extends StatelessWidget {
  const ReferralsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReferralsBloc>(
      create: (context) => ReferralsBloc()..add(const LoadReferrals()),
      child: const _ReferralsContent(),
    );
  }
}

class _ReferralsContent extends StatefulWidget {
  const _ReferralsContent();

  @override
  State<_ReferralsContent> createState() => _ReferralsContentState();
}

class _ReferralsContentState extends State<_ReferralsContent> {
  String _searchQuery = '';

  void _onPeerTap(BuildContext context, ReferralModel referral) {
    Navigator.of(context).pushNamed(
      AppRoutes.peerProfile,
      arguments: referral.toPeerModel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReferralsBloc>();

    return BlocListener<ReferralsBloc, ReferralsState>(
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
      child: BlocBuilder<ReferralsBloc, ReferralsState>(
        builder: (context, state) {
          final q = _searchQuery.trim().toLowerCase();
          final referrals = q.isEmpty
              ? state.filteredReferrals
              : state.filteredReferrals.where((r) {
                  return r.name.toLowerCase().contains(q) ||
                      r.company.toLowerCase().contains(q) ||
                      r.city.toLowerCase().contains(q) ||
                      r.category.toLowerCase().contains(q);
                }).toList();
          final allReferrals = state.allReferrals;

          final activeCount = allReferrals
              .where((r) => r.status.toLowerCase() == 'active')
              .length;
          final atRiskCount = allReferrals
              .where((r) => r.status.toLowerCase() == 'at risk')
              .length;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: 'Peers by Referrals',
              showBackButton: true,
              showSearch: true,
              searchHint: 'Search referrals...',
              onSearchChanged: (val) => setState(() => _searchQuery = val),
              onSearchClosed: () => setState(() => _searchQuery = ''),
            ),
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  ReferralsFilterBar(
                    selectedFilter: state.selectedFilter,
                    allCount: allReferrals.length,
                    activeCount: activeCount,
                    atRiskCount: atRiskCount,
                    onFilterSelected: (status) =>
                        bloc.add(FilterReferrals(status)),
                  ),
                  Expanded(
                    child: state.isLoading && allReferrals.isEmpty
                        ? const ListShimmerSkeleton()
                        : RefreshIndicator(
                            onRefresh: () async {
                              bloc.add(const LoadReferrals());
                            },
                            child: referrals.isEmpty
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
                                            Icons.share_outlined,
                                            color: AppColors.textSecondary,
                                            size: 26,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'No referrals found',
                                          style: TextStyle(
                                            color: AppColors.text,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
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
                                    itemCount: referrals.length,
                                    itemBuilder: (context, index) {
                                      final item = referrals[index];
                                      return ReferralCard(
                                        referral: item,
                                        onTap: () => _onPeerTap(context, item),
                                      );
                                    },
                                  ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
