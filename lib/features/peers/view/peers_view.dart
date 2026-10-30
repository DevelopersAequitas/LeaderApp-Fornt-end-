// ==============================================================================
// File: lib/features/peers/view/peers_view.dart
// Description: Executive Peer Directory, Member Analytics & Celebrations Hub
// Framework: Flutter | Architecture: MVP View Layer (100% Pure StatelessWidget + BLoC)
// Features:
//   - Multi-tab navigation between Active Peers, At-Risk Members, and Peer Celebrations
//   - Live search querying from the AppBar and status/metric sorting filters
//   - Interactive peer card routing to PeerProfileView & P2P meeting logging
//   - Quick wish messaging and birthday/anniversary celebration dispatches
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/peers_bloc.dart';
import '../bloc/peers_event.dart';
import '../bloc/peers_state.dart';
import '../model/celebration_model.dart';
import '../model/peer_model.dart';
import 'widgets/celebration_card.dart';
import 'widgets/peer_card.dart';
import 'widgets/peers_empty_state.dart';
import 'widgets/peers_filter_bar.dart';
import 'widgets/peers_shimmer_skeleton.dart';

/// The View component of the Peers tab feature.
/// Pure StatelessWidget powered 100% by BLoC state machine.
class PeersView extends StatelessWidget {
  final String? selectedCircle;
  final String? initialSort;
  final String externalSearchQuery;

  const PeersView({
    super.key,
    this.selectedCircle,
    this.initialSort,
    this.externalSearchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PeersBloc>(
      key: ValueKey('${selectedCircle}_$initialSort'),
      create: (context) {
        final bloc = PeersBloc()
          ..add(LoadPeersData(selectedCircle: selectedCircle));
        if (initialSort != null && initialSort!.isNotEmpty) {
          bloc.add(MetricSortChanged(initialSort!));
        }
        if (externalSearchQuery.isNotEmpty) {
          bloc.add(SearchQueryChanged(externalSearchQuery));
        }
        return bloc;
      },
      child: _PeersContent(
        selectedCircle: selectedCircle,
        externalSearchQuery: externalSearchQuery,
      ),
    );
  }
}

class _PeersContent extends StatefulWidget {
  final String? selectedCircle;
  final String externalSearchQuery;

  const _PeersContent({
    this.selectedCircle,
    this.externalSearchQuery = '',
  });

  @override
  State<_PeersContent> createState() => _PeersContentState();
}

class _PeersContentState extends State<_PeersContent> {
  @override
  void didUpdateWidget(covariant _PeersContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.externalSearchQuery != oldWidget.externalSearchQuery) {
      context.read<PeersBloc>().add(
            SearchQueryChanged(widget.externalSearchQuery),
          );
    }
  }

  Widget _buildCelebrationsSubTab(
    BuildContext context,
    List<CelebrationModel> birthdays,
    List<CelebrationModel> anniversaries,
    String searchQuery,
  ) {
    final cleanQuery = searchQuery.trim().toLowerCase();
    final allCelebrations = [...birthdays, ...anniversaries];
    final celebrations = cleanQuery.isEmpty
        ? allCelebrations
        : allCelebrations.where((item) {
            return item.peerName.toLowerCase().contains(cleanQuery) ||
                item.company.toLowerCase().contains(cleanQuery) ||
                (item.designation?.toLowerCase().contains(cleanQuery) ??
                    false) ||
                (item.circleName?.toLowerCase().contains(cleanQuery) ??
                    false) ||
                item.type.toLowerCase().contains(cleanQuery);
          }).toList();

    if (celebrations.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: const Center(
                child: PeersEmptyState(
                  icon: Icons.cake_outlined,
                  title: 'No upcoming celebrations',
                  message: 'Birthdays and work anniversaries will appear here.',
                ),
              ),
            ),
          );
        },
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: celebrations.length,
      itemBuilder: (context, index) {
        final item = celebrations[index];
        return CelebrationCard(
          celebration: item,
          onWishTap: () {
            context.read<PeersBloc>().add(
                  SendWish(
                    item.peerId.isNotEmpty ? item.peerId : item.peerName,
                    item.type,
                  ),
                );
          },
        );
      },
    );
  }

  Widget _buildPeersList(
    BuildContext context,
    List<PeerModel> peers,
    bool isRoleManagementEnabled,
    String selectedSort,
    bool hasMore,
    bool isLoadingMore,
    int totalCount,
    VoidCallback onLoadMore,
  ) {
    if (peers.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: const Center(
                child: PeersEmptyState(
                  icon: Icons.people_outline,
                  title: 'No peers found',
                  message: 'Try changing your search query or filters.',
                ),
              ),
            ),
          );
        },
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: peers.length + (hasMore || peers.length >= 20 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == peers.length) {
          if (hasMore) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: OutlinedButton(
                onPressed: isLoadingMore ? null : onLoadMore,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: isLoadingMore
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Text(
                        'Load More Peers',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
              ),
            );
          }
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'All peers loaded',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }
        return PeerCard(peer: peers[index], selectedSort: selectedSort);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PeersBloc>();
    final session = SessionManager().currentSession;
    final isRoleManagementEnabled =
        session.role == UserRole.superAdmin ||
        session.role == UserRole.countryDirector;

    return BlocListener<PeersBloc, PeersState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage &&
          curr.errorMessage.isNotEmpty,
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: BlocBuilder<PeersBloc, PeersState>(
        builder: (context, state) {
          if (state.isLoading && state.allPeers.isEmpty) {
            return const PeersListSkeleton();
          }

          final filteredPeers = state.filteredPeers;
          final totalCelebrations =
              state.birthdays.length + state.anniversaries.length;
          final displayPeersCount = state.totalPeersCount > 0
              ? state.totalPeersCount
              : state.allPeers.length;

          return Column(
            children: [
              // Segmented Sub-Tab Switcher
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSegmentButton(
                        context: context,
                        label: 'All Peers ($displayPeersCount)',
                        isSelected: state.activeSubTab == 0,
                        onTap: () => bloc.add(const ToggleSubTab(0)),
                      ),
                    ),
                    Expanded(
                      child: _buildSegmentButton(
                        context: context,
                        label: 'Celebrations ($totalCelebrations)',
                        isSelected: state.activeSubTab == 1,
                        onTap: () => bloc.add(const ToggleSubTab(1)),
                      ),
                    ),
                  ],
                ),
              ),

              // Sort Bar (Only on Peers sub-tab)
              if (state.activeSubTab == 0)
                PeersFilterBar(
                  selectedStatus: state.selectedStatus,
                  selectedSort: state.selectedSort,
                  onStatusSelected: (s) => bloc.add(StatusFilterChanged(s)),
                  onSortSelected: (m) => bloc.add(MetricSortChanged(m)),
                ),

              // Sub-Tab Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    bloc.add(
                      LoadPeersData(selectedCircle: widget.selectedCircle),
                    );
                  },
                  child: state.activeSubTab == 1
                      ? _buildCelebrationsSubTab(
                          context,
                          state.birthdays,
                          state.anniversaries,
                          state.searchQuery,
                        )
                      : _buildPeersList(
                          context,
                          filteredPeers,
                          isRoleManagementEnabled,
                          state.selectedSort,
                          state.hasMore,
                          state.isLoadingMore,
                          state.totalPeersCount,
                          () => bloc.add(const LoadMorePeersData()),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSegmentButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.brandGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
