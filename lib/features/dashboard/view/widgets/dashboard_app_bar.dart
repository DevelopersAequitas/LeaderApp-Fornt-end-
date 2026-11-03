import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/enums/user_role.dart';
import '../../model/dashboard_circle_option.dart';
import 'dashboard_circle_switcher.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/widgets/widgets.dart';

/// Renders a dynamic, tab-aware AppBar matching Peers Global Unity's `AppCommonBar`:
/// - On the Home/Dashboard tab (`activeTab == 0`), shows the PeersGlobal logo + brand text
///   and the active leader role name below it as the subtitle.
/// - On the Peers tab (`activeTab == 1`), shows the `Peers` title (without any circle subtitle),
///   a search icon button on the right (or an inline search bar when active), and the profile avatar.
/// - On other tabs (`Circles & Teams`, `Finance`, `Reports`), shows the clean tab title and profile avatar.
class DashboardAppBar extends StatelessWidget {
  final int activeTab;
  final String? selectedCircle;
  final List<String> dynamicIndustries;
  final List<DashboardCircleOption> availableCircles;
  final ValueChanged<String> onCircleSelected;
  final bool isSearching;
  final TextEditingController? searchController;
  final VoidCallback? onSearchTap;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClose;

  const DashboardAppBar({
    super.key,
    required this.activeTab,
    this.selectedCircle,
    required this.dynamicIndustries,
    this.availableCircles = const [],
    required this.onCircleSelected,
    this.isSearching = false,
    this.searchController,
    this.onSearchTap,
    this.onSearchChanged,
    this.onSearchClose,
  });

  @override
  Widget build(BuildContext context) {
    final session = SessionManager().currentSession;
    final roleSubtitle = (session.customRoleLabel != null &&
            session.customRoleLabel!.trim().isNotEmpty)
        ? session.customRoleLabel!.trim()
        : session.role.label;

    String tabTitle = 'Dashboard';
    switch (activeTab) {
      case 1:
        tabTitle = 'Peers';
        break;
      case 2:
        tabTitle = 'Circles & Teams';
        break;
      case 3:
        tabTitle = 'Finance';
        break;
      case 4:
        tabTitle = 'Reports';
        break;
      default:
        break;
    }

    final showInlineSearch = activeTab == 1 && isSearching;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: AppColor.lightBorder,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColor.lightSurface,
          border: Border(
            bottom: BorderSide(color: AppColor.lightBorder, width: 1.0),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: SafeArea(
          bottom: false,
          child: showInlineSearch
              ? Row(
                  children: [
                    _buildHeaderIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: onSearchClose ?? () {},
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColor.lightSurfaceSubtle,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColor.lightBorder),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              size: 16,
                              color: AppColor.lightTextSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                autofocus: true,
                                onChanged: onSearchChanged,
                                style: const TextStyle(
                                  color: AppColor.lightTextPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: const InputDecoration(
                                  hintText:
                                      'Search by name, company, circle...',
                                  hintStyle: TextStyle(
                                    color: AppColor.lightTextMuted,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (searchController != null)
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: searchController!,
                                builder: (context, value, _) {
                                  if (value.text.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      searchController!.clear();
                                      onSearchChanged?.call('');
                                    },
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: AppColor.lightTextSecondary,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: activeTab == 0
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/icons/AppIcon.png',
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RichText(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        text: const TextSpan(
                                          style: TextStyle(
                                            fontFamily: 'LibreFranklin',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: -0.2,
                                            height: 1.15,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Peers',
                                              style: TextStyle(
                                                color: AppColor.primaryPink,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'Global',
                                              style: TextStyle(
                                                color: AppColor.primaryBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 1.5),
                                      Text(
                                        roleSubtitle,
                                        style: const TextStyle(
                                          color: AppColor.lightTextSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          height: 1.1,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              tabTitle,
                              style: const TextStyle(
                                color: AppColor.lightTextPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    if (activeTab == 1) ...[
                      _buildHeaderIconButton(
                        icon: Icons.search_rounded,
                        onTap: onSearchTap ?? () {},
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (availableCircles.length > 1) ...[
                      DashboardCircleSwitcher(
                        circles: availableCircles,
                        selectedCircleId: selectedCircle,
                        isGlobalRole:
                            session.role == UserRole.superAdmin ||
                                session.role == UserRole.countryDirector,
                        onSelected: onCircleSelected,
                      ),
                      const SizedBox(width: 8),
                    ],
                    _buildNotificationBellButton(context),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.profile),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColor.brandGradient,
                        ),
                        padding: const EdgeInsets.all(1.5),
                        child: ClipOval(
                          child: InitialsAvatar(
                            name: session.name,
                            imageUrl: session.avatarUrl,
                            radius: 15.5,
                            backgroundColor: AppColor.lightSurface,
                            textColor: AppColor.primaryBlue,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColor.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColor.lightBorder,
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: AppColor.lightTextPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBellButton(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColor.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColor.lightBorder,
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_outlined,
                size: 19,
                color: AppColor.lightTextPrimary,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColor.primaryPink,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
