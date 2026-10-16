import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../data/repositories/teams_repository.dart';
import '../../../core/network/api_response.dart';
import '../../../features/dashboard/model/dashboard_metrics_model.dart';
import '../../../features/dashboard/model/impacter_model.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// Business Logic Component for managing Executive Dashboard state.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _dashboardRepository;
  final TeamsRepository _teamsRepository;

  DashboardBloc({
    DashboardRepository? dashboardRepository,
    TeamsRepository? teamsRepository,
  })  : _dashboardRepository =
            dashboardRepository ?? DashboardRepositoryImpl(),
        _teamsRepository = teamsRepository ?? TeamsRepositoryImpl(),
        super(const DashboardState()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<TabChanged>(_onTabChanged);
    on<SelectCircle>(_onSelectCircle);
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

    try {
      // Parallel fetch with individual error isolation
      final results = await Future.wait([
        _dashboardRepository
            .getMetrics(circleId: activeCircle)
            .catchError((e) => ApiResponse<DashboardMetricsModel>(
                  success: false,
                  message: e.toString(),
                )),
        _dashboardRepository
            .getTopImpacters(circleId: activeCircle)
            .catchError((e) => const ApiResponse<List<ImpacterModel>>(
                  success: false,
                  data: <ImpacterModel>[],
                )),
        _teamsRepository
            .getIndustries()
            .catchError((e) => const ApiResponse<List<String>>(
                  success: false,
                  data: <String>[],
                )),
      ]);

      final metricsRes = results[0] as ApiResponse<DashboardMetricsModel>;
      final impactersRes = results[1] as ApiResponse<List<ImpacterModel>>;
      final industriesRes = results[2] as ApiResponse<List<String>>;

      List<String> industries = state.dynamicIndustries;
      if (industriesRes.success &&
          industriesRes.data != null &&
          industriesRes.data!.isNotEmpty) {
        industries = List<String>.from(industriesRes.data!);
      }

      emit(
        state.copyWith(
          isLoading: false,
          metrics: metricsRes.data ?? state.metrics,
          impacters: impactersRes.data ?? state.impacters,
          selectedCircle: activeCircle,
          dynamicIndustries: industries,
          errorMessage: metricsRes.success ? '' : (metricsRes.message ?? ''),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onSelectCircle(SelectCircle event, Emitter<DashboardState> emit) {
    emit(state.copyWith(selectedCircle: event.circleName));
    add(const LoadDashboardData(isRefresh: true));
  }

  void _onTabChanged(TabChanged event, Emitter<DashboardState> emit) {
    emit(state.copyWith(activeTab: event.index));
  }
}

