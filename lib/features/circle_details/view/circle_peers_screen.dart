import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../teams/model/teams_model.dart';
import '../bloc/circle_details_bloc.dart';
import '../bloc/circle_details_event.dart';
import '../bloc/circle_details_state.dart';
import 'widgets/circle_peers_section.dart';

/// Dedicated standalone screen for Circle Peers directory.
/// Follows the standard Peers Tab layout: live search, status filter chips,
/// and standard PeerCard items routing seamlessly to PeerProfileView.
class CirclePeersScreen extends StatelessWidget {
  final CircleTeamModel circle;

  const CirclePeersScreen({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CircleDetailsBloc>(
      create: (context) =>
          CircleDetailsBloc()..add(LoadCircleDetailsData(circleId: circle.id)),
      child: _CirclePeersContent(circle: circle),
    );
  }
}

class _CirclePeersContent extends StatefulWidget {
  final CircleTeamModel circle;

  const _CirclePeersContent({required this.circle});

  @override
  State<_CirclePeersContent> createState() => _CirclePeersContentState();
}

class _CirclePeersContentState extends State<_CirclePeersContent> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusFilters = const ['All', 'Active', 'At-Risk'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Circle Peers',
        subtitle: widget.circle.name,
        showBackButton: true,
      ),
      body: SafeArea(
        child: BlocBuilder<CircleDetailsBloc, CircleDetailsState>(
          builder: (context, state) {
            final bloc = context.read<CircleDetailsBloc>();
            final displayedPeers = state.filteredCirclePeers;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (query) =>
                            bloc.add(SearchCirclePeersEvent(query)),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.text,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search peers by name, company, designation...',
                          hintStyle: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    bloc.add(const SearchCirclePeersEvent(''));
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Status Filter Chips
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: statusFilters.map((status) {
                        final isSelected =
                            state.selectedPeerStatusFilter.toLowerCase() ==
                                status.toLowerCase();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () =>
                                bloc.add(FilterCirclePeersStatusEvent(status)),
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.secondaryBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : AppColors.border,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.25),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.text,
                                  fontSize: 11.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Standard CirclePeersSection
                  CirclePeersSection(
                    peers: displayedPeers,
                    isLoading: state.isLoadingPeers,
                    isLoadingMore: state.isLoadingMorePeers,
                    hasMore: state.hasMorePeers,
                    totalCount: state.totalPeersCount,
                    onLoadMore: () => bloc.add(
                      LoadMoreCirclePeersEvent(
                        circleId: widget.circle.id,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
