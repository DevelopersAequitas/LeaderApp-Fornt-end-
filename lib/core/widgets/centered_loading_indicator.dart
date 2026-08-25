import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CenteredLoadingIndicator extends StatelessWidget {
  final double? height;
  final Color? color;

  const CenteredLoadingIndicator({
    super.key,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = Center(
      child: CircularProgressIndicator(
        color: color ?? AppColors.primary,
      ),
    );

    if (height != null) {
      return SizedBox(
        height: height,
        child: indicator,
      );
    }

    return indicator;
  }
}
