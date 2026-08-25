import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget = leading;
    if (leadingWidget == null && showBackButton) {
      leadingWidget = Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.secondaryBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(16),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.text,
              size: 24,
            ),
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.cardBg,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.text),
      leading: showBackButton ? leadingWidget : null,
      titleSpacing: showBackButton ? 8 : 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
      actions: actions != null ? [...actions!, const SizedBox(width: 8)] : null,
      shape: const Border(
        bottom: BorderSide(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
