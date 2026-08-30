import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/role_permission_model.dart';
import 'capability_tile.dart';

/// MD3-styled category grouping section with category icon, counter, and bulk toggle.
class RoleCategorySection extends StatelessWidget {
  final String categoryName;
  final List<AppCapability> capabilities;
  final List<String> enabledCapabilityIds;
  final ValueChanged<String> onToggleCapability;
  final ValueChanged<bool> onToggleCategoryAll;

  const RoleCategorySection({
    super.key,
    required this.categoryName,
    required this.capabilities,
    required this.enabledCapabilityIds,
    required this.onToggleCapability,
    required this.onToggleCategoryAll,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'navigation & access':
        return Icons.explore_outlined;
      case 'core operations':
        return Icons.hub_outlined;
      case 'financial control':
        return Icons.account_balance_wallet_outlined;
      case 'administration':
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (capabilities.isEmpty) return const SizedBox.shrink();

    final activeCount = capabilities.where((c) => enabledCapabilityIds.contains(c.id)).length;
    final isAllCategoryEnabled = activeCount == capabilities.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.selectionBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_getCategoryIcon(categoryName), size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        categoryName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: activeCount > 0 ? AppColors.selectionBg : AppColors.secondaryBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$activeCount/${capabilities.length}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: activeCount > 0 ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                isAllCategoryEnabled ? 'All ON' : 'All OFF',
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 2),
              SizedBox(
                height: 28,
                child: Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: isAllCategoryEnabled,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.25),
                    inactiveThumbColor: AppColors.disabled,
                    inactiveTrackColor: AppColors.border,
                    onChanged: onToggleCategoryAll,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          ...capabilities.map((cap) {
            final isEnabled = enabledCapabilityIds.contains(cap.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: CapabilityTile(
                capability: cap,
                isEnabled: isEnabled,
                onToggle: (_) => onToggleCapability(cap.id),
              ),
            );
          }),
        ],
      ),
    );
  }
}
