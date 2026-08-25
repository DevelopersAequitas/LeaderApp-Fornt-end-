import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/peers_bloc.dart';
import '../bloc/peers_state.dart';
import '../model/peer_model.dart';
import '../model/celebration_model.dart';
import '../presenter/peers_presenter.dart';

/// The View component of the Peers tab feature.
/// Renders segment options for Peers list and Celebrations, search filters, and detail cards.
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
    setState(() {
      _isLoading = true;
    });
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
    setState(() {
      _isLoading = false;
    });
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
      setState(() {
        _activeSubTab = index;
      });
    }
  }

  // --- UI Widget Helpers ---

  Widget _buildPeerCard(PeerModel peer) {
    // Dynamic value display badge matching selection
    String badgeText = '';
    Color badgeColor = AppColors.infoBg;
    Color badgeTextColor = AppColors.primary;

    if (_selectedSort == 'Impact') {
      badgeText = '${peer.impactCount} lives';
      badgeColor = AppColors.successBg;
      badgeTextColor = AppColors.success;
    } else if (_selectedSort == 'Deals') {
      badgeText = peer.dealsFormatted;
      badgeColor = AppColors.warningBg;
      badgeTextColor = AppColors.warning;
    } else if (_selectedSort == 'Coins') {
      badgeText = '${peer.coins} coins';
      badgeColor = AppColors.coinBg;
      badgeTextColor = AppColors.coinColor;
    } else if (_selectedSort == 'Attendance') {
      badgeText = '${peer.attendance} attendance';
      badgeColor = AppColors.attendanceBg;
      badgeTextColor = AppColors.attendanceColor;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.peerProfile, arguments: peer);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Initials Avatar
            InitialsAvatar(
              name: peer.name,
              radius: 24,
              backgroundColor: peer.status == 'At Risk'
                  ? AppColors.danger
                  : AppColors.primary,
              fontSize: 15,
            ),
            const SizedBox(width: 16),
            // Content metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        peer.name,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: badgeTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    peer.company,
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${peer.circle} · ${peer.location}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    peer.tags,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleManagementSection() {
    final currentRole = SessionManager().currentRole;
    final isSuperAdmin = currentRole == UserRole.superAdmin;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Role Management',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Circle Founder role cannot be changed once assigned.',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _buildRoleManagementRow(
            'Change Chair (per circle)',
            () => Navigator.of(context).pushNamed(AppRoutes.roleManagement),
          ),
          const SizedBox(height: 12),
          _buildRoleManagementRow(
            'Change Circle Director',
            () => Navigator.of(context).pushNamed(AppRoutes.roleManagement),
          ),
          if (isSuperAdmin) ...[
            const SizedBox(height: 12),
            _buildRoleManagementRow(
              'Change Industry Director',
              () => Navigator.of(context).pushNamed(AppRoutes.roleManagement),
            ),
            const SizedBox(height: 12),
            _buildRoleManagementRow(
              'Change District Exec',
              () => Navigator.of(context).pushNamed(AppRoutes.roleManagement),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleManagementRow(String label, VoidCallback onManage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        ElevatedButton(
          onPressed: onManage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.selectionBg,
            foregroundColor: AppColors.primary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Manage',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _buildPeersListTab() {
    final currentRole = SessionManager().currentRole;
    final isRoleManagementVisible =
        currentRole == UserRole.industryDirector ||
        currentRole == UserRole.superAdmin;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search peers box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: SearchTextField(
            controller: _searchController,
            hintText: 'Search peers...',
          ),
        ),
        // Filter rows (All, Active, At Risk)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: HorizontalSelectionChips(
            options: const ['All', 'Active', 'At Risk'],
            selectedOption: _selectedStatus,
            onSelected: (status) => _presenter.filterStatus(status),
          ),
        ),
        // Sort rows (Impact, Deals, Coins, Attendance)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: HorizontalSelectionChips(
            options: const ['Impact', 'Deals', 'Coins', 'Attendance'],
            selectedOption: _selectedSort,
            onSelected: (metric) => _presenter.sortMetric(metric),
          ),
        ),
        const SizedBox(height: 12),
        // List Builder
        if (_peers.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'No peers found matching your criteria.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          )
        else
          ..._peers.map((peer) => _buildPeerCard(peer)),
        if (isRoleManagementVisible) ...[_buildRoleManagementSection()],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCelebrationCard(CelebrationModel celebration) {
    final isBirthday = celebration.type == 'birthday';
    final cardBgColor = isBirthday
        ? AppColors.dangerBg
        : AppColors.successBg;
    final cardIconColor = isBirthday
        ? AppColors.danger
        : AppColors.success;
    final btnBgColor = isBirthday
        ? AppColors.dangerBg
        : AppColors.successBg;
    final btnTextColor = isBirthday
        ? AppColors.danger
        : AppColors.success;
    final btnLabel = isBirthday ? 'Wish 🎂' : 'Wish 🤝';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Celebration Icon Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cardBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              isBirthday ? Icons.cake_rounded : Icons.star_rounded,
              color: cardIconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  celebration.peerName,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${celebration.date} · ${celebration.company}',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Wish Action Button
          InkWell(
            onTap: () =>
                _presenter.sendWish(celebration.peerName, celebration.type),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: btnBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                btnLabel,
                style: TextStyle(
                  color: btnTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationsTab() {
    if (SessionManager().currentRole == UserRole.countryDirector ||
        SessionManager().currentRole == UserRole.superAdmin) {
      return _buildCountryDirectorCelebrationsTab();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Birthdays Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.cake_rounded,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Birthdays This Month',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_birthdays.length} peer celebrating',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '1 peer celebrating',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (_birthdays.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              'No birthdays celebrating this month.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          )
        else
          ..._birthdays.map((b) => _buildCelebrationCard(b)),
        const SizedBox(height: 24),
        // Business Anniversaries Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Business Anniversaries This Month',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_anniversaries.length} peer celebrating',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '1 peer celebrating',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (_anniversaries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              'No business anniversaries celebrating this month.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          )
        else
          ..._anniversaries.map((a) => _buildCelebrationCard(a)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCountryDirectorCelebrationsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // CELEBRATIONS Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryBg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(19),
                    topRight: Radius.circular(19),
                  ),
                ),
                child: Text(
                  'CELEBRATIONS',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Side-by-side cells
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Birthday Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.warningBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.warningBorder),
                        ),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.cake_outlined,
                              color: AppColors.warning,
                              size: 24,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Birthday',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '12 Mar',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Anniversary Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.successBorder),
                        ),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.album_outlined,
                              color: AppColors.success,
                              size: 24,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Anniversary',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '18 Jun',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // CIRCLE MEETINGS Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryBg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(19),
                    topRight: Radius.circular(19),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CIRCLE MEETINGS',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mumbai Tech Sunrise',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Meetings List
              _buildCountryDirectorMeetingRow('1', 'Aug', 'Monthly Circle Meeting', '7:30 AM · Grand Ballroom, Mumbai', 'Confirmed'),
              const Divider(height: 1, color: AppColors.border),
              _buildCountryDirectorMeetingRow('5', 'Sep', 'Monthly Circle Meeting', '7:30 AM · The Leela, Mumbai', 'Open'),
              const Divider(height: 1, color: AppColors.border),
              _buildCountryDirectorMeetingRow('3', 'Oct', 'Monthly Circle Meeting', '7:30 AM · Grand Ballroom, Mumbai', 'Planned'),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCountryDirectorMeetingRow(
    String day,
    String month,
    String title,
    String timeLocation,
    String status,
  ) {
    Color statusBg = Colors.grey.shade100;
    Color statusText = Colors.grey.shade600;

    if (status == 'Confirmed') {
      statusBg = AppColors.successBg;
      statusText = AppColors.success;
    } else if (status == 'Open') {
      statusBg = AppColors.infoBg;
      statusText = AppColors.info;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Date block badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  month,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Meeting details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeLocation,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusText,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
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
