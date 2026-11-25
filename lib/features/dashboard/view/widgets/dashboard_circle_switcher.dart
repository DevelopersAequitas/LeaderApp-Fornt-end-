import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../model/dashboard_circle_option.dart';

/// Sentinel value emitted when the user picks the "all circles in my scope" option.
const String kAllCirclesValue = 'All Circles';

enum _CircleFilterAxis { country, district, industry }

class _FilterChoice {
  final String value;
  final int count;

  const _FilterChoice({required this.value, required this.count});
}

/// Compact scope selector pill in the header / welcome bar that opens a
/// searchable, Country/District/Industry-filterable Circle switcher sheet.
class DashboardCircleSwitcher extends StatelessWidget {
  final List<DashboardCircleOption> circles;
  final List<String> industries;
  final String? selectedCircleId;
  final bool isGlobalRole;
  final ValueChanged<String> onSelected;

  const DashboardCircleSwitcher({
    super.key,
    required this.circles,
    this.industries = const [],
    required this.selectedCircleId,
    required this.isGlobalRole,
    required this.onSelected,
  });

  String get _allLabel => isGlobalRole ? 'All Circles' : 'All Assigned';

  String get _currentLabel {
    for (final c in circles) {
      if (c.id == selectedCircleId) return c.name;
    }
    return _allLabel;
  }

  static void showScopeSheet({
    required BuildContext context,
    required List<DashboardCircleOption> circles,
    List<String> industries = const [],
    required String? selectedCircleId,
    required bool isGlobalRole,
    required ValueChanged<String> onSelected,
  }) {
    final allLabel = isGlobalRole ? 'All Circles' : 'All Assigned Circles';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColor.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _CircleSwitcherSheetContent(
          circles: circles,
          industries: industries,
          selectedCircleId: selectedCircleId,
          allLabel: allLabel,
          onSelected: onSelected,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (circles.length < 2) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasFilter = selectedCircleId != null && selectedCircleId!.isNotEmpty;

    return Semantics(
      button: true,
      label: 'Organizational scope: $_currentLabel. Tap to switch Circle.',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        onTap: () => showScopeSheet(
          context: context,
          circles: circles,
          industries: industries,
          selectedCircleId: selectedCircleId,
          isGlobalRole: isGlobalRole,
          onSelected: onSelected,
        ),
        child: Container(
          height: 38,
          constraints: const BoxConstraints(maxWidth: 148),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: hasFilter
                ? AppColor.primaryContainer
                : (isDark
                    ? AppColor.darkSurfaceSubtle
                    : AppColor.surfaceContainerLow),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: hasFilter
                  ? AppColor.infoBorder
                  : (isDark ? AppColor.darkBorder : AppColor.outline),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 15,
                color: hasFilter
                    ? AppColor.primary
                    : (isDark
                        ? AppColor.darkTextSecondary
                        : AppColor.lightTextSecondary),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _currentLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    color: hasFilter
                        ? AppColor.onPrimaryContainer
                        : (isDark
                            ? AppColor.darkTextPrimary
                            : AppColor.lightTextPrimary),
                    fontWeight: hasFilter ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: hasFilter
                    ? AppColor.primary
                    : (isDark
                        ? AppColor.darkTextSecondary
                        : AppColor.lightTextSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleSwitcherSheetContent extends StatefulWidget {
  final List<DashboardCircleOption> circles;
  final List<String> industries;
  final String? selectedCircleId;
  final String allLabel;
  final ValueChanged<String> onSelected;

  const _CircleSwitcherSheetContent({
    required this.circles,
    required this.industries,
    required this.selectedCircleId,
    required this.allLabel,
    required this.onSelected,
  });

  @override
  State<_CircleSwitcherSheetContent> createState() =>
      _CircleSwitcherSheetContentState();
}

class _CircleSwitcherSheetContentState
    extends State<_CircleSwitcherSheetContent> {
  late final TextEditingController _searchController;
  late final TextEditingController _axisSearchController;
  String _query = '';
  String _axisQuery = '';
  String? _selectedCountry;
  String? _selectedDistrict;
  String? _selectedIndustry;
  _CircleFilterAxis? _activeAxis;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _axisSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _axisSearchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _query.trim().isNotEmpty ||
      _selectedCountry != null ||
      _selectedDistrict != null ||
      _selectedIndustry != null;

  void _clearAllFilters() {
    HapticFeedback.selectionClick();
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedCountry = null;
      _selectedDistrict = null;
      _selectedIndustry = null;
    });
  }

  List<_FilterChoice> _buildAxisChoices(_CircleFilterAxis axis) {
    final counts = <String, int>{};

    switch (axis) {
      case _CircleFilterAxis.country:
        for (final c in widget.circles) {
          final val = c.country.trim();
          if (val.isNotEmpty) {
            counts[val] = (counts[val] ?? 0) + 1;
          }
        }
        break;

      case _CircleFilterAxis.district:
        final countryScoped = _selectedCountry == null
            ? widget.circles
            : widget.circles
                .where(
                  (c) =>
                      c.country.trim().toLowerCase() ==
                      _selectedCountry!.toLowerCase(),
                )
                .toList();
        for (final c in countryScoped) {
          final val = c.district.trim();
          if (val.isNotEmpty) {
            counts[val] = (counts[val] ?? 0) + 1;
          }
        }
        break;

      case _CircleFilterAxis.industry:
        final geoScoped = widget.circles.where((c) {
          final matchCountry = _selectedCountry == null ||
              c.country.trim().toLowerCase() == _selectedCountry!.toLowerCase();
          final matchDistrict = _selectedDistrict == null ||
              c.district.trim().toLowerCase() ==
                  _selectedDistrict!.toLowerCase();
          return matchCountry && matchDistrict;
        });
        for (final c in geoScoped) {
          final val = c.industry.trim();
          if (val.isNotEmpty) {
            counts[val] = (counts[val] ?? 0) + 1;
          }
        }
        // Preserve canonical directory industries even when zero-matched in geo scope
        for (final ind in widget.industries) {
          final clean = ind.trim();
          if (clean.isNotEmpty) {
            counts.putIfAbsent(clean, () => 0);
          }
        }
        break;
    }

    final userCity = SessionManager().currentSession.city.trim().toLowerCase();
    final list = counts.entries
        .map((e) => _FilterChoice(value: e.key, count: e.value))
        .toList()
      ..sort((a, b) {
        if (axis == _CircleFilterAxis.district && userCity.isNotEmpty) {
          final aIsUserCity = a.value.toLowerCase() == userCity;
          final bIsUserCity = b.value.toLowerCase() == userCity;
          if (aIsUserCity != bIsUserCity) {
            return aIsUserCity ? -1 : 1;
          }
        }
        if ((a.count > 0) != (b.count > 0)) {
          return a.count > 0 ? -1 : 1;
        }
        return a.value.toLowerCase().compareTo(b.value.toLowerCase());
      });
    return list;
  }

  List<DashboardCircleOption> _filterCircles() {
    final q = _query.trim().toLowerCase();
    return widget.circles.where((c) {
      if (_selectedCountry != null &&
          c.country.trim().toLowerCase() != _selectedCountry!.toLowerCase()) {
        return false;
      }
      if (_selectedDistrict != null &&
          c.district.trim().toLowerCase() != _selectedDistrict!.toLowerCase()) {
        return false;
      }
      if (_selectedIndustry != null &&
          c.industry.trim().toLowerCase() != _selectedIndustry!.toLowerCase()) {
        return false;
      }
      if (q.isNotEmpty) {
        final hay =
            '${c.name} ${c.district} ${c.country} ${c.industry}'.toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  void _openAxisPicker(_CircleFilterAxis axis) {
    HapticFeedback.selectionClick();
    _axisSearchController.clear();
    setState(() {
      _axisQuery = '';
      _activeAxis = axis;
    });
  }

  void _applyAxisSelection(_CircleFilterAxis axis, String? value) {
    HapticFeedback.selectionClick();
    setState(() {
      switch (axis) {
        case _CircleFilterAxis.country:
          _selectedCountry = value;
          // Auto-clear District if it no longer belongs to the picked Country
          if (value != null && _selectedDistrict != null) {
            final validInCountry = widget.circles.any(
              (c) =>
                  c.country.trim().toLowerCase() == value.toLowerCase() &&
                  c.district.trim().toLowerCase() ==
                      _selectedDistrict!.toLowerCase(),
            );
            if (!validInCountry) {
              _selectedDistrict = null;
            }
          }
          break;
        case _CircleFilterAxis.district:
          _selectedDistrict = value;
          break;
        case _CircleFilterAxis.industry:
          _selectedIndustry = value;
          break;
      }
      _activeAxis = null;
      _axisQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? AppColor.darkSurfaceElevated : AppColor.lightSurface;
    final textPrimary =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final textSecondary =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
    final dividerColor = isDark ? AppColor.darkDivider : AppColor.divider;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.84;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusSheet),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColor.darkBorder
                          : AppColor.outlineStrong,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Flexible(
                  child: AnimatedSwitcher(
                    duration: AppMotion.duration(context, AppMotion.tabSwitch),
                    switchInCurve: AppMotion.easeOut,
                    switchOutCurve: AppMotion.easeIn,
                    layoutBuilder: (currentChild, previousChildren) => Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        ...previousChildren,
                        ?currentChild,
                      ],
                    ),
                    child: _activeAxis != null
                        ? _buildAxisPickerView(
                            axis: _activeAxis!,
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            dividerColor: dividerColor,
                          )
                        : _buildMainCircleListView(
                            isDark: isDark,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            dividerColor: dividerColor,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCircleListView({
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color dividerColor,
  }) {
    final filtered = _filterCircles();

    return Column(
      key: const ValueKey('circle_list_view'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sheet Header
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 10, 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Circle Scope',
                      style: AppTypography.titleLarge.copyWith(
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _hasActiveFilters
                          ? 'Showing ${filtered.length} of ${widget.circles.length} Circles'
                          : '${widget.circles.length} Circles available in your scope',
                      style: AppTypography.bodySmall.copyWith(
                        color: textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              if (_hasActiveFilters)
                TextButton(
                  onPressed: _clearAllFilters,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    'Reset',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close_rounded, color: textSecondary),
              ),
            ],
          ),
        ),

        // 1. Instant Search Input
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            style: AppTypography.bodyMedium.copyWith(color: textPrimary),
            decoration: InputDecoration(
              hintText: 'Search Circle, city, industry...',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      tooltip: 'Clear search',
                      icon: Icon(
                        Icons.close_rounded,
                        size: 17,
                        color: textSecondary,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
          ),
        ),

        // 2. Three Cascading Filter Dropdowns: Country · District · Industry
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1.0);
              final useWrap = constraints.maxWidth < 330 || textScale > 1.25;

              final countryBtn = _buildFilterDropdownButton(
                defaultLabel: 'Country',
                selectedValue: _selectedCountry,
                icon: Icons.public_rounded,
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => _openAxisPicker(_CircleFilterAxis.country),
              );
              final districtBtn = _buildFilterDropdownButton(
                defaultLabel: 'City',
                selectedValue: _selectedDistrict,
                icon: Icons.location_city_outlined,
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => _openAxisPicker(_CircleFilterAxis.district),
              );
              final industryBtn = _buildFilterDropdownButton(
                defaultLabel: 'Industry',
                selectedValue: _selectedIndustry,
                icon: Icons.category_outlined,
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => _openAxisPicker(_CircleFilterAxis.industry),
              );

              if (useWrap) {
                return Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [countryBtn, districtBtn, industryBtn],
                );
              }
              return Row(
                children: [
                  Expanded(child: countryBtn),
                  const SizedBox(width: 6),
                  Expanded(child: districtBtn),
                  const SizedBox(width: 6),
                  Expanded(child: industryBtn),
                ],
              );
            },
          ),
        ),

        Divider(height: 1, thickness: 1, color: dividerColor),

        // 3. Default "All Circles" + Matching Circles List
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            children: [
              if (!_hasActiveFilters)
                _buildCircleTile(
                  context: context,
                  label: widget.allLabel,
                  subtitle:
                      'Aggregated view across all ${widget.circles.length} Circles',
                  isSelected: widget.selectedCircleId == null,
                  value: kAllCirclesValue,
                  icon: Icons.public_rounded,
                  isGlobalAll: true,
                ),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 28,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list_off_rounded,
                          size: 32,
                          color: textSecondary,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No Circles match these filters',
                          style: AppTypography.titleSmall.copyWith(
                            color: textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Clear search or change Country, District, or Industry to view all Circles.',
                          style: AppTypography.bodySmall.copyWith(
                            color: textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _clearAllFilters,
                          child: const Text('Show All Circles'),
                        ),
                      ],
                    ),
                  )
                else ...[
                  if (!_hasActiveFilters)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                      child: Text(
                        'CIRCLES IN SCOPE',
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 10.5,
                          letterSpacing: 0.6,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  for (final c in filtered)
                    _buildCircleTile(
                      context: context,
                      label: c.name,
                      subtitle: [
                        if (c.district.isNotEmpty) c.district,
                        if (c.country.isNotEmpty) c.country,
                        if (c.industry.isNotEmpty) c.industry,
                      ].join(' · '),
                      peersCount: c.peersCount,
                      isSelected: c.id == widget.selectedCircleId,
                      value: c.id,
                      icon: Icons.hub_outlined,
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAxisPickerView({
    required _CircleFilterAxis axis,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color dividerColor,
  }) {
    final (title, allOptionLabel, selectedValue) = switch (axis) {
      _CircleFilterAxis.country => (
          'Filter by Country',
          'All Countries',
          _selectedCountry,
        ),
      _CircleFilterAxis.district => (
          'Filter by City',
          'All Cities',
          _selectedDistrict,
        ),
      _CircleFilterAxis.industry => (
          'Filter by Industry',
          'All Industries',
          _selectedIndustry,
        ),
    };

    final choices = _buildAxisChoices(axis);
    final aq = _axisQuery.trim().toLowerCase();
    final filteredChoices = aq.isEmpty
        ? choices
        : choices.where((e) => e.value.toLowerCase().contains(aq)).toList();

    return Column(
      key: ValueKey('axis_${axis.name}'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 10, 12, 8),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Back to Circles',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _activeAxis = null;
                    _axisQuery = '';
                  });
                },
                icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      '${choices.length} ${choices.length == 1 ? 'option' : 'options'} in scope',
                      style: AppTypography.labelSmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedValue != null)
                TextButton(
                  onPressed: () => _applyAxisSelection(axis, null),
                  child: Text(
                    'Reset',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (choices.length > 6)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _axisSearchController,
              onChanged: (v) => setState(() => _axisQuery = v),
              style: AppTypography.bodyMedium.copyWith(color: textPrimary),
              decoration: InputDecoration(
                hintText:
                    'Search ${axis == _CircleFilterAxis.district ? 'city' : axis.name}...',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
              ),
            ),
          ),
        Divider(height: 1, thickness: 1, color: dividerColor),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            children: [
                if (aq.isEmpty)
                  _buildFilterChoiceRow(
                    label: allOptionLabel,
                    count: null,
                    isSelected: selectedValue == null,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () => _applyAxisSelection(axis, null),
                  ),
                if (choices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                    child: Text(
                      axis == _CircleFilterAxis.country
                          ? 'No separate country metadata is attached to these Circles yet.'
                          : 'No ${axis.name} metadata available in this selection.',
                      style: AppTypography.bodySmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  )
                else
                  for (final choice in filteredChoices)
                    _buildFilterChoiceRow(
                      label: choice.value,
                      count: choice.count,
                      isSelected: selectedValue != null &&
                          selectedValue.toLowerCase() ==
                              choice.value.toLowerCase(),
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => _applyAxisSelection(axis, choice.value),
                    ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilterDropdownButton({
    required String defaultLabel,
    required String? selectedValue,
    required IconData icon,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    final isActive = selectedValue != null && selectedValue.isNotEmpty;
    final bg = isActive
        ? (isDark
            ? AppColor.primary.withValues(alpha: 0.20)
            : AppColor.primaryContainer)
        : (isDark
            ? AppColor.darkSurfaceSubtle
            : AppColor.surfaceContainerLow);
    final border = isActive
        ? AppColor.infoBorder
        : (isDark ? AppColor.darkBorder : AppColor.outline);
    final fg = isActive
        ? (isDark ? const Color(0xFF93C5FD) : AppColor.onPrimaryContainer)
        : textPrimary;

    return Semantics(
      button: true,
      label: isActive ? '$defaultLabel: $selectedValue' : 'Filter by $defaultLabel',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13.5,
                color: isActive ? AppColor.primary : textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  isActive ? selectedValue : defaultLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    fontSize: 12,
                    color: fg,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isActive ? AppColor.primary : textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChoiceRow({
    required String label,
    required int? count,
    required bool isSelected,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      tileColor: isSelected
          ? (isDark
              ? AppColor.primary.withValues(alpha: 0.16)
              : AppColor.primaryContainer)
          : null,
      title: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodyMedium.copyWith(
          color: isSelected
              ? (isDark ? Colors.white : AppColor.onPrimaryContainer)
              : textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColor.darkSurfaceSubtle
                    : AppColor.surfaceContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
              child: Text(
                '$count',
                style: AppTypography.labelSmall.copyWith(
                  color: textSecondary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          if (isSelected) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: AppColor.primary,
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildCircleTile({
    required BuildContext context,
    required String label,
    String? subtitle,
    int peersCount = 0,
    required bool isSelected,
    required String value,
    required IconData icon,
    bool isGlobalAll = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final textSecondary =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
    final cleanSub = subtitle?.trim() ?? '';

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      tileColor: isSelected
          ? (isDark
              ? AppColor.primary.withValues(alpha: 0.16)
              : AppColor.primaryContainer)
          : null,
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primary.withValues(alpha: 0.14)
              : (isDark
                  ? AppColor.darkSurfaceSubtle
                  : AppColor.surfaceContainer),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? AppColor.primary : textSecondary,
        ),
      ),
      title: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: isSelected || isGlobalAll
              ? FontWeight.w600
              : FontWeight.w500,
          color: isSelected
              ? (isDark ? Colors.white : AppColor.onPrimaryContainer)
              : textPrimary,
        ),
      ),
      subtitle: cleanSub.isNotEmpty
          ? Text(
              cleanSub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 11.5,
                color: textSecondary,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isGlobalAll && peersCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColor.darkSurfaceSubtle
                    : AppColor.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                border: Border.all(
                  color: isDark ? AppColor.darkBorder : AppColor.outline,
                ),
              ),
              child: Text(
                '$peersCount Peers',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 10.5,
                  color: textSecondary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          if (isSelected) ...[
            const SizedBox(width: 6),
            const Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: AppColor.primary,
            ),
          ],
        ],
      ),
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).pop();
        widget.onSelected(value);
      },
    );
  }
}
