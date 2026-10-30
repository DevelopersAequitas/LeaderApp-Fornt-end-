import 'package:flutter/material.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../model/dashboard_metrics_model.dart';
import '../../model/impacter_model.dart';

/// Renders the Top 5 Impacters leaderboard list on the Dashboard using the
/// Peers Global Unity `PeerCard` layout and theme colors.
/// Tapping the section header or "View All" opens the full top-to-bottom
/// ranked peers list for Life Impacts.
class DashboardTopImpacters extends StatelessWidget {
  final List<ImpacterModel> impacters;
  final DashboardMetricsModel? metrics;
  final String? selectedCircle;

  const DashboardTopImpacters({
    super.key,
    required this.impacters,
    this.metrics,
    this.selectedCircle,
  });

  void _openAllImpacters(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRoutes.leaderActivities,
      arguments: {
        'type': 'impacts',
        'circleId': ?selectedCircle,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (impacters.isEmpty) return const SizedBox.shrink();

    final session = SessionManager().currentSession;
    final String rawCircleName = metrics?.circleName ?? '';
    final bool isPlaceholder =
        rawCircleName.toLowerCase().contains('enter ') || rawCircleName.isEmpty;
    final String displayCircleName = !isPlaceholder
        ? rawCircleName
        : (selectedCircle ??
            (session.managedCircles.isNotEmpty
                ? session.managedCircles.first
                : session.regionalScope));

    final topList = impacters.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _openAllImpacters(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColor.brandGradient.createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                        blendMode: BlendMode.srcIn,
                        child: const Icon(
                          Icons.military_tech_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Top 5 Impacters',
                        style: TextStyle(
                          color: AppColor.lightTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.badgeBlueBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              displayCircleName,
                              style: const TextStyle(
                                color: AppColor.primaryBlue,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.lightSurfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColor.lightBorder),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View All',
                                style: TextStyle(
                                  color: AppColor.primaryBlue,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 13,
                                color: AppColor.primaryBlue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        ...topList.map((impacter) => _buildImpacterCard(context, impacter)),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildImpacterCard(BuildContext context, ImpacterModel impacter) {
    final displayDesig = impacter.designation != null &&
            impacter.designation!.trim().isNotEmpty
        ? impacter.designation!.trim()
        : '';
    final displayComp = impacter.company.trim();

    String designationAndCompany = '';
    if (displayDesig.isNotEmpty && displayComp.isNotEmpty) {
      designationAndCompany = '$displayDesig · $displayComp';
    } else if (displayDesig.isNotEmpty) {
      designationAndCompany = displayDesig;
    } else {
      designationAndCompany = displayComp;
    }

    final categoryStr = impacter.level4Category != null &&
            impacter.level4Category!.trim().isNotEmpty
        ? impacter.level4Category!.trim()
        : (impacter.tags.isNotEmpty ? impacter.tags : (impacter.industry ?? ''));

    final isTopRank = impacter.rank <= 3;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4.5),
      decoration: BoxDecoration(
        color: AppColor.lightSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            final session = SessionManager().currentSession;
            final String rawCircleName = metrics?.circleName ?? '';
            final bool isPlaceholder =
                rawCircleName.toLowerCase().contains('enter ') ||
                rawCircleName.isEmpty;
            final String activeCircle = !isPlaceholder
                ? rawCircleName
                : (selectedCircle ??
                    (session.managedCircles.isNotEmpty
                        ? session.managedCircles.first
                        : session.regionalScope));

            final peer = PeerModel(
              id: impacter.id,
              initials: impacter.initials,
              name: impacter.name,
              avatarUrl: impacter.avatarUrl,
              company: impacter.company,
              circle:
                  impacter.circle.isNotEmpty ? impacter.circle : activeCircle,
              circleId: impacter.circleId,
              location: impacter.location,
              tags: impacter.tags,
              impactCount: impacter.lives,
              dealsFormatted: impacter.dealsFormatted,
              coins: impacter.coins,
              attendance: impacter.attendance,
              status: impacter.status.isNotEmpty ? impacter.status : 'Active',
              phone: impacter.phone,
              email: impacter.email,
              designation: impacter.designation,
              industry: impacter.industry,
              level4Category: impacter.level4Category,
              isVerified: impacter.isVerified,
              introVideoUrl: impacter.introVideoUrl,
            );
            Navigator.of(context).pushNamed(
              AppRoutes.peerProfile,
              arguments: peer,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Avatar (38px matching Peers Global Unity)
                InitialsAvatar(
                  name: impacter.name.toUpperCase(),
                  imageUrl: impacter.avatarUrl,
                  radius: 19,
                  backgroundColor: AppColor.primaryBlue,
                  fontSize: 12,
                ),
                const SizedBox(width: 9),
                // 2. Center Details Column (4 clean rows matching PeerCard)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Uppercase Name + Verified + Theme Rank Pill
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              impacter.name.toUpperCase(),
                              style: const TextStyle(
                                color: AppColor.lightTextPrimary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (impacter.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              color: AppColor.primaryBlue,
                              size: 13,
                            ),
                          ],
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              gradient:
                                  isTopRank ? AppColor.brandGradient : null,
                              color:
                                  isTopRank ? null : AppColor.lightSurfaceMuted,
                              borderRadius: BorderRadius.circular(5),
                              border: isTopRank
                                  ? null
                                  : Border.all(color: AppColor.lightBorder),
                            ),
                            child: Text(
                              '#${impacter.rank}',
                              style: TextStyle(
                                color: isTopRank
                                    ? Colors.white
                                    : AppColor.lightTextSecondary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Row 2: City / Location
                      if (impacter.location.trim().isNotEmpty) ...[
                        const SizedBox(height: 1.5),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 10,
                              color: AppColor.lightTextSecondary,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                impacter.location.trim(),
                                style: const TextStyle(
                                  color: AppColor.lightTextSecondary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Row 3: Designation · Company
                      if (designationAndCompany.isNotEmpty) ...[
                        const SizedBox(height: 1.5),
                        Row(
                          children: [
                            const Icon(
                              Icons.business_center_rounded,
                              size: 10,
                              color: AppColor.lightTextSecondary,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                designationAndCompany,
                                style: const TextStyle(
                                  color: AppColor.lightTextSecondary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Row 4: Brand Gradient Category Text (No background box)
                      if (categoryStr.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColor.brandGradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          blendMode: BlendMode.srcIn,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.sell_outlined,
                                size: 9.0,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  categoryStr,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 3. Right Column: Main Impact Count Badge Only
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.lightSurfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColor.lightBorder.withValues(alpha: 0.8),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_rounded,
                            size: 13,
                            color: AppColor.primaryBlue,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${impacter.lives}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: AppColor.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
