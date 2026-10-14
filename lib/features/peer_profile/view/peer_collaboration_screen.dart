// ==============================================================================
// File: lib/features/peer_profile/view/peer_collaboration_screen.dart
// Description: Executive Peer Collaboration Hub displaying live asks & initiatives
// Framework: Flutter | Architecture: MVP View Layer (Remote API / Bearer Token)
// Standards: Strict compliance with RULEBOOK.md & design_standards.md (max w500 font)
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/datasources/remote/peers_remote_datasource.dart';
import '../../peers/model/peer_model.dart';
import '../model/peer_profile_model.dart';
import 'peer_collaboration_detail_screen.dart';

/// Full-screen display showing live Collaboration asks & initiatives from API.
/// Filterable by status: All, Open, In Progress, Fulfilled, Closed.
class PeerCollaborationScreen extends StatefulWidget {
  final PeerModel peer;
  final PeerProfileDetailModel? details;
  final List<PeerCollaborationItemModel>? initialCollaborations;

  const PeerCollaborationScreen({
    super.key,
    required this.peer,
    this.details,
    this.initialCollaborations,
  });

  @override
  State<PeerCollaborationScreen> createState() => _PeerCollaborationScreenState();
}

class _PeerCollaborationScreenState extends State<PeerCollaborationScreen> {
  final _searchController = TextEditingController();
  final _remoteDataSource = PeersRemoteDataSource();

  bool _isLoading = true;
  String? _errorMessage;
  String _selectedStatus = 'All'; // 'All', 'Open', 'In Progress', 'Fulfilled', 'Closed'
  String _searchQuery = '';
  List<PeerCollaborationItemModel> _collaborations = [];

  static const List<String> _statusOptions = [
    'All',
    'Open',
    'In Progress',
    'Fulfilled',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCollaborations != null && widget.initialCollaborations!.isNotEmpty) {
      _collaborations = List.from(widget.initialCollaborations!);
      _isLoading = false;
    }
    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.trim().toLowerCase();
        });
      }
    });
    _loadCollaborations();
  }

  @override
  void reassemble() {
    super.reassemble();
    _loadCollaborations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Loads live collaboration data from /leader/asks/collaboration/user/{userId}.
  Future<void> _loadCollaborations() async {
    if (!mounted) return;
    if (_collaborations.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final userId = widget.peer.id.trim();
      final response = userId.isNotEmpty
          ? await _remoteDataSource.getUserCollaborations(userId)
          : await _remoteDataSource.getMyCollaborations();

      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _collaborations = response.data!;
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (!response.success && response.message != null && response.message!.isNotEmpty) {
            _errorMessage = response.message;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to connect to collaboration services. Please try again.';
        });
      }
    }
  }

  bool _matchesStatus(PeerCollaborationItemModel item, String statusFilter) {
    if (statusFilter == 'All') return true;
    final s = item.status.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    final target = statusFilter.toLowerCase().replaceAll(' ', '_');

    if (target == 'open') {
      return s == 'open' || s == 'active';
    }
    if (target == 'in_progress') {
      return s.contains('progress') || s == 'in_progress' || s == 'discussion';
    }
    if (target == 'fulfilled') {
      return s.contains('fulfill') || s == 'completed';
    }
    if (target == 'closed') {
      return s.contains('clos') || s == 'inactive';
    }
    return s == target;
  }

  int _countForStatus(String statusFilter) {
    if (statusFilter == 'All') return _collaborations.length;
    return _collaborations.where((item) => _matchesStatus(item, statusFilter)).length;
  }

  List<PeerCollaborationItemModel> get _filteredList {
    return _collaborations.where((item) {
      // 1. Status filter
      if (!_matchesStatus(item, _selectedStatus)) {
        return false;
      }

      // 2. Search query filter
      if (_searchQuery.isNotEmpty) {
        final title = item.title.toLowerCase();
        final desc = item.description.toLowerCase();
        final partner = item.authorName.isNotEmpty ? item.authorName.toLowerCase() : widget.peer.name.toLowerCase();
        final company = item.authorCompany.isNotEmpty ? item.authorCompany.toLowerCase() : widget.peer.company.toLowerCase();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Peer Collaborations',
        subtitle: widget.peer.name,
        showBackButton: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // 1. Search Bar
            _buildSearchBar(),

            // 2. Status Filter Chips: All, Open, In Progress, Fulfilled, Closed with Gradient Selection
            _buildStatusFilterBar(),

            // 3. Content List / Shimmer Skeleton / Empty State
            Expanded(
              child: _isLoading
                  ? _buildShimmerSkeleton()
                  : RefreshIndicator(
                      onRefresh: _loadCollaborations,
                      color: AppColors.primary,
                      child: _errorMessage != null
                          ? _buildErrorState()
                          : _filteredList.isEmpty
                              ? _buildEmptyState()
                              : ListView.separated(
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  itemCount: _filteredList.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    return _buildCollaborationCard(_filteredList[index]);
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: 'Search asks by title, objective, company...',
            hintStyle: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8),
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // --- Status Filter Chips with Gradient Selection ---
  Widget _buildStatusFilterBar() {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 4, bottom: 6),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _statusOptions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = _statusOptions[index];
          final isSelected = _selectedStatus == status;
          final count = _countForStatus(status);

          return InkWell(
            onTap: () {
              setState(() {
                _selectedStatus = status;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: isSelected ? AppColors.brandGradient : null,
                color: isSelected ? null : Colors.white,
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.border, width: 0.8),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '$status ($count)',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Collaboration Card matching Peers Tab PeerCard layout ---
  Widget _buildCollaborationCard(PeerCollaborationItemModel item) {
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
            builder: (_) => PeerCollaborationDetailScreen(
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
            // Row 1: Avatar, Author, Company, Status Pill (Exact PeerCard top row layout)
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
                            : (widget.peer.circle.isNotEmpty ? widget.peer.circle : 'Member'),
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
                const SizedBox(width: 8),

                // Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusBg(item.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getStatusTextColor(item.status),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.statusLabel.isNotEmpty ? item.statusLabel : 'Open',
                        style: TextStyle(
                          color: _getStatusTextColor(item.status),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Row 2: Title / Objective
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
                height: 1.35,
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
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // Row 3: Metadata Badges (Category, Responses Count, Matches Count, Date)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Category badge
                if (item.categoryName.isNotEmpty || item.flowName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 11,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.categoryName.isNotEmpty ? item.categoryName : item.flowName,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Responses Count
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 11,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.responsesCount} Responses',
                        style: const TextStyle(
                          color: Color(0xFFB45309),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Matches Count
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBBF7D0), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.groups_outlined,
                        size: 11,
                        color: Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.matchesCount} Matches',
                        style: const TextStyle(
                          color: Color(0xFF15803D),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Created date
                if (formattedDate.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Shimmer Skeleton Loader ---
  Widget _buildShimmerSkeleton() {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: 4,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ShimmerBox(width: 40, height: 40, borderRadius: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerBox(width: 130, height: 12, borderRadius: 4),
                        SizedBox(height: 6),
                        ShimmerBox(width: 90, height: 10, borderRadius: 4),
                      ],
                    ),
                  ),
                  const ShimmerBox(width: 50, height: 20, borderRadius: 10),
                ],
              ),
              const SizedBox(height: 14),
              const ShimmerBox(width: double.infinity, height: 14, borderRadius: 4),
              const SizedBox(height: 6),
              const ShimmerBox(width: 200, height: 12, borderRadius: 4),
              const SizedBox(height: 12),
              Row(
                children: const [
                  ShimmerBox(width: 70, height: 22, borderRadius: 6),
                  SizedBox(width: 6),
                  ShimmerBox(width: 90, height: 22, borderRadius: 6),
                  SizedBox(width: 6),
                  ShimmerBox(width: 80, height: 22, borderRadius: 6),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Empty State ---
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.handshake_outlined,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Collaborations Found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No collaboration asks matched "$_searchQuery".'
                  : (_selectedStatus != 'All'
                      ? 'No "$_selectedStatus" collaboration asks found for ${widget.peer.name}.'
                      : '${widget.peer.name} has not published any collaboration asks yet.'),
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
              _errorMessage ?? 'Unable to fetch collaboration asks.',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadCollaborations,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }


}
