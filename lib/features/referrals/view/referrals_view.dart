import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
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

  Widget _buildFilterPill(String label) {
    final isSelected = _selectedFilter.toLowerCase() == label.toLowerCase();
    return GestureDetector(
      onTap: () => _presenter.filterStatus(label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade500,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard(ReferralModel referral) {
    // Top rank badge colors
    Color badgeColor = const Color(0xFF78909C);
    if (referral.rank == 1) {
      badgeColor = const Color(0xFFD87D32);
    } else if (referral.rank == 2) {
      badgeColor = const Color(0xFF32567D);
    } else if (referral.rank == 3) {
      badgeColor = const Color(0xFF2E7D32);
    }

    final isRank1 = referral.rank == 1;
    final referralsBoxBg = isRank1 ? const Color(0xFFFFF3E0) : const Color(0xFFEDF2FA);
    final referralsBoxBorder = isRank1 ? const Color(0xFFFFE0B2) : const Color(0xFFDDE3ED);
    final referralsBoxTextColor = isRank1 ? const Color(0xFFD87D32) : const Color(0xFF32567D);

    final statusBg = referral.status == 'Active' ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final statusTextColor = referral.status == 'Active' ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    final sourceBorder = referral.source == 'Direct' ? const Color(0xFF81C784) : const Color(0xFF64B5F6);
    final sourceTextColor = referral.source == 'Direct' ? const Color(0xFF2E7D32) : const Color(0xFF1565C0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEFF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF162D4A),
                    child: Text(
                      referral.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
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
              const SizedBox(width: 14),
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
              // Referrals Counter Card Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: referralsBoxBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: referralsBoxBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${referral.referralCount}',
                      style: TextStyle(
                        color: referralsBoxTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'REFERRALS',
                      style: TextStyle(
                        color: referralsBoxTextColor.withOpacity(0.7),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Category and Badges Row
          Row(
            children: [
              Expanded(
                child: Text(
                  referral.category,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
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
              // Source Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
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
              _buildStatItem(referral.attendanceRate, 'Attend'),
              _buildStatItem('${referral.p2pCount}', 'P2P'),
              _buildStatItem('${referral.referralsCount}', 'Refs'),
              _buildStatItem(referral.dealsCount, 'Deals'),
              _buildStatItem('${referral.coinsCount}', 'Coins'),
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
          backgroundColor: const Color(0xFFF9FAFC),
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Peers by Referrals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Mumbai Tech Sunrise',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded, color: Colors.white),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : Column(
                  children: [
                    const SizedBox(height: 16),
                    // Filter Pills Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildFilterPill('All'),
                          _buildFilterPill('Active'),
                          _buildFilterPill('At Risk'),
                        ],
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
