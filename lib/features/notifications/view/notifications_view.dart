import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../model/notification_model.dart';
import '../presenter/notifications_presenter.dart';

/// Screen component rendering user notifications.
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
    setState(() {
      _isLoading = true;
    });
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
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // --- UI Widget Builders ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F2541),
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
        ),
      ),
      title: const Text(
        'Notifications',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildSummaryHeader() {
    final unreadCount = _notifications.where((n) => n.isUnread).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Total & Unread summary text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_notifications.length} notifications',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$unreadCount unread alerts',
                    style: const TextStyle(
                      color: Color(0xFFE27C00),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Mark all read button
          if (_notifications.isNotEmpty) ...[
            InkWell(
              onTap: () => _presenter.markAllAsRead(),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  'Mark all read',
                  style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Clear all button
            InkWell(
              onTap: () => _presenter.clearAll(),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.delete_outline_outlined,
                      color: Colors.redAccent,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Clear all',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    Color iconBg = Colors.grey.shade100;
    Color iconColor = Colors.grey;
    IconData iconData = Icons.notifications_none;
    String badgeLabel = 'INFO';
    Color badgeBg = Colors.grey.shade100;
    Color badgeTextColor = Colors.grey;

    switch (notification.type) {
      case NotificationType.referral:
        iconBg = const Color(0xFFE8F0FE);
        iconColor = const Color(0xFF1565C0);
        iconData = Icons.campaign_outlined;
        badgeLabel = 'REFERRAL';
        badgeBg = const Color(0xFFE8F0FE);
        badgeTextColor = const Color(0xFF1565C0);
        break;
      case NotificationType.deal:
        iconBg = const Color(0xFFE8F5E9);
        iconColor = const Color(0xFF2E7D32);
        iconData = Icons.monetization_on_outlined;
        badgeLabel = 'DEAL';
        badgeBg = const Color(0xFFE8F5E9);
        badgeTextColor = const Color(0xFF2E7D32);
        break;
      case NotificationType.alert:
        iconBg = const Color(0xFFFFF2F2);
        iconColor = const Color(0xFFD32F2F);
        iconData = Icons.flash_on_outlined;
        badgeLabel = 'ALERT';
        badgeBg = const Color(0xFFFFF2F2);
        badgeTextColor = const Color(0xFFD32F2F);
        break;
      case NotificationType.meeting:
        iconBg = const Color(0xFFFFF7ED);
        iconColor = const Color(0xFFD97706);
        iconData = Icons.calendar_today_outlined;
        badgeLabel = 'MEETING';
        badgeBg = const Color(0xFFFFF7ED);
        badgeTextColor = const Color(0xFFD97706);
        break;
      case NotificationType.report:
        iconBg = const Color(0xFFF1F5F9);
        iconColor = const Color(0xFF475569);
        iconData = Icons.description_outlined;
        badgeLabel = 'REPORT';
        badgeBg = const Color(0xFFE2E8F0);
        badgeTextColor = const Color(0xFF475569);
        break;
    }

    return Container(
      color: notification.isUnread ? const Color(0xFFF3F6FA) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unread indicator dot
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 14, right: 12),
            decoration: BoxDecoration(
              color: notification.isUnread ? const Color(0xFF1F3D68) : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
          // Soft-tinted Icon Box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          color: badgeTextColor,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Description Subtitle
                Text(
                  notification.description,
                  style: TextStyle(
                    color: AppColors.text.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                // Time
                Text(
                  notification.time,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationsBloc>.value(
      value: _bloc,
      child: BlocListener<NotificationsBloc, NotificationsState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF9FAFC),
          appBar: _buildAppBar(),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSummaryHeader(),
                    const Divider(height: 1, color: Color(0xFFEDEFF3)),
                    Expanded(
                      child: _notifications.isEmpty
                          ? const Center(
                              child: Text(
                                'No notifications found.',
                                style: TextStyle(
                                  color: Color(0xFF8B9CB4),
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _notifications.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1, color: Color(0xFFEDEFF3)),
                              itemBuilder: (context, index) =>
                                  _buildNotificationCard(_notifications[index]),
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
