import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../data/repositories/notifications_repository.dart';
import '../../../data/repositories/teams_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// Business Logic Component for managing Executive Dashboard state.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _dashboardRepository;
  final NotificationsRepository _notificationsRepository;
  final TeamsRepository _teamsRepository;

  DashboardBloc({
    DashboardRepository? dashboardRepository,
    NotificationsRepository? notificationsRepository,
    TeamsRepository? teamsRepository,
  })  : _dashboardRepository =
            dashboardRepository ?? DashboardRepositoryImpl(),
        _notificationsRepository =
            notificationsRepository ?? NotificationsRepositoryImpl(),
        _teamsRepository = teamsRepository ?? TeamsRepositoryImpl(),
        super(const DashboardState()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<TabChanged>(_onTabChanged);
    on<SelectCircle>(_onSelectCircle);
    on<RefreshNotificationsCount>(_onRefreshNotificationsCount);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.metrics == null && !event.isRefresh) {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
    }

    final session = SessionManager().currentSession;

    // Determine which circle or industry is currently active/selected
    final activeCircle = state.selectedCircle ??
        (session.role == UserRole.industryDirector ||
                session.role == UserRole.districtExecDirector ||
                session.role == UserRole.countryDirector ||
                session.role == UserRole.superAdmin
            ? (session.regionalScope.isNotEmpty
                ? session.regionalScope
                : (session.managedCircles.isNotEmpty
                    ? session.managedCircles.first
                    : null))
            : (session.managedCircles.isNotEmpty
                ? session.managedCircles.first
                : null));

    // Parallel fetch: metrics, impacters, dynamic industries, and unread notifications
    final metricsFuture =
        _dashboardRepository.getMetrics(circleId: activeCircle);
    final impactersFuture =
        _dashboardRepository.getTopImpacters(circleId: activeCircle);
    final industriesFuture = _teamsRepository.getIndustries();
    final notifsFuture = _notificationsRepository.getNotifications();

    try {
      final metricsRes = await metricsFuture;
      final impactersRes = await impactersFuture;
      final industriesRes = await industriesFuture;
      final notifsRes = await notifsFuture;

      int unreadCount = state.unreadNotificationCount;
      if (notifsRes.success && notifsRes.data != null) {
        unreadCount = notifsRes.data!.where((n) => n.isUnread).length;
      }

      List<String> industries = state.dynamicIndustries;
      if (industriesRes.success &&
          industriesRes.data != null &&
          industriesRes.data!.isNotEmpty) {
        industries = List<String>.from(industriesRes.data!);
      }

      emit(
        state.copyWith(
          isLoading: false,
          metrics: metricsRes.data,
          impacters: impactersRes.data ?? const [],
          selectedCircle: activeCircle,
          unreadNotificationCount: unreadCount,
          dynamicIndustries: industries,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshNotificationsCount(
    RefreshNotificationsCount event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final res = await _notificationsRepository.getNotifications();
      if (res.success && res.data != null) {
        final unreadCount = res.data!.where((n) => n.isUnread).length;
        emit(state.copyWith(unreadNotificationCount: unreadCount));
      }
    } catch (_) {}
  }

  void _onSelectCircle(SelectCircle event, Emitter<DashboardState> emit) {
    emit(state.copyWith(selectedCircle: event.circleName));
    add(const LoadDashboardData(isRefresh: true));
  }

  void _onTabChanged(TabChanged event, Emitter<DashboardState> emit) {
    emit(state.copyWith(activeTab: event.index));
  }
}
