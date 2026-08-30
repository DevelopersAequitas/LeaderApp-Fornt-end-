// ==============================================================================
// File: lib/features/notifications/view/notifications_view.dart
// Description: Executive Notifications, System Alerts & Actionable Circulars
// Framework: Flutter | Architecture: MVP View Layer (100% Pure StatelessWidget + BLoC)
// Features:
//   - Date-wise grouped notification feed (Today, Yesterday, Older)
//   - Notification type filter pills (All, Unread, Deals, P2P, Finance, System)
//   - Mark single / Mark all read dispatches and swipe-to-dismiss actions
//   - Clear all notifications modal dialog with confirmation
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../model/notification_model.dart';
import 'widgets/notification_date_group.dart';
import 'widgets/notifications_clear_dialog.dart';
import 'widgets/notifications_empty_view.dart';
import 'widgets/notifications_filter_chips.dart';
import 'widgets/notifications_summary_header.dart';

/// The View component of the Notifications feature.
/// Pure StatelessWidget powered 100% by BLoC state machine.
class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationsBloc>(
      create: (context) =>
          NotificationsBloc()..add(const LoadNotifications()),
      child: const _NotificationsContent(),
    );
  }
}

class _NotificationsContent extends StatelessWidget {
  const _NotificationsContent();

  Map<String, List<NotificationModel>> _groupNotificationsByDate(
    List<NotificationModel> notifications,
  ) {
    final grouped = <String, List<NotificationModel>>{
      'Today': [],
      'Yesterday': [],
      'Earlier': [],
    };

    for (final item in notifications) {
      final t = item.time.toLowerCase();
      if (t.contains('today') ||
          t.contains('m ago') ||
          t.contains('h ago') ||
          t.contains('just now')) {
        grouped['Today']!.add(item);
      } else if (t.contains('yesterday') || t.contains('1d ago')) {
        grouped['Yesterday']!.add(item);
      } else {
        grouped['Earlier']!.add(item);
      }
    }

    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  void _showClearAllConfirm(BuildContext context) {
    final bloc = context.read<NotificationsBloc>();
    NotificationsClearDialog.show(
      context,
      onConfirm: () => bloc.add(const ClearAllNotifications()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NotificationsBloc>();

    return BlocListener<NotificationsBloc, NotificationsState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage && curr.errorMessage.isNotEmpty,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: AppColors.danger,
          ),
        );
      },
      child: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          final allList = state.allNotifications;
          final filteredList = state.filteredNotifications;
          final grouped = _groupNotificationsByDate(filteredList);

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: 'Notifications',
              subtitle: 'System updates & member alerts',
              showBackButton: true,
            ),
            body: Column(
              children: [
                // Top Summary Row with Mark All Read / Clear actions
                NotificationsSummaryHeader(
                  totalCount: state.totalCount,
                  unreadCount: state.unreadCount,
                  onMarkAllRead: () => bloc.add(const MarkAllAsRead()),
                  onClearAll: () => _showClearAllConfirm(context),
                ),

                // Horizontal Filter Chips
                NotificationsFilterChips(
                  selectedFilter: state.selectedFilter,
                  allCount: allList.length,
                  unreadCount: state.unreadCount,
                  onFilterSelected: (f) =>
                      bloc.add(FilterNotifications(f)),
                ),

                const SizedBox(height: 4),

                // Content list or Empty State
                Expanded(
                  child: state.isLoading && allList.isEmpty
                      ? const CenteredLoadingIndicator(height: 300)
                      : RefreshIndicator(
                          onRefresh: () async {
                            bloc.add(
                              const LoadNotifications(isRefresh: true),
                            );
                          },
                          child: filteredList.isEmpty
                              ? NotificationsEmptyView(
                                  selectedFilter: state.selectedFilter,
                                )
                              : ListView.builder(
                                  padding:
                                      const EdgeInsets.only(bottom: 32),
                                  itemCount: grouped.keys.length,
                                  itemBuilder: (context, index) {
                                    final dateKey =
                                        grouped.keys.elementAt(index);
                                    final items = grouped[dateKey]!;
                                    return NotificationDateGroup(
                                      dateTitle: dateKey,
                                      notifications: items,
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
