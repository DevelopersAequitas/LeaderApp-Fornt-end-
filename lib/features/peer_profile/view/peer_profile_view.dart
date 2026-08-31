// ==============================================================================
// File: lib/features/peer_profile/view/peer_profile_view.dart
// Description: Comprehensive Peer Member Profile, KPI Breakdown & Interaction Suite
// Framework: Flutter | Architecture: MVP View Layer (100% Pure StatelessWidget + BLoC)
// Features:
//   - Detailed leader profile hero card with contact shortcuts (Call, Email, WhatsApp)
//   - Multi-tab breakdown: Overview KPIs, Attendance History, Activity Logs, and Testimonials
//   - Action bottom sheets for Logging 1-on-1 P2P Meetings, Sending Referrals, and Profile Editing
//   - Role-gated capability management driven by SessionManager and UserRole
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../peers/model/peer_model.dart';
import '../bloc/peer_profile_bloc.dart';
import '../bloc/peer_profile_event.dart';
import '../bloc/peer_profile_state.dart';
import 'widgets/edit_peer_bottom_sheet.dart';
// import 'widgets/log_p2p_bottom_sheet.dart';
import 'widgets/peer_profile_activity_section.dart';
// import 'widgets/peer_profile_bottom_actions.dart';
import 'widgets/peer_profile_hero_card.dart';
import 'widgets/peer_profile_overview_section.dart';
import 'widgets/peer_profile_tab_selector.dart';
import 'widgets/peer_profile_testimonials_section.dart';
// import 'widgets/send_referral_bottom_sheet.dart';

/// Screen component rendering a comprehensive Peer Profile view.
/// Pure StatelessWidget powered 100% by BLoC state machine.
class PeerProfileView extends StatelessWidget {
  final PeerModel peer;

  const PeerProfileView({super.key, required this.peer});

  @override
  Widget build(BuildContext context) {
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

  // void _showLogP2pSheet(BuildContext context, PeerModel currentPeer) {
  //   LogP2PBottomSheet.show(
  //     context,
  //     peer: currentPeer,
  //     onMeetingLogged: () {
  //       context.read<PeerProfileBloc>().add(LoadPeerProfile(currentPeer));
  //     },
  //     onError: (err) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(err), backgroundColor: AppColors.danger),
  //       );
  //     },
  //   );
  // }

  // void _showSendReferralSheet(BuildContext context, PeerModel currentPeer) {
  //   SendReferralBottomSheet.show(
  //     context,
  //     peer: currentPeer,
  //     onReferralSent: () {
  //       context.read<PeerProfileBloc>().add(LoadPeerProfile(currentPeer));
  //     },
  //     onError: (err) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(err), backgroundColor: AppColors.danger),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PeerProfileBloc>();
    final session = SessionManager().currentSession;
    final canEdit = session.role == UserRole.superAdmin ||
        session.role == UserRole.countryDirector ||
        session.role == UserRole.circleFounder;

    return BlocListener<PeerProfileBloc, PeerProfileState>(
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
      child: BlocBuilder<PeerProfileBloc, PeerProfileState>(
        builder: (context, state) {
          final displayPeer = state.peer ?? initialPeer;
          final details = state.details;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: displayPeer.name,
              subtitle: displayPeer.circle,
              showBackButton: true,
              actions: canEdit
                  ? [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.text,
                          size: 20,
                        ),
                        onPressed: () =>
                            _showEditPeerSheet(context, displayPeer),
                      ),
                    ]
                  : null,
            ),
            body: state.isLoading && details == null
                ? const CenteredLoadingIndicator(height: 300)
                : RefreshIndicator(
                    onRefresh: () async {
                      bloc.add(LoadPeerProfile(displayPeer));
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PeerProfileHeroCard(peer: displayPeer),
                          const SizedBox(height: 8),
                          PeerProfileTabSelector(
                            activeIndex: state.activeSubTab,
                            onTabSelected: (idx) =>
                                bloc.add(ChangeProfileSubTab(idx)),
                            activityCount: details?.activities.length ?? 0,
                            testimonialCount:
                                details?.testimonials.length ?? 0,
                          ),
                          const SizedBox(height: 12),
                          if (state.activeSubTab == 0 && details != null)
                            PeerProfileOverviewSection(
                              peer: displayPeer,
                              details: details,
                            )
                          else if (state.activeSubTab == 1 && details != null)
                            PeerProfileActivitySection(
                              activities: details.activities,
                            )
                          else if (state.activeSubTab == 2 && details != null)
                            PeerProfileTestimonialsSection(
                              testimonials: details.testimonials,
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
            // bottomNavigationBar: PeerProfileBottomActions(
            //   onLogP2PTap: () => _showLogP2pSheet(context, displayPeer),
            //   onSendReferralTap: () =>
            //       _showSendReferralSheet(context, displayPeer),
            // ),
          );
        },
      ),
    );
  }
}
