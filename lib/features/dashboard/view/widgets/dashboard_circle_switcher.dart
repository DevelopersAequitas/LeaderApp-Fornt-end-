import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';
import '../../model/dashboard_circle_option.dart';

/// Sentinel value emitted when the user picks the "all circles in my scope" option.
const String kAllCirclesValue = 'All Circles';

/// Compact pill shown in the dashboard app bar that opens a bottom sheet to switch
/// between the circles inside the user's role scope. Hidden when only one circle exists.
class DashboardCircleSwitcher extends StatelessWidget {
  final List<DashboardCircleOption> circles;
  final String? selectedCircleId;
  final bool isGlobalRole;
  final ValueChanged<String> onSelected;

  const DashboardCircleSwitcher({
    super.key,
    required this.circles,
    required this.selectedCircleId,
    required this.isGlobalRole,
    required this.onSelected,
  });

  String get _allLabel => isGlobalRole ? 'All Circles' : 'All My Circles';

  String get _currentLabel {
    for (final c in circles) {
      if (c.id == selectedCircleId) return c.name;
    }
    return _allLabel;
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColor.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final maxHeight = MediaQuery.of(sheetContext).size.height * 0.7;
        return Material(
          color: AppColor.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColor.lightBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                    child: Text(
                      'Switch Circle',
                      style: AppTypography.titleSmall.copyWith(
                        fontSize: 15,
                        color: AppColor.lightTextPrimary,
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      children: [
                        _buildTile(
                          context: sheetContext,
                          label: _allLabel,
                          isSelected: selectedCircleId == null,
                          value: kAllCirclesValue,
                          icon: Icons.layers_rounded,
                        ),
                        for (final c in circles)
                          _buildTile(
                            context: sheetContext,
                            label: c.name,
                            isSelected: c.id == selectedCircleId,
                            value: c.id,
                            icon: Icons.donut_large_rounded,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required String value,
    required IconData icon,
  }) {
    return ListTile(
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: isSelected ? AppColor.badgeBlueBg : null,
      leading: Icon(
        icon,
        size: 18,
        color: isSelected ? AppColor.primaryBlue : AppColor.lightTextSecondary,
      ),
      title: Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodyMedium.copyWith(
          fontSize: 13,
          color: isSelected ? AppColor.primaryBlue : AppColor.lightTextPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: AppColor.primaryBlue,
            )
          : null,
      onTap: () {
        Navigator.of(context).pop();
        onSelected(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (circles.length < 2) return const SizedBox.shrink();

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _openSheet(context),
      child: Container(
        height: 36,
        constraints: const BoxConstraints(maxWidth: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColor.lightSurfaceSubtle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.lightBorder, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.swap_horiz_rounded,
              size: 16,
              color: AppColor.primaryBlue,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                _currentLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 11,
                  color: AppColor.lightTextPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColor.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
