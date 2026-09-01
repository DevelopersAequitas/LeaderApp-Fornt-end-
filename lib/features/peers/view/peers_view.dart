// ==============================================================================
// File: lib/features/peers/view/peers_view.dart
// Description: Executive Peer Directory, Member Analytics & Celebrations Hub
// Framework: Flutter | Architecture: MVP View Layer (100% Pure StatelessWidget + BLoC)
// Features:
//   - Multi-tab navigation between Active Peers, At-Risk Members, and Peer Celebrations
//   - Live search querying and status/metric sorting filters
//   - Interactive peer card routing to PeerProfileView & P2P meeting logging
//   - Quick wish messaging and birthday/anniversary celebration dispatches
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/peers_bloc.dart';
import '../bloc/peers_event.dart';
import '../bloc/peers_state.dart';
import '../model/celebration_model.dart';
import '../model/peer_model.dart';
import 'widgets/celebration_card.dart';
import 'widgets/peer_card.dart';
// import 'widgets/peer_role_management_section.dart';
import 'widgets/peers_empty_state.dart';
import 'widgets/peers_filter_bar.dart';

/// The View component of the Peers tab feature.
/// Pure StatelessWidget powered 100% by BLoC state machine.
class PeersView extends StatelessWidget {
  final String? selectedCircle;
  final String? initialSort;

  const PeersView({super.key, this.selectedCircle, this.initialSort});

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
        return bloc;
      },
      child: _PeersContent(selectedCircle: selectedCircle),
    );
  }
}

class _PeersContent extends StatelessWidget {
  final String? selectedCircle;
  final _searchController = TextEditingController();

  _PeersContent({this.selectedCircle});

  Widget _buildCelebrationsSubTab(
    BuildContext context,
    List<CelebrationModel> birthdays,
    List<CelebrationModel> anniversaries,
  ) {
    final celebrations = [...birthdays, ...anniversaries];
    if (celebrations.isEmpty) {
      return const PeersEmptyState(
        icon: Icons.cake_outlined,
        title: 'No upcoming celebrations',
        message: 'Birthdays and work anniversaries will appear here.',
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
            context.read<PeersBloc>().add(SendWish(item.peerName, item.type));
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
      return const PeersEmptyState(
        icon: Icons.people_outline,
        title: 'No peers found',
        message: 'Try changing your search query or filters.',
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
                          fontWeight: FontWeight.w700,
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
            return const CenteredLoadingIndicator(height: 300);
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

              // Filter Bar (Only on Peers sub-tab)
              if (state.activeSubTab == 0)
                PeersFilterBar(
                  searchController: _searchController,
                  selectedStatus: state.selectedStatus,
                  selectedSort: state.selectedSort,
                  onStatusSelected: (s) => bloc.add(StatusFilterChanged(s)),
                  onSortSelected: (m) => bloc.add(MetricSortChanged(m)),
                ),

              // Sub-Tab Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    bloc.add(LoadPeersData(selectedCircle: selectedCircle));
                  },
                  child: state.activeSubTab == 1
                      ? _buildCelebrationsSubTab(
                          context,
                          state.birthdays,
                          state.anniversaries,
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
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
            color: isSelected ? AppColors.text : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
