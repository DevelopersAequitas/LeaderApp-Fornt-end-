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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top 5 Impacters',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  displayCircleName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ...impacters.map((impacter) => _buildImpacterTile(context, impacter)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildImpacterTile(BuildContext context, ImpacterModel impacter) {
    Color badgeColor = const Color(0xFF78909C);
    if (impacter.rank == 1) {
      badgeColor = const Color(0xFFD87D32);
    } else if (impacter.rank == 2) {
      badgeColor = const Color(0xFF32567D);
    } else if (impacter.rank == 3) {
      badgeColor = const Color(0xFF2E7D32);
    }

    return InkWell(
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
          company: impacter.company,
          circle: impacter.circle.isNotEmpty ? impacter.circle : activeCircle,
          location: impacter.location,
          tags: impacter.tags,
          impactCount: impacter.lives,
          dealsFormatted: impacter.dealsFormatted,
          coins: impacter.coins,
          attendance: impacter.attendance,
          status: impacter.status.isNotEmpty ? impacter.status : 'Active',
        );
        Navigator.of(context).pushNamed(AppRoutes.peerProfile, arguments: peer);
      },
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                InitialsAvatar(
                  name: impacter.name,
                  radius: 20,
                  backgroundColor: const Color(0xFF162D4A),
                  fontSize: 13,
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${impacter.rank}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    impacter.name,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (impacter.company.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      impacter.company,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (impacter.location.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      impacter.location,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${impacter.lives} lives',
                  style: const TextStyle(
                    color: Color(0xFF16A34A),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${_formatCompactNumber(impacter.coins)} coins',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade300,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
