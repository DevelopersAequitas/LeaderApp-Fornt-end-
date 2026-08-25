import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/peers_bloc.dart';
import '../bloc/peers_state.dart';
import '../model/celebration_model.dart';
import '../model/peer_model.dart';
import '../presenter/peers_presenter.dart';
import 'widgets/celebration_card.dart';
import 'widgets/peer_card.dart';
import 'widgets/peer_role_management_section.dart';
import 'widgets/peers_empty_state.dart';
import 'widgets/peers_filter_bar.dart';

/// The View component of the Peers tab feature.
class PeersView extends StatefulWidget {
  final String? selectedCircle;
  const PeersView({super.key, this.selectedCircle});

  @override
  State<PeersView> createState() => _PeersViewState();
}

class _PeersViewState extends State<PeersView> implements PeersViewContract {
  late final PeersBloc _bloc;
  late final PeersPresenter _presenter;
  late final TextEditingController _searchController;

  int _activeSubTab = 0;
  bool _isLoading = false;
  String _selectedStatus = 'All';
  String _selectedSort = 'Impact';
  List<PeerModel> _peers = const [];
  List<CelebrationModel> _birthdays = const [];
  List<CelebrationModel> _anniversaries = const [];

  @override
  void initState() {
    super.initState();
    _bloc = PeersBloc();
    _presenter = PeersPresenter(view: this, bloc: _bloc);
    _searchController = TextEditingController();

    _searchController.addListener(() {
      _presenter.search(_searchController.text);
    });

    _presenter.load(selectedCircle: widget.selectedCircle);
  }

  @override
  void didUpdateWidget(covariant PeersView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCircle != oldWidget.selectedCircle) {
      _presenter.load(selectedCircle: widget.selectedCircle);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  // --- PeersViewContract Implementations ---

  @override
  void onPeersLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void onPeersLoaded() {
    setState(() {
      _isLoading = false;
      _peers = _bloc.state.filteredPeers;
      _birthdays = _bloc.state.birthdays;
      _anniversaries = _bloc.state.anniversaries;
      _selectedStatus = _bloc.state.selectedStatus;
      _selectedSort = _bloc.state.selectedSort;
    });
  }

  @override
  void onPeersError(String error) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void onWishSent(String peerName, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Wish sent to $peerName successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void onTabChanged(int index) {
    if (_activeSubTab != index) {
      setState(() => _activeSubTab = index);
    }
  }

  Widget _buildPeersListTab() {
    final currentRole = SessionManager().currentRole;
    final isRoleManagementVisible =
        currentRole == UserRole.industryDirector ||
        currentRole == UserRole.superAdmin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PeersFilterBar(
          searchController: _searchController,
          selectedStatus: _selectedStatus,
          selectedSort: _selectedSort,
          onStatusSelected: (status) => _presenter.filterStatus(status),
          onSortSelected: (sort) => _presenter.sortMetric(sort),
        ),
        if (_peers.isEmpty)
          const PeersEmptyState(
            icon: Icons.people_outline_rounded,
            title: 'No Peers Found',
            message:
                'No peers match your search query or filter criteria in this circle.',
          )
        else
          ..._peers.map(
            (peer) => PeerCard(
              peer: peer,
              selectedSort: _selectedSort,
            ),
          ),
        if (isRoleManagementVisible) const PeerRoleManagementSection(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCelebrationsTab() {
    final hasBirthdays = _birthdays.isNotEmpty;
    final hasAnniversaries = _anniversaries.isNotEmpty;

    if (!hasBirthdays && !hasAnniversaries) {
      return const PeersEmptyState(
        icon: Icons.celebration_outlined,
        title: 'No Celebrations This Month',
        message:
            'Upcoming birthdays and business anniversaries will appear here automatically.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasBirthdays) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.cake_rounded, color: Colors.redAccent, size: 16),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Birthdays This Month',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_birthdays.length} ${_birthdays.length == 1 ? "peer" : "peers"}',
                    style: const TextStyle(
                      color: Color(0xFF5A6E85),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._birthdays.map(
            (b) => CelebrationCard(
              celebration: b,
              onWishTap: () => _presenter.sendWish(b.peerName, b.type),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (hasAnniversaries) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Business Anniversaries',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_anniversaries.length} ${_anniversaries.length == 1 ? "peer" : "peers"}',
                    style: const TextStyle(
                      color: Color(0xFF5A6E85),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._anniversaries.map(
            (a) => CelebrationCard(
              celebration: a,
              onWishTap: () => _presenter.sendWish(a.peerName, a.type),
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PeersBloc>.value(
      value: _bloc,
      child: BlocListener<PeersBloc, PeersState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: Column(
          children: [
            SegmentedControl(
              labels: ['Peers (${_peers.length})', 'Celebrations'],
              icons: const [null, Icons.cake_rounded],
              activeIndex: _activeSubTab,
              onSegmentChanged: (index) => _presenter.changeSubTab(index),
            ),
            _isLoading
                ? const CenteredLoadingIndicator(height: 300)
                : _activeSubTab == 0
                    ? _buildPeersListTab()
                    : _buildCelebrationsTab(),
          ],
        ),
      ),
    );
  }
}
