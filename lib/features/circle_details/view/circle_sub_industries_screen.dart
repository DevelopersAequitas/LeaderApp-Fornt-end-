import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../teams/model/teams_model.dart';
import '../bloc/circle_details_bloc.dart';
import '../bloc/circle_details_event.dart';
import '../bloc/circle_details_state.dart';
import '../model/circle_sub_industry_model.dart';
import 'widgets/circle_sub_industries_section.dart';

/// Dedicated two-tab screen for Circle Categories (Open & Closed)
/// matching Peers Global Unity's `CircleCategoriesScreen`.
class CircleSubIndustriesScreen extends StatefulWidget {
  final CircleTeamModel circle;
  final int initialTabIndex;

  const CircleSubIndustriesScreen({
    super.key,
    required this.circle,
    this.initialTabIndex = 0,
  });

  @override
  State<CircleSubIndustriesScreen> createState() =>
      _CircleSubIndustriesScreenState();
}

class _CircleSubIndustriesScreenState extends State<CircleSubIndustriesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _searchController;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<SubIndustryItemModel> _filterItems(List<SubIndustryItemModel> items) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((item) {
      final nameMatch = item.name.toLowerCase().contains(q);
      final sectorMatch = item.breadcrumb.toLowerCase().contains(q);
      final peerMatch = (item.occupant?.name.toLowerCase().contains(q) ??
              false) ||
          (item.occupant?.company.toLowerCase().contains(q) ?? false);
      return nameMatch || sectorMatch || peerMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CircleDetailsBloc>(
      create: (_) => CircleDetailsBloc()
        ..add(LoadCircleDetailsData(circleId: widget.circle.id)),
      child: BlocBuilder<CircleDetailsBloc, CircleDetailsState>(
        builder: (context, state) {
          final openItems = _filterItems(
            state.subIndustries?.openSubIndustries ?? const [],
          );
          final closedItems = _filterItems(
            state.subIndustries?.activeSubIndustries ?? const [],
          );

          return Scaffold(
            backgroundColor: AppColor.lightBackground,
            appBar: CustomAppBar(
              title: widget.circle.name,
              subtitle: widget.circle.category,
              showBackButton: true,
              showSearch: true,
              isSearching: _isSearching,
              searchController: _searchController,
              searchHint: 'Search categories, sectors, peers...',
              onSearchTap: () => setState(() => _isSearching = true),
              onSearchChanged: (val) => setState(() => _searchQuery = val),
              onSearchClose: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _isSearching = false;
                });
              },
            ),
            body: Column(
              children: [
                Container(
                  color: AppColor.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColor.primaryBlue,
                    unselectedLabelColor: AppColor.lightTextSecondary,
                    indicatorColor: AppColor.primaryBlue,
                    indicatorWeight: 2.5,
                    dividerColor: AppColor.lightBorder,
                    labelStyle: AppTypography.titleSmall.copyWith(fontSize: 13),
                    unselectedLabelStyle:
                        AppTypography.bodyMedium.copyWith(fontSize: 13),
                    tabs: [
                      Tab(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_open_rounded, size: 15),
                            const SizedBox(width: 6),
                            Text('Open (${openItems.length})'),
                          ],
                        ),
                      ),
                      Tab(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline_rounded, size: 15),
                            const SizedBox(width: 6),
                            Text('Closed (${closedItems.length})'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.isLoadingSubIndustries &&
                          state.subIndustries == null
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColor.primaryBlue,
                          ),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildCategoryList(
                              context,
                              items: openItems,
                              isOpenTab: true,
                            ),
                            _buildCategoryList(
                              context,
                              items: closedItems,
                              isOpenTab: false,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context, {
    required List<SubIndustryItemModel> items,
    required bool isOpenTab,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            isOpenTab
                ? 'No open categories found.'
                : 'No closed categories found.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColor.lightTextSecondary,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColor.primaryBlue,
      onRefresh: () async {
        context.read<CircleDetailsBloc>().add(
              LoadCircleDetailsData(circleId: widget.circle.id),
            );
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return isOpenTab
              ? CircleOpenCategoryCard(item: item, circle: widget.circle)
              : CircleClosedCategoryCard(item: item, circle: widget.circle);
        },
      ),
    );
  }
}
