import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/circle_event_model.dart';

/// Renders the Events tab list with filter chips for Circle Details.
class CircleEventsSection extends StatelessWidget {
  final List<CircleEventModel> events;
  final bool isLoading;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const CircleEventsSection({
    super.key,
    required this.events,
    required this.isLoading,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = const ['All', 'Upcoming', 'Completed'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Horizontal Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: Row(
            children: filters.map((filter) {
              final isSelected = selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: GestureDetector(
                  onTap: () => onFilterChanged(filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1E3C72)
                          : AppColors.secondaryBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1E3C72)
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    size: 36,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No events found for this circle.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, idx) {
              final ev = events[idx];

              Color bg = const Color(0xFFEBF3FB);
              Color fg = const Color(0xFF1E3C72);
              IconData icon = Icons.mic_none_rounded;
              if (ev.title.contains('Summit') || ev.title.contains('Assembly')) {
                bg = const Color(0xFFFEF3C7);
                fg = const Color(0xFFD97706);
                icon = Icons.groups_rounded;
              } else if (ev.title.contains('Workshop') ||
                  ev.title.contains('AI')) {
                bg = const Color(0xFFDCFCE7);
                fg = const Color(0xFF16A34A);
                icon = Icons.psychology_rounded;
              }

              final isUpcoming = ev.status == 'Upcoming';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.015),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, color: fg, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ev.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${ev.date} · ${ev.time} · ${ev.location} (${ev.mode})',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isUpcoming
                            ? const Color(0xFFEBF3FB)
                            : AppColors.secondaryBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ev.status,
                        style: TextStyle(
                          color: isUpcoming
                              ? const Color(0xFF1E3C72)
                              : Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
