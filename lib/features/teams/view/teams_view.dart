// ==============================================================================
// File: lib/features/teams/view/teams_view.dart
// Description: Multi-Circle Teams Hierarchy, Industry Clusters & Growth Metrics
// Framework: Flutter | Architecture: MVP View Layer (100% Pure StatelessWidget + BLoC)
// Features:
//   - Industry cluster filter chips and circle status toggles (All, Active, Growing, Inactive)
//   - Circle health indicators (Capacity percentage, member roster, revenue yield)
//   - Real-time search query filtering over managed circles
//   - Role-based restriction fallback view for non-authorized leadership tiers
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/teams_bloc.dart';
import '../bloc/teams_event.dart';
import '../bloc/teams_state.dart';
import 'widgets/teams_circle_card.dart';
import 'widgets/teams_industry_filter_chips.dart';
import 'widgets/teams_metrics_banner.dart';
import 'widgets/teams_restricted_placeholder.dart';
import 'widgets/teams_search_bar.dart';
import 'widgets/teams_status_filter_header.dart';

/// The View component of the Teams tab feature.
/// 100% Pure StatelessWidget powered by BLoC state machine.
class TeamsView extends StatelessWidget {
  final String? selectedCircle;
  const TeamsView({super.key, this.selectedCircle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TeamsBloc>(
      key: ValueKey(selectedCircle),
      create: (context) =>
          TeamsBloc()..add(LoadTeamsData(selectedCircle: selectedCircle)),
      child: _TeamsContent(selectedCircle: selectedCircle),
    );
  }
}

class _TeamsContent extends StatelessWidget {
  final String? selectedCircle;
  final TextEditingController _searchController = TextEditingController();

  _TeamsContent({this.selectedCircle});

  String _getSectionTitle(String selectedIndustry) {
    if (selectedIndustry == 'All Industries' || selectedIndustry.isEmpty) {
      return 'ALL CIRCLES';
    }
    return '${selectedIndustry.toUpperCase()} CIRCLES';
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TeamsBloc>();

    return BlocListener<TeamsBloc, TeamsState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage && curr.errorMessage.isNotEmpty,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: AppColors.danger,
          ),
        );
      },
      child: BlocBuilder<TeamsBloc, TeamsState>(
        builder: (context, state) {
          if (state.isLoading && state.allCircles.isEmpty) {
            return const CenteredLoadingIndicator(height: 300);
          }

          if (state.permission != null && state.permission!.isRestricted) {
            return TeamsRestrictedPlaceholder(
              permission: state.permission!,
            );
          }

          final circles = state.filteredCircles;

          return RefreshIndicator(
            onRefresh: () async {
              bloc.add(LoadTeamsData(selectedCircle: selectedCircle));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TeamsMetricsBanner(circles: state.allCircles),
                  const SizedBox(height: 8),
                  TeamsIndustryFilterChips(
                    industries: state.availableIndustries,
                    industriesList: state.industriesList,
                    allCircles: state.allCircles,
                    selectedIndustry: state.selectedIndustryFilter,
                    onIndustrySelected: (ind) =>
                        bloc.add(IndustryCirclesFilterChanged(ind)),
                  ),
                  const SizedBox(height: 4),
                  TeamsStatusFilterHeader(
                    title: _getSectionTitle(state.selectedIndustryFilter),
                    selectedStatus: state.selectedStatusFilter,
                    onStatusSelected: (st) =>
                        bloc.add(StatusCirclesFilterChanged(st)),
                  ),
                  const SizedBox(height: 8),
                  TeamsSearchBar(
                    controller: _searchController,
                    onChanged: (q) =>
                        bloc.add(SearchCirclesQueryChanged(q)),
                  ),
                  const SizedBox(height: 6),
                  if (circles.isEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded, color: AppColors.textSecondary, size: 36),
                          SizedBox(height: 8),
                          Text(
                            'No circles found matching your filter criteria',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: circles.length,
                      itemBuilder: (context, index) {
                        return TeamsCircleCard(circle: circles[index]);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
