import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/notification_count_service.dart';
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
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _bloc = NotificationsBloc();
    _presenter = NotificationsPresenter(view: this, bloc: _bloc);
    _scrollController = ScrollController()..addListener(_onScroll);
    _presenter.loadNotifications();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      _presenter.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
        backgroundColor: AppColor.primaryPink,
        behavior: SnackBarBehavior.floating,
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
    }
    // If target is empty or '/dashboard', the item is marked read in place
    // without forcing the user out of the notifications list.
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<NotificationsBloc, NotificationsState>(
        listener: (context, state) {
          NotificationCountService.instance.updateCount(state.unreadCount);
        },
        child: Scaffold(
          backgroundColor: AppColor.lightScaffoldBg,
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
            titleSpacing: 0,
            title: BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, state) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColor.lightTextPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (state.unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColor.brandGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primaryPink.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          '${state.unreadCount} new',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            actions: [
              BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, state) {
                  if (state.unreadCount > 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: TextButton.icon(
                        onPressed: state.isMarkingRead
                            ? null
                            : () => _presenter.markAllAsRead(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: state.isMarkingRead
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColor.primaryBlue,
                                ),
                              )
                            : const Icon(
                                Icons.done_all_rounded,
                                size: 16,
                                color: AppColor.primaryBlue,
                              ),
                        label: const Text(
                          'Mark all read',
                          style: TextStyle(
                            color: AppColor.primaryBlue,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1.0),
              child: Divider(
                height: 1,
                color: AppColor.lightBorder,
                thickness: 0.8,
              ),
            ),
          ),
          body: BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              return Column(
                children: [
                  const SizedBox(height: 12),

                  // Category Filter Chips
                  NotificationFilterChips(
                    activeCategory: state.activeCategory,
                    onSelected: (cat) => _presenter.filterCategory(cat),
                  ),

                  // Main Content
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
                                  controller: _scrollController,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  itemCount:
                                      state.filteredNotifications.length +
                                          (state.isLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index ==
                                        state.filteredNotifications.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColor.primaryBlue,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
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
      ),
    );
  }
}
