import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/circle_sub_industry_model.dart';

/// Renders the Sub-Industries tab list for Circle Details.
class CircleSubIndustriesSection extends StatelessWidget {
  final CircleSubIndustriesResponse? subIndustries;
  final bool isLoading;
  final String categoryName;

  const CircleSubIndustriesSection({
    super.key,
    required this.subIndustries,
    required this.isLoading,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final activeList = subIndustries?.activeSubIndustries ?? [];
    final openList = subIndustries?.openSubIndustries ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Active Sub-Industries',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (activeList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No active sub-industry specializations recorded.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            )
          else
            ...activeList.map(
              (item) => _buildSubIndustryTile(
                name: item.name,
                count: '${item.peerCount} ${item.peerCount == 1 ? "peer" : "peers"}',
                status: 'Active',
                isActive: true,
              ),
            ),
          const SizedBox(height: 18),
          const Text(
            'Open Sub-Industries',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Available categories for $categoryName',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          if (openList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'All sub-industries are currently filled.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            )
          else
            ...openList.map(
              (item) => _buildSubIndustryTile(
                name: item.name,
                count: null,
                status: 'Open',
                isActive: false,
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSubIndustryTile({
    required String name,
    required String? count,
    required String status,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (count != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count,
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF16A34A).withValues(alpha: 0.1)
                  : AppColors.secondaryBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF16A34A)
                    : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
