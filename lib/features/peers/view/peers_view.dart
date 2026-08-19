import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
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

  Widget _buildSegmentControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Peers (8) Segment
          Expanded(
            child: InkWell(
              onTap: () => _presenter.changeSubTab(0),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _activeSubTab == 0
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Peers (${_peers.length})',
                  style: TextStyle(
                    color: _activeSubTab == 0
                        ? Colors.white
                        : const Color(0xFF8B9CB4),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          // Celebrations Segment
          Expanded(
            child: InkWell(
              onTap: () => _presenter.changeSubTab(1),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _activeSubTab == 1
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cake_rounded,
                      size: 16,
                      color: _activeSubTab == 1
                          ? Colors.white
                          : const Color(0xFF8B9CB4),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Celebrations',
                      style: TextStyle(
                        color: _activeSubTab == 1
                            ? Colors.white
                            : const Color(0xFF8B9CB4),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final isSelected = _selectedStatus == status;
    return InkWell(
      onTap: () => _presenter.filterStatus(status),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF8B9CB4),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String metric) {
    final isSelected = _selectedSort == metric;
    return InkWell(
      onTap: () => _presenter.sortMetric(metric),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          metric,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF8B9CB4),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildPeerCard(PeerModel peer) {
    // Dynamic value display badge matching selection
    String badgeText = '';
    Color badgeColor = const Color(0xFFE8F0FE);
    Color badgeTextColor = AppColors.primary;

    if (_selectedSort == 'Impact') {
      badgeText = '${peer.impactCount} lives';
      badgeColor = const Color(0xFFE8F5E9);
      badgeTextColor = const Color(0xFF2E7D32);
    } else if (_selectedSort == 'Deals') {
      badgeText = peer.dealsFormatted;
      badgeColor = const Color(0xFFFFF3E0);
      badgeTextColor = const Color(0xFFFF9800);
    } else if (_selectedSort == 'Coins') {
      badgeText = '${peer.coins} coins';
      badgeColor = const Color(0xFFFEFDE7);
      badgeTextColor = const Color(0xFFFBC02D);
    } else if (_selectedSort == 'Attendance') {
      badgeText = '${peer.attendance} attendance';
      badgeColor = const Color(0xFFF3E5F5);
      badgeTextColor = const Color(0xFF8E24AA);
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
          border: Border.all(color: const Color(0xFFEDEFF3)),
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
            CircleAvatar(
              radius: 24,
              backgroundColor: peer.status == 'At Risk'
                  ? const Color(0xFFD57D72)
                  : const Color(0xFF102640),
              child: Text(
                peer.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
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
              color: Color(0xFF8B9CB4),
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
        border: Border.all(color: const Color(0xFFEDEFF3)),
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
          _buildRoleManagementRow('Change Chair (per circle)', () {}),
          const SizedBox(height: 12),
          _buildRoleManagementRow('Change Circle Director', () {}),
          if (isSuperAdmin) ...[
            const SizedBox(height: 12),
            _buildRoleManagementRow('Change Industry Director', () {}),
            const SizedBox(height: 12),
            _buildRoleManagementRow('Change District Exec', () {}),
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
            backgroundColor: const Color(0xFFEDF2FA),
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
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search peers...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.grey.shade400,
                size: 22,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        // Filter rows (All, Active, At Risk)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: Row(
            children: [
              _buildStatusChip('All'),
              const SizedBox(width: 8),
              _buildStatusChip('Active'),
              const SizedBox(width: 8),
              _buildStatusChip('At Risk'),
            ],
          ),
        ),
        // Sort rows (Impact, Deals, Coins, Attendance)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: Row(
            children: [
              _buildSortChip('Impact'),
              const SizedBox(width: 4),
              _buildSortChip('Deals'),
              const SizedBox(width: 4),
              _buildSortChip('Coins'),
              const SizedBox(width: 4),
              _buildSortChip('Attendance'),
            ],
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
              style: TextStyle(color: Color(0xFF8B9CB4), fontSize: 14),
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
        ? const Color(0xFFFDF2F2)
        : const Color(0xFFE8F5E9);
    final cardIconColor = isBirthday
        ? const Color(0xFFC62828)
        : const Color(0xFF2E7D32);
    final btnBgColor = isBirthday
        ? const Color(0xFFFFEBEE)
        : const Color(0xFFE8F5E9);
    final btnTextColor = isBirthday
        ? const Color(0xFFC62828)
        : const Color(0xFF2E7D32);
    final btnLabel = isBirthday ? 'Wish 🎂' : 'Wish 🤝';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF3)),
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
            border: Border.all(color: const Color(0xFFEDEFF3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F6F9),
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
                          color: const Color(0xFFFFF9F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFEBD5)),
                        ),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.cake_outlined,
                              color: Color(0xFFD97706),
                              size: 24,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Birthday',
                              style: TextStyle(
                                color: Color(0xFFB45309),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '12 Mar',
                              style: TextStyle(
                                color: Color(0xFF78350F),
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
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDCFCE7)),
                        ),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.album_outlined,
                              color: Color(0xFF15803D),
                              size: 24,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Anniversary',
                              style: TextStyle(
                                color: Color(0xFF15803D),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '18 Jun',
                              style: TextStyle(
                                color: Color(0xFF14532D),
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
            border: Border.all(color: const Color(0xFFEDEFF3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F6F9),
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
              const Divider(height: 1, color: Color(0xFFEDEFF3)),
              _buildCountryDirectorMeetingRow('5', 'Sep', 'Monthly Circle Meeting', '7:30 AM · The Leela, Mumbai', 'Open'),
              const Divider(height: 1, color: Color(0xFFEDEFF3)),
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
      statusBg = const Color(0xFFE8F5E9);
      statusText = const Color(0xFF2E7D32);
    } else if (status == 'Open') {
      statusBg = const Color(0xFFE8F0FE);
      statusText = const Color(0xFF1565C0);
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
              color: const Color(0xFF0F2541),
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
            _buildSegmentControls(),
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(64.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : _activeSubTab == 0
                ? _buildPeersListTab()
                : _buildCelebrationsTab(),
          ],
        ),
      ),
    );
  }
}
