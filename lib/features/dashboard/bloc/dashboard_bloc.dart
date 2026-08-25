import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// Business Logic Component for managing Circle Chair dashboard statistics via Clean Architecture.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _dashboardRepository;

  DashboardBloc({DashboardRepository? dashboardRepository})
      : _dashboardRepository = dashboardRepository ?? DashboardRepositoryImpl(),
        super(const DashboardState()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<TabChanged>(_onTabChanged);
    on<SelectCircle>(_onSelectCircle);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.metrics == null) {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
    }

    final session = SessionManager().currentSession;

    // Determine which circle or industry is currently active/selected
    final activeCircle =
        state.selectedCircle ??
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

    try {
      final metricsResponse = await _dashboardRepository.getMetrics(circleId: activeCircle);
      final impactersResponse = await _dashboardRepository.getTopImpacters(circleId: activeCircle);

      emit(
        state.copyWith(
          isLoading: false,
          metrics: metricsResponse.data,
          impacters: impactersResponse.data ?? const [],
          selectedCircle: activeCircle,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onSelectCircle(SelectCircle event, Emitter<DashboardState> emit) {
    emit(state.copyWith(selectedCircle: event.circleName));
    add(const LoadDashboardData());
  }

  void _onTabChanged(TabChanged event, Emitter<DashboardState> emit) {
    emit(state.copyWith(activeTab: event.index));
  }
}
