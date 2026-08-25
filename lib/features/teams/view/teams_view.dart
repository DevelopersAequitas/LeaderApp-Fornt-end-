import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/teams_bloc.dart';
import '../bloc/teams_state.dart';
import '../model/teams_model.dart';
import '../../../core/routes/app_routes.dart';
import '../presenter/teams_presenter.dart';

/// The View component of the Teams tab feature.
/// Displays an "Access Restricted" lock card over a blurred mock dashboard background.
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
    setState(() {
      _isLoading = true;
    });
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
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
    );
  }

  // --- UI Widget Builders ---

  Widget _buildMockDashboardBackground() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(height: 20, width: 150, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestrictedCard(TeamsPermissionModel permission) {
    return RestrictedAccessCard(
      title: 'Access Restricted',
      message: '',
      contentOverride: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(
                color: AppColors.text.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'As a '),
                TextSpan(
                  text: permission.role,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const TextSpan(
                  text:
                      ', you do not have permissions to access the Teams dashboard. Access is limited to Founder, Director, and Executive levels.',
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'REQUIRED CAPABILITIES',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: permission.requiredCapabilities
                      .map(
                        (cap) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE1DDF6),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            cap,
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              children: [
                const TextSpan(text: 'Logged in as: '),
                TextSpan(
                  text: permission.role,
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFounderDashboardView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMetricsGrid(),
        const SizedBox(height: 16),
        _buildIndustryFilterRow(),
        const SizedBox(height: 16),
        _buildSearchField(),
        const SizedBox(height: 16),
        _buildMyCirclesHeaderAndFilter(),
        const SizedBox(height: 12),
        if (_filteredCircles.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'No circles found matching your criteria.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          )
        else
          ..._filteredCircles.map((circle) => _buildCircleCard(circle)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFlatMetricItem({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    final totalCircles = _filteredCircles.length;
    final totalPeers = _filteredCircles.fold<int>(
      0,
      (sum, c) => sum + c.peersCount,
    );
    final avgHealth = totalCircles == 0
        ? 0
        : (_filteredCircles.fold<int>(0, (sum, c) => sum + c.healthPercentage) /
                  totalCircles)
              .round();

    double totalRevenueVal = 0.0;
    for (final c in _filteredCircles) {
      final revStr = c.revenue.replaceAll('₹', '').replaceAll('L', '').trim();
      final revVal = double.tryParse(revStr) ?? 0.0;
      totalRevenueVal += revVal;
    }
    final totalRevenue = totalRevenueVal == 0.0
        ? '₹0.0L'
        : '₹${totalRevenueVal.toStringAsFixed(1).replaceAll('.0', '')}L';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFlatMetricItem(
                  value: '$totalCircles',
                  label: 'Total Circles',
                  valueColor: AppColors.chartPrimary,
                ),
                const SizedBox(height: 20),
                _buildFlatMetricItem(
                  value: '$avgHealth%',
                  label: 'Avg Health',
                  valueColor: AppColors.engagementGold,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFlatMetricItem(
                  value: '$totalPeers',
                  label: 'Total Peers',
                  valueColor: AppColors.successDark,
                ),
                const SizedBox(height: 20),
                _buildFlatMetricItem(
                  value: totalRevenue,
                  label: 'Total Revenue',
                  valueColor: AppColors.chartPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndustryFilterRow() {
    final session = SessionManager().currentSession;
    final industries =
        session.role == UserRole.industryDirector ||
            session.role == UserRole.districtExecDirector
        ? const ['All Industries', 'Manufacturing', 'Real Estate']
        : const [
            'All Industries',
            'Manufacturing',
            'Real Estate',
            'Technology',
            'Healthcare',
            'Startups',
          ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: industries.map((ind) {
          final isSelected = _selectedIndustry == ind;
          final count = _bloc.state.allCircles
              .where((c) => c.category.toLowerCase().trim() == ind.toLowerCase().trim())
              .length;
          final label = ind == 'All Industries' ? ind : '$ind ($count)';

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () => _presenter.filterCirclesIndustry(ind),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.chartPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.chartPrimary
                        : AppColors.border,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SearchTextField(
        controller: _searchController,
        hintText: 'Search circles by name, founder, industry, city...',
      ),
    );
  }

  String _getSectionTitle() {
    if (_selectedIndustry == 'All Industries') {
      return 'All Circles in Scope';
    } else if (_selectedIndustry == 'Manufacturing') {
      return 'Manufacturing & Engineering Circles';
    } else if (_selectedIndustry == 'Real Estate') {
      return 'Real Estate, Construction & Infra Circles';
    } else {
      return '$_selectedIndustry Circles';
    }
  }

  Widget _buildMyCirclesHeaderAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _getSectionTitle(),
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          HorizontalSelectionChips(
            options: const ['All', 'Active', 'At Risk'],
            selectedOption: _selectedStatus,
            onSelected: (status) => _presenter.filterCirclesStatus(status),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleCard(CircleTeamModel circle) {
    final isActive = circle.status.toLowerCase() == 'active';
    final progressColor = isActive
        ? AppColors.successDark
        : AppColors.engagementGold;
    final statusBgColor = isActive
        ? AppColors.successLightBg
        : AppColors.dangerBg;
    final statusTextColor = isActive
        ? AppColors.successDark
        : AppColors.danger;

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.circleDetails, arguments: circle);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    circle.name,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    circle.status,
                    style: TextStyle(
                      color: statusTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${circle.category} · ${circle.location}',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: circle.healthPercentage / 100,
                color: progressColor,
                backgroundColor: AppColors.progressBg,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${circle.peersCount} peers · ${circle.healthPercentage}% health',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  circle.revenue,
                  style: TextStyle(
                    color: progressColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: circle.tags.map((tag) {
                  final isPlus = tag.startsWith('+');
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPlus
                          ? AppColors.secondaryBg
                          : AppColors.selectionBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: isPlus
                            ? AppColors.textSecondary
                            : AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRoleItem(
                  name: circle.founderName,
                  role: 'Founder',
                  isFounder: true,
                ),
                _buildRoleItem(name: circle.directorName, role: 'Director'),
                _buildRoleItem(name: circle.chairName, role: 'Chair'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleItem({
    required String name,
    required String role,
    bool isFounder = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                role,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isFounder) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.grey.shade400,
                  size: 10,
                ),
              ],
            ],
          ),
        ],
      ),
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
                    Positioned.fill(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: _buildMockDashboardBackground(),
                      ),
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                        child: Container(color: Colors.white.withOpacity(0.3)),
                      ),
                    ),
                    Center(
                      child: SingleChildScrollView(
                        child: _buildRestrictedCard(_permission!),
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
