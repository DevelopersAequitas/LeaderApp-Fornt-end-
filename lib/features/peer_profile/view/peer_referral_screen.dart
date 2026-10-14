import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/datasources/remote/peers_remote_datasource.dart';
import '../../peers/model/peer_model.dart';
import '../model/peer_profile_model.dart';
import 'peer_referral_detail_screen.dart';

/// Full-screen display showing live Referral asks from API.
/// Filterable by status: All, Open, In Progress, Fulfilled, Closed.
class PeerReferralScreen extends StatefulWidget {
  final PeerModel peer;
  final PeerProfileDetailModel? details;
  final List<PeerCollaborationItemModel>? initialReferrals;

  const PeerReferralScreen({
    super.key,
    required this.peer,
    this.details,
    this.initialReferrals,
  });

  @override
  State<PeerReferralScreen> createState() => _PeerReferralScreenState();
}

class _PeerReferralScreenState extends State<PeerReferralScreen> {
  final PeersRemoteDataSource _remoteDataSource = PeersRemoteDataSource();
  final TextEditingController _searchController = TextEditingController();

  // Status Filters: All, Open, In Progress, Fulfilled, Closed
  static const List<String> _statusFilters = [
    'All',
    'Open',
    'In Progress',
    'Fulfilled',
    'Closed',
  ];

  List<PeerCollaborationItemModel> _referrals = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _selectedStatus = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialReferrals != null && widget.initialReferrals!.isNotEmpty) {
      _referrals = List.from(widget.initialReferrals!);
    }
    _loadReferrals();
  }

  @override
  void didUpdateWidget(covariant PeerReferralScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.peer.id != widget.peer.id) {
      _loadReferrals();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Loads live referral asks data from /leader/asks/referral/user/{userId}.
  Future<void> _loadReferrals() async {
    if (_referrals.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final userId = widget.peer.id.trim();
      final response = userId.isNotEmpty
          ? await _remoteDataSource.getUserReferralAsks(userId)
          : await _remoteDataSource.getMyReferralAsks();

      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _referrals = response.data!;
            _isLoading = false;
            _errorMessage = null;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_referrals.isEmpty) {
            _errorMessage = (response.message != null && response.message!.isNotEmpty)
                ? response.message
                : 'Unable to fetch referral asks.';
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_referrals.isEmpty) {
            _errorMessage = 'Unable to connect to referral services. Please try again.';
          }
        });
      }
    }
  }

  bool _matchesStatus(PeerCollaborationItemModel item, String statusFilter) {
    if (statusFilter == 'All') return true;
    final itemStatus = item.status.toLowerCase().trim();
    final filter = statusFilter.toLowerCase().trim();

    if (filter == 'in progress') {
      return itemStatus == 'in_progress' ||
          itemStatus == 'inprogress' ||
          itemStatus.contains('progress') ||
          itemStatus.contains('discussion') ||
          itemStatus.contains('pending');
    }
    if (filter == 'fulfilled') {
      return itemStatus == 'fulfilled' || itemStatus == 'completed';
    }
    if (filter == 'closed') {
      return itemStatus == 'closed' || itemStatus == 'clos';
    }
    if (filter == 'open') {
      return itemStatus == 'open' || itemStatus == 'active';
    }
    return itemStatus == filter;
  }

  int _countForStatus(String statusFilter) {
    if (statusFilter == 'All') return _referrals.length;
    return _referrals.where((item) => _matchesStatus(item, statusFilter)).length;
  }

  List<PeerCollaborationItemModel> get _filteredList {
    return _referrals.where((item) {
      if (!_matchesStatus(item, _selectedStatus)) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final title = item.title.toLowerCase();
        final desc = item.description.toLowerCase();
        final partner = item.authorName.isNotEmpty
            ? item.authorName.toLowerCase()
            : widget.peer.name.toLowerCase();
        final company = item.authorCompany.isNotEmpty
            ? item.authorCompany.toLowerCase()
            : widget.peer.company.toLowerCase();
        final cat = item.categoryName.toLowerCase();
        if (!title.contains(_searchQuery) &&
            !desc.contains(_searchQuery) &&
            !partner.contains(_searchQuery) &&
            !company.contains(_searchQuery) &&
            !cat.contains(_searchQuery)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Color _getStatusBg(String status) {
    final s = status.toLowerCase();
    if (s.contains('open') || s.contains('active')) {
      return const Color(0xFFDCFCE7);
    }
    if (s.contains('progress') || s.contains('discussion') || s.contains('pending')) {
      return const Color(0xFFFEF3C7);
    }
    if (s.contains('fulfill') || s.contains('completed')) {
      return const Color(0xFFF3E8FF);
    }
    if (s.contains('closed') || s.contains('clos')) {
      return const Color(0xFFF1F5F9);
    }
    return const Color(0xFFEFF6FF);
  }

  Color _getStatusTextColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('open') || s.contains('active')) {
      return const Color(0xFF15803D);
    }
    if (s.contains('progress') || s.contains('discussion') || s.contains('pending')) {
      return const Color(0xFFB45309);
    }
    if (s.contains('fulfill') || s.contains('completed')) {
      return const Color(0xFF7E22CE);
    }
    if (s.contains('closed') || s.contains('clos')) {
      return const Color(0xFF64748B);
    }
    return AppColors.primary;
  }

  String _formatDate(String rawDate) {
    if (rawDate.isEmpty) return '';
    try {
      final dt = DateTime.tryParse(rawDate);
      if (dt != null) {
        const monthNames = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${dt.day} ${monthNames[dt.month - 1]} ${dt.year}';
      }
      return rawDate.split('T').first;
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredList;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Peer Referrals',
        subtitle: widget.peer.name.isNotEmpty
            ? widget.peer.name
            : 'Executive Referral Asks',
        showBackButton: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Search & Status Filter Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 10),
                  _buildStatusFilterChips(),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // Content Area
            Expanded(
              child: _isLoading && _referrals.isEmpty
                  ? const CenteredLoadingIndicator(height: 260)
                  : _errorMessage != null && _referrals.isEmpty
                      ? _buildErrorState()
                      : RefreshIndicator(
                          onRefresh: _loadReferrals,
                          child: filtered.isEmpty
                              ? _buildEmptyState()
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  itemCount: filtered.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    return _buildReferralCard(filtered[index]);
                                  },
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Search Bar ---
  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.text,
              ),
              decoration: const InputDecoration(
                hintText: 'Search referral asks, category, description...',
                hintStyle: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  // --- Status Filter Chips ---
  Widget _buildStatusFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _statusFilters.map((status) {
          final isSelected = _selectedStatus == status;
          final count = _countForStatus(status);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedStatus = status;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.brandGradient : null,
                  color: isSelected ? null : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- Referral Card matching executive layout ---
  Widget _buildReferralCard(PeerCollaborationItemModel item) {
    final authorName = item.authorName.isNotEmpty
        ? item.authorName
        : (item.authorDisplayName.isNotEmpty ? item.authorDisplayName : widget.peer.name);
    final authorCompany = item.authorCompany.isNotEmpty
        ? item.authorCompany
        : widget.peer.company;
    final authorAvatar = item.authorAvatarUrl.isNotEmpty
        ? item.authorAvatarUrl
        : (widget.peer.avatarUrl ?? '');

    final formattedDate = _formatDate(item.createdAt);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PeerReferralDetailScreen(
              ask: item,
              peer: widget.peer,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Avatar, Author, Company, Status Pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InitialsAvatar(
                  name: authorName,
                  imageUrl: authorAvatar.isNotEmpty ? authorAvatar : null,
                  radius: 20,
                  fontSize: 13,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        authorCompany.isNotEmpty
                            ? (widget.peer.circle.isNotEmpty
                                ? '$authorCompany · ${widget.peer.circle}'
                                : authorCompany)
                            : (widget.peer.circle.isNotEmpty
                                ? widget.peer.circle
                                : 'Circle Leader'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusBg(item.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.statusLabel,
                    style: TextStyle(
                      color: _getStatusTextColor(item.status),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Row 2: Flow Badge & Category Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.swap_horiz_rounded,
                        size: 11,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.flowName.isNotEmpty ? item.flowName : 'Find a Referral',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.categoryName.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      item.categoryName,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 10),

            // Row 3: Title & Description
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.description.isNotEmpty && item.description != item.title) ...[
              const SizedBox(height: 4),
              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),

            // Row 4: Metrics (Responses, Matches, Date)
            Row(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 13,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.responsesCount > 0 ? item.responsesCount : (item.responses?.length ?? 0)} Responses',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.groups_outlined,
                      size: 13,
                      color: Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.matchesCount} Matches',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (formattedDate.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 11,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Empty State ---
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Icon(
                Icons.swap_horiz_rounded,
                size: 28,
                color: Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Referral Asks Found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No referral asks matched "$_searchQuery".'
                  : (_selectedStatus != 'All'
                      ? 'No "$_selectedStatus" referral asks found for ${widget.peer.name}.'
                      : '${widget.peer.name} has not published any referral asks yet.'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --- Error State ---
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.danger,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Unable to fetch referral asks.',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadReferrals,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
