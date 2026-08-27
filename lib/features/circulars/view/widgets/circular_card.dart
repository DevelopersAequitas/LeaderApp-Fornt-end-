import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/circular_model.dart';

/// MD3-styled soft card displaying an official circular announcement.
class CircularCard extends StatefulWidget {
  final CircularModel circular;

  const CircularCard({super.key, required this.circular});

  @override
  State<CircularCard> createState() => _CircularCardState();
}

class _CircularCardState extends State<CircularCard> {
  bool _isExpanded = false;

  Color _getPriorityBg(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppColors.dangerBg;
      case 'important':
        return AppColors.warningBg;
      default:
        return AppColors.selectionBg;
    }
  }

  Color _getPriorityFg(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppColors.danger;
      case 'important':
        return AppColors.warningDark;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.circular;
    final priorityBg = _getPriorityBg(c.priority);
    final priorityFg = _getPriorityFg(c.priority);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
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
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: priorityBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        c.priority.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: priorityFg,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Target: ${c.targetRoles.join(', ')}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      c.publishedAt,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  c.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  c.content,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                  maxLines: _isExpanded ? 100 : 2,
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      size: 14,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${c.authorName} (${c.authorRole})',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _isExpanded ? 'Show Less' : 'Read More',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.info,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: AppColors.info,
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
