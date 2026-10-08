import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/member_activities_bloc.dart';
import '../bloc/member_activities_state.dart';
import '../model/member_activity_model.dart';
import '../presenter/member_activities_presenter.dart';
import 'widgets/member_activity_card.dart';

class BusinessDealsView extends StatelessWidget {
  final String memberId;
  final String memberName;

  const BusinessDealsView({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  static Future<void> open(
    BuildContext context, {
    required String memberId,
    required String memberName,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BusinessDealsView(memberId: memberId, memberName: memberName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Business Deals',
          subtitle: memberName,
          showBackButton: true,
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_upward_rounded, size: 15),
                          SizedBox(width: 6),
                          Text('Deals Given'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_downward_rounded, size: 15),
                          SizedBox(width: 6),
                          Text('Deals Received'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _BusinessDealsTab(
                      memberId: memberId,
                      type: MemberActivityType.dealGiven,
                    ),
                    _BusinessDealsTab(
                      memberId: memberId,
                      type: MemberActivityType.dealReceived,
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
}

class _BusinessDealsTab extends StatelessWidget {
  final String memberId;
  final MemberActivityType type;

  const _BusinessDealsTab({
    required this.memberId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MemberActivitiesBloc>(
      create: (_) {
        final bloc = MemberActivitiesBloc();
        MemberActivitiesPresenter(
          bloc: bloc,
        ).load(memberId: memberId, type: type);
        return bloc;
      },
      child: _BusinessDealsList(type: type),
    );
  }
}

class _BusinessDealsList extends StatelessWidget {
  final MemberActivityType type;

  const _BusinessDealsList({required this.type});

  @override
  Widget build(BuildContext context) {
    final presenter = MemberActivitiesPresenter(
      bloc: context.read<MemberActivitiesBloc>(),
    );

    return BlocBuilder<MemberActivitiesBloc, MemberActivitiesState>(
      builder: (context, state) {
        final items = state.activities;

        if (state.isLoading && items.isEmpty) {
          return const CenteredLoadingIndicator();
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
                    child: GradientIcon(icon: Icons.currency_rupee, size: 32),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No deals ${type == MemberActivityType.dealGiven ? 'given' : 'received'} yet',
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
