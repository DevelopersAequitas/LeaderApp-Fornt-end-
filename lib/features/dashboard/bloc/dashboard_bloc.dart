import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/error_formatter.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../data/repositories/teams_repository.dart';
import '../../../features/dashboard/model/dashboard_circle_option.dart';
import '../../../features/dashboard/model/dashboard_metrics_model.dart';
import '../../../features/dashboard/model/impacter_model.dart';
import '../../../features/teams/model/teams_model.dart';
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

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.metrics == null && !event.isRefresh) {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
    } else if (event.isRefresh) {
      emit(state.copyWith(errorMessage: ''));
    }

    // Role-based scoping is enforced by the backend. The selected circle is only
    // sent when the user explicitly switched to one specific circle (UUID);
    // otherwise the request covers every circle inside the user's role scope.
    final selected = state.selectedCircle?.trim();
    final String? activeCircle =
        (selected != null && _uuidRegex.hasMatch(selected)) ? selected : null;

    // Dynamic RBAC sync: update active session and permissions in background
    ApiClient()
        .get<Map<String, dynamic>>(
          ApiEndpoints.profile,
          fromJsonT: (json) => json is Map<String, dynamic>
              ? json
              : (json is Map
                  ? Map<String, dynamic>.from(json)
                  : <String, dynamic>{}),
        )
        .then((res) async {
          if (res.success && res.data != null) {
            await SessionManager().updateFromAuthProfile(res.data!);
          }
        })
        .catchError((_) {});

    try {
      // Parallel fetch with individual error isolation
      final results = await Future.wait([
        _dashboardRepository
            .getMetrics(circleId: activeCircle)
            .catchError((e) => ApiResponse<DashboardMetricsModel>(
                  success: false,
                  message: ErrorFormatter.format(e),
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
        _teamsRepository
            .getCircles()
            .catchError((e) => const ApiResponse<List<CircleTeamModel>>(
                  success: false,
                  data: <CircleTeamModel>[],
                )),
      ]);

      final metricsRes = results[0] as ApiResponse<DashboardMetricsModel>;
      final impactersRes = results[1] as ApiResponse<List<ImpacterModel>>;
      final industriesRes = results[2] as ApiResponse<List<String>>;
      final circlesRes = results[3] as ApiResponse<List<CircleTeamModel>>;

      List<String> industries = state.dynamicIndustries;
      if (industriesRes.success &&
          industriesRes.data != null &&
          industriesRes.data!.isNotEmpty) {
        industries = List<String>.from(industriesRes.data!);
      }

      var circleOptions = state.availableCircles;
      var fullCircles = state.circles;
      if (circlesRes.success && circlesRes.data != null) {
        fullCircles = List<CircleTeamModel>.from(circlesRes.data!);
        circleOptions = fullCircles
            .where((c) => _uuidRegex.hasMatch(c.id.trim()))
            .map(
              (c) => DashboardCircleOption(
                id: c.id.trim(),
                name: c.name,
                country: c.country.trim(),
                district: c.district.trim().isNotEmpty
                    ? c.district.trim()
                    : c.location.trim(),
                industry: c.category.trim(),
                peersCount: c.peersCount,
                status: c.status.trim(),
              ),
            )
            .toList();
      }

      final resolvedError = metricsRes.success
          ? ''
          : ErrorFormatter.format(
              metricsRes.message ?? 'Unable to load dashboard metrics.',
            );

      emit(
        state.copyWith(
          isLoading: false,
          metrics: metricsRes.data ?? state.metrics,
          impacters: impactersRes.data ?? state.impacters,
          selectedCircle: activeCircle,
          clearSelectedCircle: activeCircle == null,
          dynamicIndustries: industries,
          availableCircles: circleOptions,
          circles: fullCircles,
          errorMessage: resolvedError,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: ErrorFormatter.format(e),
        ),
      );
    }
  }

  void _onSelectCircle(SelectCircle event, Emitter<DashboardState> emit) {
    final name = (event.circleName ?? '').trim();
    if (_uuidRegex.hasMatch(name)) {
      emit(state.copyWith(selectedCircle: name));
    } else {
      emit(state.copyWith(clearSelectedCircle: true));
    }
    add(const LoadDashboardData(isRefresh: true));
  }

  void _onTabChanged(TabChanged event, Emitter<DashboardState> emit) {
    emit(state.copyWith(activeTab: event.index));
  }
}
