import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/teams_bloc.dart';
import '../bloc/teams_state.dart';
import '../model/teams_model.dart';
import '../presenter/teams_presenter.dart';
import 'widgets/teams_circle_card.dart';
import 'widgets/teams_industry_filter_chips.dart';
import 'widgets/teams_metrics_banner.dart';
import 'widgets/teams_restricted_placeholder.dart';
import 'widgets/teams_search_bar.dart';
import 'widgets/teams_status_filter_header.dart';

/// The View component of the Teams tab feature.
class TeamsView extends StatefulWidget {
  final String? selectedCircle;
  const TeamsView({super.key, this.selectedCircle});

  @override
  State<TeamsView> createState() => _TeamsViewState();
}

class _TeamsViewState extends State<TeamsView> implements TeamsViewContract {
  late final TeamsBloc _bloc;
  late final TeamsPresenter _presenter;
  late final TextEditingController _searchController;

  bool _isLoading = false;
  TeamsPermissionModel? _permission;
  List<CircleTeamModel> _filteredCircles = const [];
  String _selectedStatus = 'All';
  String _selectedIndustry = 'All Industries';

  @override
  void initState() {
    super.initState();
    _bloc = TeamsBloc();
    _presenter = TeamsPresenter(view: this, bloc: _bloc);
    _searchController = TextEditingController();

    _searchController.addListener(() {
      _presenter.searchCircles(_searchController.text);
    });

    _presenter.load(selectedCircle: widget.selectedCircle);
  }

  @override
  void didUpdateWidget(covariant TeamsView oldWidget) {
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

  // --- TeamsViewContract Implementations ---

  @override
  void onTeamsLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void onTeamsLoaded() {
    setState(() {
      _isLoading = false;
      _permission = _bloc.state.permission;
      _filteredCircles = _bloc.state.filteredCircles;
      _selectedStatus = _bloc.state.selectedStatusFilter;
      _selectedIndustry = _bloc.state.selectedIndustryFilter;
    });
  }

  @override
  void onTeamsError(String error) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
    );
  }

  String _getSectionTitle() {
    if (_selectedIndustry == 'All Industries' || _selectedIndustry.isEmpty) {
      return 'All Circles';
    }
    return '$_selectedIndustry Circles';
  }

  Widget _buildFounderDashboardView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TeamsMetricsBanner(circles: _filteredCircles),
        const SizedBox(height: 10),
        TeamsIndustryFilterChips(
          industries: _bloc.state.availableIndustries,
          allCircles: _bloc.state.allCircles,
          selectedIndustry: _selectedIndustry,
          onIndustrySelected: (ind) => _presenter.filterCirclesIndustry(ind),
        ),
        const SizedBox(height: 10),
        TeamsSearchBar(controller: _searchController),
        const SizedBox(height: 10),
        TeamsStatusFilterHeader(
          title: _getSectionTitle(),
          selectedStatus: _selectedStatus,
          onStatusSelected: (status) => _presenter.filterCirclesStatus(status),
        ),
        const SizedBox(height: 8),
        if (_filteredCircles.isEmpty)
          const Padding(
            padding: EdgeInsets.all(28.0),
            child: Text(
              'No circles found matching your criteria.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          )
        else
          ..._filteredCircles.map((circle) => TeamsCircleCard(circle: circle)),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TeamsBloc>.value(
      value: _bloc,
      child: BlocListener<TeamsBloc, TeamsState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: _isLoading || _permission == null
            ? const CenteredLoadingIndicator(height: 300)
            : _permission!.isRestricted
                ? SizedBox(
                    height: 580,
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: SingleChildScrollView(
                            physics: NeverScrollableScrollPhysics(),
                            child: TeamsRestrictedBackgroundSkeleton(),
                          ),
                        ),
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                            child: Container(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        Center(
                          child: SingleChildScrollView(
                            child: TeamsRestrictedPlaceholder(
                              permission: _permission!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildFounderDashboardView(),
      ),
    );
  }
}
