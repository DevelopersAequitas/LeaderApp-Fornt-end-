import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/datasources/remote/peers_remote_datasource.dart';
import '../../peers/model/peer_model.dart';
import '../model/peer_profile_model.dart';

class PeerIntroducedByScreen extends StatefulWidget {
  final PeerModel peer;
  final PeerProfileDetailModel details;

  const PeerIntroducedByScreen({
    super.key,
    required this.peer,
    required this.details,
  });

  @override
  State<PeerIntroducedByScreen> createState() => _PeerIntroducedByScreenState();
}

class _PeerIntroducedByScreenState extends State<PeerIntroducedByScreen> {
  bool _isLoading = true;
  List<PeerModel> _peers = [];

  @override
  void initState() {
    super.initState();
    _fetchIntroducedPeers();
  }

  Future<void> _fetchIntroducedPeers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await PeersRemoteDataSource().getIntroducedPeers(widget.peer.id);
      if (response.success && response.data != null) {
        setState(() {
          _peers = response.data!;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Peers Introduced By',
        subtitle: widget.peer.name,
        showBackButton: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const CenteredLoadingIndicator()
            : RefreshIndicator(
                onRefresh: _fetchIntroducedPeers,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'INTRODUCED MEMBERS',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_peers.isEmpty)
                        _buildEmptyState()
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _peers.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = _peers[index];
                            final initials = item.name.isNotEmpty
                                ? item.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
                                : 'P';
                            final subtitleStr = [
                              if (item.designation != null && item.designation!.isNotEmpty) item.designation!,
                              if (item.company.isNotEmpty) item.company,
                            ].join(' · ');

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 0.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppColors.brandGradient,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      initials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.name,
                                                style: const TextStyle(
                                                  color: AppColors.text,
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDCFCE7),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                item.status.isNotEmpty ? item.status : 'Active',
                                                style: const TextStyle(
                                                  color: Color(0xFF15803D),
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (subtitleStr.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            subtitleStr,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (item.circle.isNotEmpty) ...[
                                              const Icon(
                                                Icons.group_outlined,
                                                size: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  item.circle,
                                                  style: const TextStyle(
                                                    color: AppColors.textSecondary,
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                            if (item.location.isNotEmpty)
                                              Text(
                                                item.location,
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            SquareRoundedGradientIcon(
              icon: Icons.person_add_disabled_outlined,
              boxSize: 52,
              iconSize: 26,
              borderRadius: 14,
              showBorder: true,
            ),
            const SizedBox(height: 14),
            const Text(
              'No Introduced Peers Yet',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Peers introduced by this member will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
