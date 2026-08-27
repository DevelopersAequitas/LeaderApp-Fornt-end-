import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../peers/model/peer_model.dart';
import '../bloc/peer_profile_bloc.dart';
import '../bloc/peer_profile_state.dart';
import '../model/peer_profile_model.dart';
import '../presenter/peer_profile_presenter.dart';
import 'widgets/edit_peer_bottom_sheet.dart';
import 'widgets/log_p2p_bottom_sheet.dart';
import 'widgets/peer_profile_activity_section.dart';
import 'widgets/peer_profile_bottom_actions.dart';
import 'widgets/peer_profile_hero_card.dart';
import 'widgets/peer_profile_overview_section.dart';
import 'widgets/peer_profile_tab_selector.dart';
import 'widgets/peer_profile_testimonials_section.dart';
import 'widgets/send_referral_bottom_sheet.dart';

/// Screen component rendering a comprehensive Peer Profile view.
class PeerProfileView extends StatefulWidget {
  final PeerModel peer;

  const PeerProfileView({super.key, required this.peer});

  @override
  State<PeerProfileView> createState() => _PeerProfileViewState();
}

class _PeerProfileViewState extends State<PeerProfileView>
    implements PeerProfileViewContract {
  late final PeerProfileBloc _bloc;
  late final PeerProfilePresenter _presenter;

  int _activeSubTab = 0;
  bool _isLoading = false;
  PeerProfileDetailModel? _details;

  @override
  void initState() {
    super.initState();
    _bloc = PeerProfileBloc();
    _presenter = PeerProfilePresenter(view: this, bloc: _bloc);
    _presenter.load(widget.peer);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // --- PeerProfileViewContract Implementations ---

  @override
  void onProfileLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void onProfileLoaded() {
    setState(() {
      _isLoading = false;
      _details = _bloc.state.details;
    });
  }

  @override
  void onProfileError(String error) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void onSubTabChanged(int index) {
    if (_activeSubTab != index) {
      setState(() => _activeSubTab = index);
    }
  }

  void _showLogP2PModal() {
    LogP2PBottomSheet.show(
      context,
      peer: widget.peer,
      onMeetingLogged: () {
        _presenter.load(widget.peer);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('P2P Meeting logged successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      onError: onProfileError,
    );
  }

  void _showCreateReferralModal() {
    SendReferralBottomSheet.show(
      context,
      peer: widget.peer,
      onReferralSent: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Referral forwarded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      onError: onProfileError,
    );
  }

  void _showEditPeerModal(PeerModel currentPeer) {
    EditPeerBottomSheet.show(
      context,
      peer: currentPeer,
      onUpdated: (updatedPeer) {
        _presenter.load(updatedPeer);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peer profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePeer = _bloc.state.peer ?? widget.peer;
    final canEditPeer = SessionManager().permissions.canAddEditPeer ||
        SessionManager().currentRole == UserRole.superAdmin;

    return BlocProvider<PeerProfileBloc>.value(
      value: _bloc,
      child: BlocListener<PeerProfileBloc, PeerProfileState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: CustomAppBar(
            title: 'Peer Profile',
            showBackButton: true,
            actions: [
              if (canEditPeer)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  tooltip: 'Edit Peer Profile',
                  onPressed: () => _showEditPeerModal(activePeer),
                ),
            ],
          ),
          body: _isLoading && _details == null
              ? const CenteredLoadingIndicator(height: 300)
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PeerProfileHeroCard(peer: activePeer),
                      PeerProfileTabSelector(
                        activeIndex: _activeSubTab,
                        onTabSelected: (idx) => _presenter.changeSubTab(idx),
                        activityCount: _details?.activities.length ?? 0,
                        testimonialCount: _details?.testimonials.length ?? 0,
                      ),
                      const SizedBox(height: 4),
                      if (_activeSubTab == 0) ...[
                        if (_details != null)
                          PeerProfileOverviewSection(
                            peer: activePeer,
                            details: _details!,
                          ),
                      ] else if (_activeSubTab == 1) ...[
                        PeerProfileActivitySection(
                          activities: _details?.activities ?? [],
                        ),
                      ] else ...[
                        PeerProfileTestimonialsSection(
                          testimonials: _details?.testimonials ?? [],
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
          bottomNavigationBar: PeerProfileBottomActions(
            onLogP2PTap: _showLogP2PModal,
            onSendReferralTap: _showCreateReferralModal,
          ),
        ),
      ),
    );
  }
}
