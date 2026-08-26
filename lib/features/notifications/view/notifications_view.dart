import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_state.dart';
import '../model/notification_model.dart';
import '../presenter/notifications_presenter.dart';
import 'widgets/notification_date_group.dart';
import 'widgets/notifications_clear_dialog.dart';
import 'widgets/notifications_filter_chips.dart';
import 'widgets/notifications_summary_header.dart';

/// Screen component rendering user notifications with date-wise grouping and Material 3 design.
class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView>
    implements NotificationsViewContract {
  late final NotificationsBloc _bloc;
  late final NotificationsPresenter _presenter;

  bool _isLoading = false;
  List<NotificationModel> _notifications = const [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _bloc = NotificationsBloc();
    _presenter = NotificationsPresenter(view: this, bloc: _bloc);
    _presenter.load();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // --- NotificationsViewContract Implementations ---

  @override
  void onNotificationsLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void onNotificationsLoaded() {
    setState(() {
      _isLoading = false;
      _notifications = _bloc.state.notifications;
    });
  }

  @override
  void onNotificationsError(String error) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
    );
  }

  void _showClearAllDialog() {
    NotificationsClearDialog.show(
      context,
      onConfirm: () => _presenter.clearAll(),
    );
  }

  List<NotificationModel> _getFilteredNotifications() {
    switch (_selectedFilter) {
      case 'Unread':
        return _notifications.where((n) => n.isUnread).toList();
      case 'Referrals':
        return _notifications
            .where((n) => n.type == NotificationType.referral)
            .toList();
      case 'Deals':
        return _notifications
            .where((n) => n.type == NotificationType.deal)
            .toList();
      case 'Meetings':
        return _notifications
            .where((n) => n.type == NotificationType.meeting)
            .toList();
      case 'Alerts':
        return _notifications
            .where((n) =>
                n.type == NotificationType.alert ||
                n.type == NotificationType.report)
            .toList();
      default:
        return _notifications;
    }
  }

  Map<String, List<NotificationModel>> _groupByDate(
      List<NotificationModel> list) {
    final Map<String, List<NotificationModel>> groups = {};

    for (final notif in list) {
      final t = notif.time.toLowerCase();
      String groupKey = 'Earlier';

      if (t.contains('today') ||
          t.contains('m ago') ||
          t.contains('h ago') ||
          t.contains('min') ||
          t.contains('just now') ||
          t.contains('sec')) {
        groupKey = 'Today';
      } else if (t.contains('yesterday') ||
          t.contains('1d ago') ||
          t.contains('1 day')) {
        groupKey = 'Yesterday';
      } else if (t.contains('2d ago') ||
          t.contains('3d ago') ||
          t.contains('4d ago') ||
          t.contains('this week')) {
        groupKey = 'This Week';
      } else {
        final commaIdx = notif.time.indexOf(',');
        if (commaIdx != -1) {
          final prefix = notif.time.substring(0, commaIdx).trim();
          groupKey = prefix.isNotEmpty ? prefix : 'Earlier';
        } else if (notif.time.isNotEmpty && notif.time != 'Recent') {
          groupKey = notif.time;
        } else {
          groupKey = 'Earlier';
        }
      }

      groups.putIfAbsent(groupKey, () => []).add(notif);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredNotifications();
    final unreadCount = _notifications.where((n) => n.isUnread).length;
    final dateGroups = _groupByDate(filtered);

    return BlocProvider<NotificationsBloc>.value(
      value: _bloc,
      child: BlocListener<NotificationsBloc, NotificationsState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: const CustomAppBar(
            title: 'Notifications',
            showBackButton: true,
          ),
          body: _isLoading && _notifications.isEmpty
              ? const CenteredLoadingIndicator(height: 300)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Summary Header
                    NotificationsSummaryHeader(
                      totalCount: _notifications.length,
                      unreadCount: unreadCount,
                      onMarkAllRead: () => _presenter.markAllAsRead(),
                      onClearAll: _showClearAllDialog,
                    ),
                    // Filter Chips
                    if (_notifications.isNotEmpty) ...[
                      NotificationsFilterChips(
                        selectedFilter: _selectedFilter,
                        onFilterSelected: (filter) {
                          setState(() => _selectedFilter = filter);
                        },
                        allCount: _notifications.length,
                        unreadCount: unreadCount,
                      ),
                      const SizedBox(height: 4),
                    ],
                    // Notifications List by Date
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.notifications_off_outlined,
                                      color: AppColors.textSecondary,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _selectedFilter == 'All'
                                        ? 'No notifications yet'
                                        : 'No $_selectedFilter notifications',
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Alerts, referrals, and meeting updates will appear here.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: dateGroups.length,
                              itemBuilder: (context, index) {
                                final dateKey =
                                    dateGroups.keys.elementAt(index);
                                final groupList = dateGroups[dateKey]!;

                                return NotificationDateGroup(
                                  dateTitle: dateKey,
                                  notifications: groupList,
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
