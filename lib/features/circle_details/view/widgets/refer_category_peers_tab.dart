import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/peers_repository.dart';
import '../../../../data/repositories/teams_repository.dart';
import '../../../peers/model/peer_model.dart';
import '../../../teams/model/teams_model.dart';
import '../../model/circle_sub_industry_model.dart';

/// Tab 1 of [ReferCategoryBottomSheet]: Global Peers directory with search,
/// pagination, and one-tap 'Refer' button per peer.
class ReferCategoryPeersTab extends StatefulWidget {
  final CircleTeamModel circle;
  final SubIndustryItemModel category;

  const ReferCategoryPeersTab({
    super.key,
    required this.circle,
    required this.category,
  });

  @override
  State<ReferCategoryPeersTab> createState() => _ReferCategoryPeersTabState();
}

class _ReferCategoryPeersTabState extends State<ReferCategoryPeersTab> {
  final PeersRepository _peersRepo = PeersRepositoryImpl();
  final TeamsRepository _teamsRepo = TeamsRepositoryImpl();
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  Timer? _debounce;

  List<PeerModel> _peers = const [];
  final Set<String> _referredPeerIds = <String>{};
  String? _submittingPeerId;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
    _fetchPeers(page: 1);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || _isLoading) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200 && _currentPage < _lastPage) {
      _fetchPeers(page: _currentPage + 1, append: true);
    }
  }

  Future<void> _fetchPeers({required int page, bool append = false}) async {
    if (append) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() => _isLoading = true);
    }

    final res = await _peersRepo.getPeers(
      page: page,
      perPage: 40,
      global: true,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    if (!mounted) return;
    final fetched = res.data ?? const <PeerModel>[];
    setState(() {
      _isLoading = false;
      _isLoadingMore = false;
      _currentPage = res.meta?.currentPage ?? page;
      _lastPage = res.meta?.lastPage ?? (fetched.length >= 40 ? page + 1 : page);
      _peers = append ? [..._peers, ...fetched] : fetched;
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      _searchQuery = value.trim();
      _fetchPeers(page: 1);
    });
  }

  Future<void> _referPeer(PeerModel peer) async {
    final peerKey = peer.id.isNotEmpty ? peer.id : peer.name;
    if (_referredPeerIds.contains(peerKey) || _submittingPeerId != null) return;

    setState(() => _submittingPeerId = peerKey);
    final res = await _teamsRepo.referCategory(
      widget.circle.id,
      {
        'source_type': 'peer',
        if (peer.id.isNotEmpty) 'peer_id': peer.id,
        'peer_name': peer.name,
        if (peer.phone != null && peer.phone!.isNotEmpty)
          'peer_phone': peer.phone,
        if (peer.email != null && peer.email!.isNotEmpty)
          'peer_email': peer.email,
        'peer_company': peer.company,
        'peer_city': peer.location,
        'category_id': widget.category.id,
        'category_name': widget.category.name,
        'notes':
            'Referred ${peer.name} for ${widget.category.name} in ${widget.circle.name}',
      },
    );

    if (!mounted) return;
    setState(() {
      _submittingPeerId = null;
      if (res.success) {
        _referredPeerIds.add(peerKey);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res.success
              ? '${peer.name} referred for ${widget.category.name}'
              : (res.message ?? 'Could not submit referral'),
        ),
        backgroundColor: res.success ? AppColor.success : AppColor.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: SearchTextField(
            controller: _searchController,
            hintText: 'Search all peers by name, company, city...',
            onChanged: _onSearchChanged,
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColor.primaryBlue),
                )
              : _peers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No peers found matching your search.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColor.lightTextSecondary,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: _peers.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _peers.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColor.primaryBlue,
                                ),
                              ),
                            ),
                          );
                        }
                        final peer = _peers[index];
                        final peerKey =
                            peer.id.isNotEmpty ? peer.id : peer.name;
                        final isReferred = _referredPeerIds.contains(peerKey);
                        final isSubmitting = _submittingPeerId == peerKey;
                        return _buildPeerRow(
                          peer: peer,
                          isReferred: isReferred,
                          isSubmitting: isSubmitting,
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildPeerRow({
    required PeerModel peer,
    required bool isReferred,
    required bool isSubmitting,
  }) {
    final subtitleParts = <String>[
      if (peer.company.trim().isNotEmpty) peer.company.trim(),
      if (peer.location.trim().isNotEmpty) peer.location.trim(),
    ];
    final categoryLabel =
        (peer.level4Category ?? peer.tags).trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.lightBorder),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.peerProfile,
              arguments: peer,
            ),
            child: InitialsAvatar(
              name: peer.name.toUpperCase(),
              imageUrl: peer.avatarUrl,
              radius: 19,
              backgroundColor: AppColor.primaryBlue,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.peerProfile,
                arguments: peer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          peer.name.toUpperCase(),
                          style: AppTypography.labelLarge.copyWith(
                            fontSize: 12.5,
                            color: AppColor.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (peer.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          size: 13,
                          color: AppColor.primaryBlue,
                        ),
                      ],
                    ],
                  ),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitleParts.join(' · '),
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 10.5,
                        color: AppColor.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (categoryLabel.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      categoryLabel,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 9.5,
                        color: AppColor.primaryBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: isReferred || isSubmitting ? null : () => _referPeer(peer),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                gradient: isReferred ? null : AppColor.brandGradient,
                color: isReferred ? AppColor.successBg : null,
                borderRadius: BorderRadius.circular(8),
                border: isReferred
                    ? Border.all(color: AppColor.successBorder)
                    : null,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.6,
                        color: AppColor.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isReferred ? 'Referred' : 'Refer',
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 10.5,
                            color:
                                isReferred ? AppColor.success : AppColor.white,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          isReferred
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 12,
                          color: isReferred ? AppColor.success : AppColor.white,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

