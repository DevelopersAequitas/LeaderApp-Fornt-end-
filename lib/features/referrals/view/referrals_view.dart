import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/referrals_bloc.dart';
import '../bloc/referrals_state.dart';
import '../presenter/referrals_presenter.dart';
import '../model/referral_model.dart';

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

  @override
  void onReferralsLoading() {
    setState(() {
      _isLoading = true;
    });
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
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget _buildReferralCard(ReferralModel referral) {
    // Top rank badge colors
    Color badgeColor = const Color(0xFF78909C);
    if (referral.rank == 1) {
      badgeColor = AppColors.warning;
    } else if (referral.rank == 2) {
      badgeColor = AppColors.chartPrimary;
    } else if (referral.rank == 3) {
      badgeColor = AppColors.success;
    }

    final isRank1 = referral.rank == 1;
    final referralsBoxBg = isRank1 ? AppColors.warningBg : AppColors.selectionBg;
    final referralsBoxBorder = isRank1 ? AppColors.warningBorder : AppColors.dashedBorder;
    final referralsBoxTextColor = isRank1 ? AppColors.warning : AppColors.chartPrimary;

    final statusBg = referral.status == 'Active' ? AppColors.successBg : AppColors.dangerBg;
    final statusTextColor = referral.status == 'Active' ? AppColors.success : AppColors.danger;

    final sourceBorder = referral.source == 'Direct' ? AppColors.successBorder : AppColors.infoBorder;
    final sourceTextColor = referral.source == 'Direct' ? AppColors.success : AppColors.info;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Avatar Stack with Rank Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  InitialsAvatar(
                    name: referral.name,
                    radius: 22,
                    backgroundColor: AppColors.primary,
                    fontSize: 14,
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${referral.rank}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      referral.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      referral.company,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Referrals Count Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: referralsBoxBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: referralsBoxBorder, width: 1),
                ),
                child: Text(
                  '${referral.referralCount} refs',
                  style: TextStyle(
                    color: referralsBoxTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Badges Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  referral.status,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sourceBorder),
                ),
                child: Text(
                  referral.source,
                  style: TextStyle(
                    color: sourceTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEDEFF3)),
          const SizedBox(height: 12),
          // Stats Row Grid
          Row(
            children: [
              Expanded(
                child: StatCard(
                  value: referral.attendanceRate,
                  label: 'Attend',
                  valueColor: AppColors.text,
                  valueFontSize: 13,
                  labelFontSize: 10,
                  labelColor: Colors.grey.shade500,
                  padding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: StatCard(
                  value: '${referral.p2pCount}',
                  label: 'P2P',
                  valueColor: AppColors.text,
                  valueFontSize: 13,
                  labelFontSize: 10,
                  labelColor: Colors.grey.shade500,
                  padding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: StatCard(
                  value: '${referral.referralsCount}',
                  label: 'Refs',
                  valueColor: AppColors.text,
                  valueFontSize: 13,
                  labelFontSize: 10,
                  labelColor: Colors.grey.shade500,
                  padding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: StatCard(
                  value: referral.dealsCount,
                  label: 'Deals',
                  valueColor: AppColors.text,
                  valueFontSize: 13,
                  labelFontSize: 10,
                  labelColor: Colors.grey.shade500,
                  padding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: StatCard(
                  value: '${referral.coinsCount}',
                  label: 'Coins',
                  valueColor: AppColors.text,
                  valueFontSize: 13,
                  labelFontSize: 10,
                  labelColor: Colors.grey.shade500,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          body: _isLoading
              ? const CenteredLoadingIndicator()
              : Column(
                  children: [
                    const SizedBox(height: 16),
                    // Filter Pills Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: HorizontalSelectionChips(
                        options: const ['All', 'Active', 'At Risk'],
                        selectedOption: _selectedFilter,
                        onSelected: (status) => _presenter.filterStatus(status),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // List
                    Expanded(
                      child: _referrals.isEmpty
                          ? Center(
                              child: Text(
                                'No peers found',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _referrals.length,
                              itemBuilder: (context, index) {
                                return _buildReferralCard(_referrals[index]);
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
