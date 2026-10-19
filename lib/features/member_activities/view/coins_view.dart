import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_page_route.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/member_activities_bloc.dart';
import '../bloc/member_activities_event.dart';
import '../bloc/member_activities_state.dart';
import '../model/member_activity_model.dart';
import '../presenter/member_activities_presenter.dart';
import 'widgets/member_activity_card.dart';

/// Dedicated screen for displaying member Coins activity (All, Earned, Redeemed).
class CoinsView extends StatelessWidget {
  final String memberId;
  final String memberName;
  final int? coinBalance;

  const CoinsView({
    super.key,
    required this.memberId,
    required this.memberName,
    this.coinBalance,
  });

  static Future<void> open(
    BuildContext context, {
    required String memberId,
    required String memberName,
    int? coinBalance,
  }) {
    return Navigator.of(context).push(
      AppPageRoute(
        builder: (_) => CoinsView(
          memberId: memberId,
          memberName: memberName,
          coinBalance: coinBalance,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Coins History',
          subtitle: memberName,
          showBackButton: true,
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              if (coinBalance != null) _buildBalanceHeader(coinBalance!),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    gradient: AppColor.brandGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_rounded, size: 14),
                          SizedBox(width: 4),
                          Text('All Activity'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_downward_rounded, size: 14),
                          SizedBox(width: 4),
                          Text('Earned'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_upward_rounded, size: 14),
                          SizedBox(width: 4),
                          Text('Redeemed'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _CoinsTab(
                      memberId: memberId,
                      type: MemberActivityType.coins,
                    ),
                    _CoinsTab(
                      memberId: memberId,
                      type: MemberActivityType.coinsEarned,
                    ),
                    _CoinsTab(
                      memberId: memberId,
                      type: MemberActivityType.coinsRedeemed,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceHeader(int balance) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.7),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SquareRoundedGradientIcon(
            icon: Icons.stars_rounded,
            boxSize: 38,
            iconSize: 22,
            borderRadius: 10,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'CURRENT COIN BALANCE',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                GradientText(
                  '$balance Coins',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 13,
                  color: AppColors.success,
                ),
                SizedBox(width: 4),
                Text(
                  'Verified',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinsTab extends StatelessWidget {
  final String memberId;
  final MemberActivityType type;

  const _CoinsTab({
    required this.memberId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MemberActivitiesBloc>(
      create: (_) => MemberActivitiesBloc()
        ..add(LoadMemberActivities(memberId: memberId, type: type)),
      child: _CoinsList(type: type),
    );
  }
}

class _CoinsList extends StatelessWidget {
  final MemberActivityType type;

  const _CoinsList({required this.type});

  @override
  Widget build(BuildContext context) {
    final presenter = MemberActivitiesPresenter(
      bloc: context.read<MemberActivitiesBloc>(),
    );

    return BlocBuilder<MemberActivitiesBloc, MemberActivitiesState>(
      builder: (context, state) {
        final items = state.activities;

        if (state.isLoading && items.isEmpty) {
          return const ListShimmerSkeleton();
        }

        return RefreshIndicator(
          onRefresh: () async => presenter.refresh(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.extentAfter < 200) {
                presenter.loadMore();
              }
              return false;
            },
            child: items.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
                    itemCount: items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        return state.isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: AppShimmer(
                                  child: ShimmerBox(
                                    width: double.infinity,
                                    height: 40,
                                    borderRadius: 10,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      }
                      return MemberActivityCard(activity: items[index]);
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String emptyText;
    switch (type) {
      case MemberActivityType.coinsEarned:
        emptyText = 'No earned coins recorded yet';
        break;
      case MemberActivityType.coinsRedeemed:
        emptyText = 'No redeemed coins recorded yet';
        break;
      default:
        emptyText = 'No coin transactions found';
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GradientBorderContainer(
                    borderWidth: 1.8,
                    borderRadius: 16,
                    padding: EdgeInsets.all(14),
                    child: GradientIcon(icon: Icons.stars_rounded, size: 32),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    emptyText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pull down to refresh.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
