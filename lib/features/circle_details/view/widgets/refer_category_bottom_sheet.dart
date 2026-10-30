import 'package:flutter/material.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../teams/model/teams_model.dart';
import '../../model/circle_sub_industry_model.dart';
import 'refer_category_contact_tab.dart';
import 'refer_category_peers_tab.dart';

/// Bottom sheet opened when tapping 'Refer' on an Open Category card.
/// Provides two options:
/// 1. 'All Peers' — Search and refer any peer from the global Peers directory.
/// 2. 'From Contact' — Pick from saved contacts or enter contact details / invite via WhatsApp.
class ReferCategoryBottomSheet extends StatefulWidget {
  final CircleTeamModel circle;
  final SubIndustryItemModel category;

  const ReferCategoryBottomSheet({
    super.key,
    required this.circle,
    required this.category,
  });

  static Future<bool?> show(
    BuildContext context, {
    required CircleTeamModel circle,
    required SubIndustryItemModel category,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.transparent,
      builder: (_) => ReferCategoryBottomSheet(
        circle: circle,
        category: category,
      ),
    );
  }

  @override
  State<ReferCategoryBottomSheet> createState() =>
      _ReferCategoryBottomSheetState();
}

class _ReferCategoryBottomSheetState extends State<ReferCategoryBottomSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final sheetHeight = media.size.height * 0.82;

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        height: sheetHeight,
        decoration: const BoxDecoration(
          color: AppColor.lightBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
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
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
              child: Row(
                children: [
                  const SquareRoundedGradientIcon(
                    icon: Icons.person_add_alt_1_rounded,
                    boxSize: 34,
                    iconSize: 17,
                    borderRadius: 10,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Refer for ${widget.category.name}',
                          style: AppTypography.titleSmall.copyWith(
                            fontSize: 14,
                            color: AppColor.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.circle.name,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 11,
                            color: AppColor.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColor.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColor.lightBorder),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: AppColor.brandGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: AppColor.transparent,
                labelColor: AppColor.white,
                unselectedLabelColor: AppColor.lightTextSecondary,
                labelStyle: AppTypography.labelSmall.copyWith(fontSize: 12),
                unselectedLabelStyle:
                    AppTypography.bodySmall.copyWith(fontSize: 12),
                tabs: const [
                  Tab(
                    height: 34,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_alt_outlined, size: 15),
                        SizedBox(width: 6),
                        Text('All Peers'),
                      ],
                    ),
                  ),
                  Tab(
                    height: 34,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.contact_phone_outlined, size: 15),
                        SizedBox(width: 6),
                        Text('From Contact'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ReferCategoryPeersTab(
                    circle: widget.circle,
                    category: widget.category,
                  ),
                  ReferCategoryContactTab(
                    circle: widget.circle,
                    category: widget.category,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

