import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/teams_model.dart';

/// Renders a LinkedIn-style executive circle card featuring a top half-cover banner,
/// overlapping avatar badge, status pill, category & location details, and metrics.
class TeamsCircleCard extends StatelessWidget {
  final CircleTeamModel circle;

  const TeamsCircleCard({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    final isActive = circle.status.toLowerCase() == 'active';
    final statusBgColor =
        isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final statusTextColor =
        isActive ? const Color(0xFF15803D) : const Color(0xFFB91C1C);

    final String metaLocation =
        circle.location.isNotEmpty ? ' · ${circle.location}' : '';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.circleDetails,
          arguments: circle,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // LinkedIn-Style Top Half Cover Image Banner & Overlapping Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Top Cover Banner
                Container(
                  height: 110,
                  decoration: const BoxDecoration(
                    gradient: AppColors.brandGradient,
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _CoverPatternPainter(),
                        ),
                      ),
                      // Status Pill Top-Right
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            circle.status,
                            style: TextStyle(
                              color: statusTextColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Overlapping Circle Avatar
                Positioned(
                  top: 82,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: InitialsAvatar(
                      name: circle.name.toUpperCase(),
                      imageUrl: circle.chairs.isNotEmpty ? circle.chairs.first.avatarUrl : null,
                      radius: 28,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32), // Space for overlapping avatar
            // Card Content Body
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    circle.name,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${circle.category}$metaLocation',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (circle.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: circle.tags.map((tag) {
                          return Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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

class _CoverPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 40, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), 25, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
