import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StarRatingDisplay extends StatelessWidget {
  final int rating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final int maxStars;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.size = 16,
    this.activeColor = AppColors.warning,
    this.inactiveColor = AppColors.inactive,
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        return Icon(
          Icons.star_rounded,
          color: index < rating ? activeColor : inactiveColor,
          size: size,
        );
      }),
    );
  }
}
