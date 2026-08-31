import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../../teams/model/teams_model.dart';

/// Renders the comprehensive Circle Leadership section supporting up to 3 Chairs, Founders, and Directors.
class CircleLeadershipCard extends StatelessWidget {
  final CircleTeamModel circle;

  const CircleLeadershipCard({super.key, required this.circle});

  static const List<String> _chairCommittees = [
    'Chair - Business Growth Committee',
    'Chair - Membership Committee',
    'Chair - Events & Programs Committee',
  ];

  static const List<String> _chairBadges = [
    'Chair - Business Growth',
    'Chair - Membership',
    'Chair - Events & Programs',
  ];

  static const List<String> _chairResponsibilities = [
    'Business Referrals, Synergies & Growth Deals',
    'Membership Retention, Peer Alignment & Engagement',
    'Circle Gatherings, Assemblies & Speaker Sessions',
  ];

  @override
  Widget build(BuildContext context) {
    // Collect all Chairs (support up to 3 chairs)
    final chairs = circle.chairs.isNotEmpty
        ? circle.chairs
        : (circle.chairName.trim().isNotEmpty &&
                  circle.chairName != 'Unassigned'
              ? [
                  CircleLeaderModel(
                    name: circle.chairName.trim(),
                    role: 'Circle Chair',
                  ),
                ]
              : <CircleLeaderModel>[]);

    // Collect Founders
    final founders = circle.founders.isNotEmpty
        ? circle.founders
        : (circle.founderName.trim().isNotEmpty &&
                  circle.founderName != 'Unassigned'
              ? [
                  CircleLeaderModel(
                    name: circle.founderName.trim(),
                    role: 'Circle Founder',
                  ),
                ]
              : <CircleLeaderModel>[]);

    // Collect Directors
    final directors = circle.directors.isNotEmpty
        ? circle.directors
        : (circle.directorName.trim().isNotEmpty &&
                  circle.directorName != 'Unassigned'
              ? [
                  CircleLeaderModel(
                    name: circle.directorName.trim(),
                    role: 'Circle Director',
                  ),
                ]
              : <CircleLeaderModel>[]);

    // final totalLeadersCount =
    //     chairs.length + founders.length + directors.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Circle Leadership Team',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Circle Chairs (Up to 3 Chairs formatted as Committees)
          if (chairs.isEmpty)
            _buildLeaderRow(
              context,
              roleTitle: _chairCommittees[0],
              leader: CircleLeaderModel(name: '', role: _chairCommittees[0]),
              roleBadge: _chairBadges[0],
              badgeBg: const Color(0xFFDCFCE7),
              badgeFg: const Color(0xFF16A34A),
              avatarBg: const Color(0xFF16A34A),
              responsibility: _chairResponsibilities[0],
            )
          else
            ...chairs.asMap().entries.map((entry) {
              final idx = entry.key;
              final chair = entry.value;
              final committeeTitle = idx < _chairCommittees.length
                  ? _chairCommittees[idx]
                  : 'Chair - Committee ${idx + 1}';
              final committeeBadge = idx < _chairBadges.length
                  ? _chairBadges[idx]
                  : 'Chair ${idx + 1}';
              final defaultResp = idx < _chairResponsibilities.length
                  ? _chairResponsibilities[idx]
                  : 'Circle Leadership & Committee Strategy';

              return Column(
                children: [
                  if (idx > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                  _buildLeaderRow(
                    context,
                    roleTitle: committeeTitle,
                    leader: chair,
                    roleBadge: committeeBadge,
                    badgeBg: const Color(0xFFDCFCE7),
                    badgeFg: const Color(0xFF16A34A),
                    avatarBg: const Color(0xFF16A34A),
                    responsibility: defaultResp,
                  ),
                ],
              );
            }),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColors.border),
          ),

          // 2. Circle Founders
          if (founders.isEmpty)
            _buildLeaderRow(
              context,
              roleTitle: 'Circle Founder',
              leader: const CircleLeaderModel(name: '', role: 'Circle Founder'),
              roleBadge: 'Founder 🔒',
              badgeBg: const Color(0xFFFEF3C7),
              badgeFg: const Color(0xFFD97706),
              avatarBg: AppColors.primary,
              responsibility: 'Vision, Founding Network & Core Strategy',
            )
          else
            ...founders.asMap().entries.map((entry) {
              final idx = entry.key;
              final founder = entry.value;
              return Column(
                children: [
                  if (idx > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                  _buildLeaderRow(
                    context,
                    roleTitle: 'Circle Founder',
                    leader: founder,
                    roleBadge: 'Founder 🔒',
                    badgeBg: const Color(0xFFFEF3C7),
                    badgeFg: const Color(0xFFD97706),
                    avatarBg: AppColors.primary,
                    responsibility: 'Vision, Founding Network & Core Strategy',
                  ),
                ],
              );
            }),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColors.border),
          ),

          // 3. Circle Directors
          if (directors.isEmpty)
            _buildLeaderRow(
              context,
              roleTitle: 'Circle Director',
              leader: const CircleLeaderModel(
                name: '',
                role: 'Circle Director',
              ),
              roleBadge: 'Director',
              badgeBg: const Color(0xFFEBF3FB),
              badgeFg: AppColors.primary,
              avatarBg: const Color(0xFF2563EB),
              responsibility: 'Regional Growth, Alignment & Guidance',
            )
          else
            ...directors.asMap().entries.map((entry) {
              final idx = entry.key;
              final director = entry.value;
              return Column(
                children: [
                  if (idx > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                  _buildLeaderRow(
                    context,
                    roleTitle: 'Circle Director',
                    leader: director,
                    roleBadge: 'Director',
                    badgeBg: const Color(0xFFEBF3FB),
                    badgeFg: AppColors.primary,
                    avatarBg: const Color(0xFF2563EB),
                    responsibility: 'Regional Growth, Alignment & Guidance',
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLeaderRow(
    BuildContext context, {
    required String roleTitle,
    required CircleLeaderModel leader,
    required String roleBadge,
    required Color badgeBg,
    required Color badgeFg,
    required Color avatarBg,
    required String responsibility,
  }) {
    final bool isAssigned =
        leader.name.trim().isNotEmpty && leader.name != 'Unassigned';
    final displayName = isAssigned ? leader.name : 'Unassigned';

    final String companyDetails;
    if (isAssigned &&
        ((leader.designation != null && leader.designation!.isNotEmpty) ||
            (leader.company != null && leader.company!.isNotEmpty))) {
      final parts = <String>[];
      if (leader.designation != null && leader.designation!.isNotEmpty) {
        parts.add(leader.designation!);
      }
      if (leader.company != null && leader.company!.isNotEmpty) {
        parts.add(leader.company!);
      }
      companyDetails = parts.join(' · ');
    } else {
      companyDetails = responsibility;
    }

    final String displayRole = leader.role.trim().isNotEmpty
        ? leader.role.trim()
        : roleTitle;

    return InkWell(
      onTap: isAssigned
          ? () {
              final initials = leader.name.trim().isNotEmpty
                  ? leader.name
                        .trim()
                        .split(' ')
                        .where((n) => n.isNotEmpty)
                        .map((n) => n[0])
                        .take(2)
                        .join()
                        .toUpperCase()
                  : '?';
              final peer = PeerModel(
                id: leader.id.trim(),
                initials: initials,
                name: leader.name,
                avatarUrl: leader.avatarUrl,
                company: leader.company ?? circle.name,
                circle: circle.name,
                circleId: circle.id,
                location: circle.location,
                designation: displayRole,
                industry: circle.category,
                level4Category: circle.category,
                tags: '$displayRole · ${circle.name}',
                status: 'Active',
                impactCount: 0,
                dealsFormatted: '₹0.0',
                coins: 0,
                attendance: '100%',
                phone: leader.phone ?? '',
                email: leader.email ?? '',
                isVerified: true,
              );
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.peerProfile, arguments: peer);
            }
          : null,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InitialsAvatar(
              name: displayName,
              imageUrl: isAssigned ? leader.avatarUrl : null,
              radius: 20,
              backgroundColor: isAssigned ? avatarBg : Colors.grey.shade400,
              textColor: Colors.white,
              fontSize: 11,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            color: isAssigned
                                ? AppColors.text
                                : Colors.grey.shade500,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAssigned) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayRole,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (companyDetails.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      companyDetails,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
