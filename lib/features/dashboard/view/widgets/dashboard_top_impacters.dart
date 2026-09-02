import 'package:flutter/material.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../model/dashboard_metrics_model.dart';
import '../../model/impacter_model.dart';

/// Renders the Top 5 Impacters leaderboard list on the Dashboard.
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

  String _formatCompactNumber(dynamic value) {
    if (value == null) return '0';
    int? numVal;
    if (value is int) {
      numVal = value;
    } else {
      numVal = int.tryParse(value.toString().replaceAll(',', '').trim());
    }
    if (numVal == null) return value.toString();
    if (numVal >= 1000000) {
      final double inM = numVal / 1000000.0;
      return '${inM.toStringAsFixed(inM.truncateToDouble() == inM ? 0 : 1)}M';
    } else if (numVal >= 1000) {
      final double inK = numVal / 1000.0;
      return '${inK.toStringAsFixed(inK.truncateToDouble() == inK ? 0 : 1)}k';
    }
    return '$numVal';
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.military_tech_rounded,
                    color: Color(0xFFD97706),
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Top 5 Impacters',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    displayCircleName,
                    style: const TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ...topList.map((impacter) => _buildImpacterCard(context, impacter)),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildImpacterCard(BuildContext context, ImpacterModel impacter) {
    Color rankBg = const Color(0xFFF1F5F9);
    Color rankText = const Color(0xFF475569);
    Color rankBorder = AppColors.border;

    if (impacter.rank == 1) {
      rankBg = const Color(0xFFFEF3C7);
      rankText = const Color(0xFFB45309);
      rankBorder = const Color(0xFFFDE68A);
    } else if (impacter.rank == 2) {
      rankBg = const Color(0xFFF1F5F9);
      rankText = const Color(0xFF334155);
      rankBorder = const Color(0xFFCBD5E1);
    } else if (impacter.rank == 3) {
      rankBg = const Color(0xFFFFEDD5);
      rankText = const Color(0xFFC2410C);
      rankBorder = const Color(0xFFFED7AA);
    }

    final displayDesig = impacter.designation != null &&
            impacter.designation!.trim().isNotEmpty
        ? impacter.designation!.trim()
        : '';
    final displayComp = impacter.company.trim();

    String subtitle = '';
    if (displayDesig.isNotEmpty && displayComp.isNotEmpty) {
      subtitle = '$displayDesig · $displayComp';
    } else if (displayDesig.isNotEmpty) {
      subtitle = displayDesig;
    } else {
      subtitle = displayComp;
    }

    final categoryStr = impacter.level4Category != null &&
            impacter.level4Category!.trim().isNotEmpty
        ? impacter.level4Category!.trim()
        : (impacter.tags.isNotEmpty ? impacter.tags : (impacter.industry ?? ''));

    final displayCircle = impacter.circle.isNotEmpty
        ? impacter.circle
        : (metrics?.circleName ?? selectedCircle ?? '');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Avatar + Name/Company + Rank Pill + Chevron
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InitialsAvatar(
                      name: impacter.name.toUpperCase(),
                      imageUrl: impacter.avatarUrl,
                      radius: 22,
                      backgroundColor: const Color(0xFF162D4A),
                      fontSize: 13,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  impacter.name.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (impacter.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 14,
                                ),
                              ],
                            ],
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Rank Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: rankBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: rankBorder, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            impacter.rank == 1
                                ? Icons.emoji_events_rounded
                                : (impacter.rank <= 3
                                    ? Icons.military_tech_rounded
                                    : Icons.star_rounded),
                            size: 12,
                            color: rankText,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '#${impacter.rank} Rank',
                            style: TextStyle(
                              color: rankText,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 8),
                // Badges & Chips Wrap
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // 1. Lives Impacted Count
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFDE68A),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite_rounded,
                            size: 11,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${impacter.lives} Lives Impacted',
                            style: const TextStyle(
                              color: Color(0xFFB45309),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 2. Coins Count
                    if (impacter.coins > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFDE68A),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.monetization_on_outlined,
                              size: 11,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_formatCompactNumber(impacter.coins)} Coins',
                              style: const TextStyle(
                                color: Color(0xFFB45309),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // 3. Category / Level 4
                    if (categoryStr.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.category_outlined,
                              size: 11,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 140),
                              child: Text(
                                categoryStr,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // 4. Circle Name
                    if (displayCircle.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFBFDBFE),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.group_work_outlined,
                              size: 11,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 130),
                              child: Text(
                                displayCircle,
                                style: const TextStyle(
                                  color: Color(0xFF1D4ED8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // 5. City / Location
                    if (impacter.location.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 11,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              impacter.location,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
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
