import 'package:flutter/material.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';

/// Renders a dynamic, tab-aware AppBar adhering to Material 3 design standards.
class DashboardAppBar extends StatelessWidget {
  final int activeTab;
  final String? selectedCircle;
  final int unreadNotificationCount;
  final List<String> dynamicIndustries;
  final ValueChanged<String> onCircleSelected;
  final VoidCallback onNotificationTap;

  const DashboardAppBar({
    super.key,
    required this.activeTab,
    this.selectedCircle,
    required this.unreadNotificationCount,
    required this.dynamicIndustries,
    required this.onCircleSelected,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final session = SessionManager().currentSession;
    final isIndustryDirector = session.role == UserRole.industryDirector;
    final activeCircleName = selectedCircle ??
        (session.managedCircles.isNotEmpty
            ? session.managedCircles.first
            : session.regionalScope.isNotEmpty
                ? session.regionalScope
                : '');

    String tabTitle;
    String tabSubtitle;

    switch (activeTab) {
      case 0:
        tabTitle = activeCircleName.isNotEmpty ? activeCircleName : 'Dashboard';
        tabSubtitle = session.customRoleLabel ?? session.role.label;
        break;
      case 1:
        tabTitle = 'Peers';
        tabSubtitle = activeCircleName.isNotEmpty
            ? activeCircleName
            : 'Directory & Profiles';
        break;
      case 2:
        tabTitle = 'Circles & Teams';
        tabSubtitle = session.regionalScope.isNotEmpty
            ? session.regionalScope
            : 'Circles Directory';
        break;
      case 3:
        tabTitle = 'Finance';
        tabSubtitle = activeCircleName.isNotEmpty
            ? activeCircleName
            : 'Collections & Dues';
        break;
      case 4:
        tabTitle = 'Reports';
        tabSubtitle = activeCircleName.isNotEmpty
            ? activeCircleName
            : 'Submissions & Attendance';
        break;
      default:
        tabTitle = 'Dashboard';
        tabSubtitle = session.customRoleLabel ?? session.role.label;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tabTitle,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        tabSubtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.text,
                    size: 22,
                  ),
                  onPressed: () {},
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.text,
                        size: 22,
                      ),
                      onPressed: onNotificationTap,
                    ),
                    if (unreadNotificationCount > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1.5,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 15,
                            minHeight: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            unreadNotificationCount > 99
                                ? '99+'
                                : '$unreadNotificationCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.profile),
                  child: InitialsAvatar(
                    name: session.name,
                    radius: 17,
                    backgroundColor: AppColors.secondaryBg,
                    textColor: AppColors.text,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            if (activeTab == 0) ...[
              if (isIndustryDirector && dynamicIndustries.isNotEmpty) ...[
                const SizedBox(height: 10),
                HorizontalSelectionChips(
                  options: dynamicIndustries,
                  selectedOption: selectedCircle ?? dynamicIndustries.first,
                  onSelected: onCircleSelected,
                  showBulletWhenSelected: true,
                  selectedBgColor: AppColors.primary,
                  unselectedBgColor: AppColors.secondaryBg,
                  selectedTextColor: Colors.white,
                  unselectedTextColor: AppColors.textSecondary,
                  bulletColor: Colors.white,
                ),
              ] else if (session.managedCircles.length > 1 &&
                  session.role != UserRole.districtExecDirector) ...[
                const SizedBox(height: 10),
                HorizontalSelectionChips(
                  options: session.managedCircles,
                  selectedOption:
                      selectedCircle ??
                      (session.managedCircles.isNotEmpty
                          ? session.managedCircles.first
                          : ''),
                  onSelected: onCircleSelected,
                  showBulletWhenSelected: true,
                  selectedBgColor: AppColors.primary,
                  unselectedBgColor: AppColors.secondaryBg,
                  selectedTextColor: Colors.white,
                  unselectedTextColor: AppColors.textSecondary,
                  bulletColor: Colors.white,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
