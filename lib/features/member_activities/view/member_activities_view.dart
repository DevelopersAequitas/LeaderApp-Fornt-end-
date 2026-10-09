// ==============================================================================
// File: lib/features/member_activities/view/member_activities_view.dart
// Description: Full-screen list of a member's activities for one category
//              (P2P Meetings, Referrals, Deals, Attendance, Coins).
// Source API: GET /leader/members/{member_id}/activities?type={category}
// Architecture: MVP View (StatelessWidget) + BLoC
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/member_activities_bloc.dart';
import '../bloc/member_activities_event.dart';
import '../bloc/member_activities_state.dart';
import '../model/member_activity_model.dart';
import '../presenter/member_activities_presenter.dart';
import 'widgets/member_activity_card.dart';

class MemberActivitiesView extends StatelessWidget {
  final String memberId;
  final String memberName;
  final MemberActivityType type;

  const MemberActivitiesView({
    super.key,
    required this.memberId,
    required this.memberName,
    required this.type,
  });

  /// Convenience navigator used by metric tiles in the Peer Profile.
  static Future<void> open(
    BuildContext context, {
    required String memberId,
    required String memberName,
    required MemberActivityType type,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MemberActivitiesView(
          memberId: memberId,
          memberName: memberName,
          type: type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MemberActivitiesBloc>(
      create: (_) => MemberActivitiesBloc()
        ..add(LoadMemberActivities(memberId: memberId, type: type)),
      child: _MemberActivitiesContent(memberName: memberName, type: type),
    );
  }
}

class _MemberActivitiesContent extends StatelessWidget {
  final String memberName;
  final MemberActivityType type;

  const _MemberActivitiesContent({
    required this.memberName,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final presenter = MemberActivitiesPresenter(
      bloc: context.read<MemberActivitiesBloc>(),
    );

    return BlocListener<MemberActivitiesBloc, MemberActivitiesState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage &&
          curr.errorMessage.isNotEmpty,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: AppColors.danger,
          ),
        );
      },
      child: BlocBuilder<MemberActivitiesBloc, MemberActivitiesState>(
        builder: (context, state) {
          final items = state.activities;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: type.title,
              subtitle: memberName,
              showBackButton: true,
            ),
            body: SafeArea(
              top: false,
              child: state.isLoading && items.isEmpty
                  ? const CenteredLoadingIndicator()
                  : RefreshIndicator(
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
                                  return MemberActivityCard(
                                    activity: items[index],
                                  );
                                },
                              ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
          child: Column(
            children: [
              GradientBorderContainer(
                borderWidth: 1.8,
                borderRadius: 16,
                padding: const EdgeInsets.all(14),
                child: GradientIcon(icon: type.icon, size: 32),
              ),
              const SizedBox(height: 14),
              Text(
                type.emptyMessage,
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
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
