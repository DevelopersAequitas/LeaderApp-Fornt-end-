import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_state.dart';
import '../presenter/notifications_presenter.dart';
import 'widgets/notification_card.dart';
import 'widgets/notification_empty_state.dart';
import 'widgets/notification_filter_chips.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView>
    implements NotificationsViewContract {
  late final NotificationsBloc _bloc;
  late final NotificationsPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _bloc = NotificationsBloc();
    _presenter = NotificationsPresenter(view: this, bloc: _bloc);
    _presenter.loadNotifications();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  void onNotificationLoading() {}

  @override
  void onNotificationLoaded() {}

  @override
  void onNotificationError(String error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void onNotificationTapped(String screen, Map<String, dynamic> data) {
    if (!mounted) return;

    final target = screen.toLowerCase().trim();
    if (target.contains('team') || target.contains('circle')) {
      Navigator.of(context).pushNamed(AppRoutes.home, arguments: {'tab': 2});
    } else if (target.contains('finance')) {
      Navigator.of(context).pushNamed(AppRoutes.home, arguments: {'tab': 3});
    } else if (target.contains('report')) {
      Navigator.of(context).pushNamed(AppRoutes.home, arguments: {'tab': 4});
    } else if (target.contains('peer')) {
      Navigator.of(context).pushNamed(AppRoutes.peers);
    } else if (target.contains('profile')) {
      Navigator.of(context).pushNamed(AppRoutes.profile);
    } else {
      Navigator.of(context).pushNamed(AppRoutes.home, arguments: {'tab': 0});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColor.lightBackground,
        appBar: AppBar(
          backgroundColor: AppColor.lightSurface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColor.lightTextPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColor.lightTextPrimary,
            ),
          ),
          centerTitle: false,
          actions: [
            BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, state) {
                if (state.unreadCount > 0) {
                  return TextButton(
                    onPressed: () => _presenter.markAllAsRead(),
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(
                        color: AppColor.primaryBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 8),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Divider(
              height: 1,
              color: AppColor.lightBorder,
              thickness: 1,
            ),
          ),
        ),
        body: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            return Column(
              children: [
                const SizedBox(height: 12),

                // Category Chips
                NotificationFilterChips(
                  activeCategory: state.activeCategory,
                  onSelected: (cat) => _presenter.filterCategory(cat),
                ),

                // Content
                Expanded(
                  child: state.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColor.primaryBlue,
                            strokeWidth: 2.5,
                          ),
                        )
                      : state.filteredNotifications.isEmpty
                          ? NotificationEmptyState(
                              category: state.activeCategory,
                              onRefresh: () => _presenter.loadNotifications(
                                category: state.activeCategory,
                                isRefresh: true,
                              ),
                            )
                          : RefreshIndicator(
                              color: AppColor.primaryBlue,
                              onRefresh: () async {
                                _presenter.loadNotifications(
                                  category: state.activeCategory,
                                  isRefresh: true,
                                );
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                itemCount: state.filteredNotifications.length,
                                itemBuilder: (context, index) {
                                  final item =
                                      state.filteredNotifications[index];
                                  return NotificationCard(
                                    notification: item,
                                    onTap: () =>
                                        _presenter.handleNotificationClick(
                                      item.id,
                                      item.screen,
                                      item.data,
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
