// ==============================================================================
// File: lib/features/peer_profile/view/peer_profile_view.dart
// Description: Founder-Level Peer Profile View
// Framework: Flutter | Architecture: MVP View Layer + BLoC
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../peers/model/peer_model.dart';
import '../bloc/peer_profile_bloc.dart';
import '../bloc/peer_profile_event.dart';
import '../bloc/peer_profile_state.dart';
import '../model/peer_profile_model.dart';
import '../model/peer_profile_sections_model.dart';
import '../presenter/peer_profile_presenter.dart';
import 'widgets/edit_peer_bottom_sheet.dart';
import 'widgets/peer_profile_activity_section.dart';
import 'widgets/peer_profile_business_section.dart';
import 'widgets/peer_profile_collaborations_section.dart';
import 'widgets/peer_profile_hero_card.dart';
import 'widgets/peer_profile_leadership_section.dart';
import 'widgets/peer_profile_life_impact_section.dart';
import 'widgets/peer_profile_organization_section.dart';
import 'widgets/peer_profile_overview_section.dart';
import 'widgets/peer_profile_performance_section.dart';
import 'widgets/peer_profile_shimmer_skeleton.dart';
import 'widgets/peer_profile_tab_selector.dart';

/// Screen component rendering the Founder-Level Peer Profile across conditional sections.
class PeerProfileView extends StatelessWidget {
  final PeerModel peer;
  final PeerProfileBloc? bloc;

  const PeerProfileView({
    super.key,
    required this.peer,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<PeerProfileBloc>.value(
        value: bloc!,
        child: _PeerProfileContent(initialPeer: peer),
      );
    }
    return BlocProvider<PeerProfileBloc>(
      create: (context) => PeerProfileBloc()..add(LoadPeerProfile(peer)),
      child: _PeerProfileContent(initialPeer: peer),
    );
  }
}

class _PeerProfileContent extends StatelessWidget {
  final PeerModel initialPeer;

  const _PeerProfileContent({required this.initialPeer});

  void _showEditPeerSheet(BuildContext context, PeerModel currentPeer) {
    EditPeerBottomSheet.show(
      context,
      peer: currentPeer,
      onUpdated: (updated) {
        context.read<PeerProfileBloc>().add(LoadPeerProfile(updated));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PeerProfileBloc>();
    final session = SessionManager().currentSession;
    final canEdit = SessionManager().isSuperAdmin ||
        SessionManager().permissions.canAddEditPeer ||
        session.role == UserRole.countryDirector ||
        session.role == UserRole.circleFounder;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<PeerProfileBloc, PeerProfileState>(
      listenWhen: (prev, curr) =>
          (prev.errorMessage != curr.errorMessage &&
              curr.errorMessage.isNotEmpty) ||
          (prev.successMessage != curr.successMessage &&
              curr.successMessage.isNotEmpty),
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.danger,
            ),
          );
        } else if (state.successMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      child: BlocBuilder<PeerProfileBloc, PeerProfileState>(
        builder: (context, state) {
          final displayPeer = state.peer ?? initialPeer;
          final details = state.details;
          final visibleSections = PeerProfilePresenter.resolveVisibleSections(
            displayPeer,
            details,
          );
          final effectiveSection =
              visibleSections.contains(state.activeSection)
                  ? state.activeSection
                  : PeerProfileSection.overview;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: CustomAppBar(
              title: displayPeer.name,
              subtitle: displayPeer.circle,
              showBackButton: true,
              actions: canEdit
                  ? [
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: isDark
                              ? AppColor.darkTextPrimary
                              : AppColor.lightTextPrimary,
                          size: 20,
                        ),
                        onPressed: () =>
                            _showEditPeerSheet(context, displayPeer),
                      ),
                    ]
                  : null,
            ),
            body: SafeArea(
              top: false,
              child: state.isLoading && details == null
                  ? const PeerProfileSkeleton()
                  : RefreshIndicator(
                      onRefresh: () async {
                        bloc.add(LoadPeerProfile(displayPeer));
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PeerProfileHeroCard(
                              peer: displayPeer,
                              details: details,
                            ),
                            if (details != null) ...[
                              const SizedBox(height: 6),
                              PeerProfileTabSelector(
                                sections: visibleSections,
                                activeSection: effectiveSection,
                                onSectionSelected: (section) =>
                                    bloc.add(SelectPeerProfileSection(section)),
                              ),
                              const SizedBox(height: 12),
                              _buildActiveSection(
                                context,
                                bloc,
                                state,
                                displayPeer,
                                details,
                                effectiveSection,
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveSection(
    BuildContext context,
    PeerProfileBloc bloc,
    PeerProfileState state,
    PeerModel displayPeer,
    PeerProfileDetailModel details,
    PeerProfileSection activeSection,
  ) {
    void refreshProfile() => bloc.add(LoadPeerProfile(displayPeer));
    void selectSection(PeerProfileSection s) =>
        bloc.add(SelectPeerProfileSection(s));

    switch (activeSection) {
      case PeerProfileSection.overview:
        return PeerProfileOverviewSection(
          peer: displayPeer,
          details: details,
          onSelectSection: selectSection,
          onRefreshProfile: refreshProfile,
        );
      case PeerProfileSection.business:
        return PeerProfileBusinessSection(
          business: details.business ??
              PeerBusinessInfoModel(
                companyName: displayPeer.company,
                designation: displayPeer.designation ?? '',
                industry: displayPeer.industry ?? '',
                level4Category: displayPeer.level4Category ?? '',
                shortBio: details.bio,
                industryTags: details.tags,
              ),
          fallbackBio: details.bio,
          fallbackTags: details.tags,
        );
      case PeerProfileSection.organization:
        return PeerProfileOrganizationSection(
          organization: details.organization ??
              PeerOrganizationInfoModel(
                city: displayPeer.location,
                primaryCircleName: displayPeer.circle,
                membershipStatus: displayPeer.status,
                joiningDate: details.joinedDate,
              ),
        );
      case PeerProfileSection.leadership:
        return PeerProfileLeadershipSection(
          leadership: details.leadership ?? const PeerLeadershipHistoryModel(),
        );
      case PeerProfileSection.collaborations:
        return PeerProfileCollaborationsSection(
          peer: displayPeer,
          details: details,
          collaborations: details.collaborationsInfo ??
              PeerCollaborationGrowthModel(
                dealsGivenCount: 0,
                dealsReceivedCount: 0,
                dealsTotalValueFormatted: details.dealsClosed,
                referralsGivenCount: details.referralsGiven,
                referralsReceivedCount: details.referralsReceived,
                collaborationAsksCount: details.collaborationsCount,
                introducedPeersCount: details.introducedPeersCount,
              ),
        );
      case PeerProfileSection.lifeImpact:
        return PeerProfileLifeImpactSection(
          lifeImpact: details.lifeImpact ??
              PeerLifeImpactSummaryModel(
                total: details.impactCount,
                approvedCount: details.impactCount,
                totalLivesImpacted: details.impactCount,
              ),
          activeFilter: state.impactStatusFilter,
          onFilterChanged: (status) =>
              bloc.add(FilterPeerProfileImpacts(status)),
          onRefreshProfile: refreshProfile,
        );
      case PeerProfileSection.performance:
        return PeerProfilePerformanceSection(
          peer: displayPeer,
          details: details,
          performance: details.performance ??
              PeerPerformanceInfoModel(
                p2pMeetingsCount: details.p2pSessions,
                testimonialsReceivedCount: details.testimonials.length,
                postsCount: details.posts.length,
              ),
        );
      case PeerProfileSection.activity:
        return PeerProfileActivitySection(
          peer: displayPeer,
          details: details,
          timeline: details.timeline,
          activities: details.activities,
          onRefreshProfile: refreshProfile,
        );
    }
  }
}
