import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/teams_repository.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../model/teams_model.dart';
import 'teams_event.dart';
import 'teams_state.dart';

/// Business Logic Component for managing Teams & Circles directory via Clean Architecture.
class TeamsBloc extends Bloc<TeamsEvent, TeamsState> {
  final TeamsRepository _teamsRepository;

  TeamsBloc({TeamsRepository? teamsRepository})
      : _teamsRepository = teamsRepository ?? TeamsRepositoryImpl(),
        super(const TeamsState()) {
    on<LoadTeamsData>(_onLoadTeamsData);
    on<SearchCirclesQueryChanged>(_onSearchCirclesQueryChanged);
    on<StatusCirclesFilterChanged>(_onStatusCirclesFilterChanged);
    on<IndustryCirclesFilterChanged>(_onIndustryCirclesFilterChanged);
  }

  Future<void> _onLoadTeamsData(LoadTeamsData event, Emitter<TeamsState> emit) async {
    if (state.allCircles.isEmpty) {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
    }

    final session = SessionManager().currentSession;
    final permissions = SessionManager().permissions;
    final isRestricted = !permissions.canAccessTeamsTab && session.role == UserRole.circleChair;

    final permissionModel = TeamsPermissionModel(
      role: session.customRoleLabel ?? session.role.label,
      isRestricted: isRestricted,
      requiredCapabilities: const ['Access Circles & Teams', 'Manage Circles Directory'],
    );

    if (isRestricted) {
      emit(
        state.copyWith(
          isLoading: false,
          permission: permissionModel,
          allCircles: const [],
          filteredCircles: const [],
        ),
      );
      return;
    }

    final activeCircle = event.selectedCircle ?? state.selectedCircle ?? '';

    try {
      final industriesResponse = await _teamsRepository.getIndustriesList();
      final circlesResponse = await _teamsRepository.getCircles();

      final allCircles = circlesResponse.data ?? const [];
      final filtered = _filterAndSortCircles(
        allCircles,
        state.searchQuery,
        state.selectedStatusFilter,
        state.selectedIndustryFilter,
      );

      final List<IndustryModel> rawIndustries = industriesResponse.data ?? [];
      final List<String> industriesSet = ['All Industries'];
      for (final ind in rawIndustries) {
        final name = ind.name.trim();
        if (name.isNotEmpty && !industriesSet.contains(name)) {
          industriesSet.add(name);
        }
      }

      emit(
        state.copyWith(
          isLoading: false,
          permission: permissionModel,
          allCircles: allCircles,
          filteredCircles: filtered,
          selectedCircle: activeCircle,
          availableIndustries: industriesSet,
          industriesList: rawIndustries,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onSearchCirclesQueryChanged(
    SearchCirclesQueryChanged event,
    Emitter<TeamsState> emit,
  ) {
    final filtered = _filterAndSortCircles(
      state.allCircles,
      event.query,
      state.selectedStatusFilter,
      state.selectedIndustryFilter,
    );
    emit(state.copyWith(searchQuery: event.query, filteredCircles: filtered));
  }

  void _onStatusCirclesFilterChanged(
    StatusCirclesFilterChanged event,
    Emitter<TeamsState> emit,
  ) {
    final filtered = _filterAndSortCircles(
      state.allCircles,
      state.searchQuery,
      event.status,
      state.selectedIndustryFilter,
    );
    emit(
      state.copyWith(
        selectedStatusFilter: event.status,
        filteredCircles: filtered,
      ),
    );
  }

  void _onIndustryCirclesFilterChanged(
    IndustryCirclesFilterChanged event,
    Emitter<TeamsState> emit,
  ) {
    final filtered = _filterAndSortCircles(
      state.allCircles,
      state.searchQuery,
      state.selectedStatusFilter,
      event.industry,
    );
    emit(
      state.copyWith(
        selectedIndustryFilter: event.industry,
        filteredCircles: filtered,
      ),
    );
  }

  List<CircleTeamModel> _filterAndSortCircles(
    List<CircleTeamModel> list,
    String query,
    String status,
    String industry,
  ) {
    var result = list;

    if (query.trim().isNotEmpty) {
      final cleanQuery = query.toLowerCase().trim();
      result = result
          .where(
            (c) =>
                c.name.toLowerCase().contains(cleanQuery) ||
                c.category.toLowerCase().contains(cleanQuery) ||
                c.location.toLowerCase().contains(cleanQuery) ||
                c.founderName.toLowerCase().contains(cleanQuery),
          )
          .toList();
    }

    if (status != 'All') {
      result = result.where((c) => c.status.toLowerCase() == status.toLowerCase()).toList();
    }

    if (industry != 'All Industries') {
      final cleanIndustry = industry.toLowerCase().trim();
      result = result
          .where((c) => c.category.toLowerCase().trim() == cleanIndustry)
          .toList();
    }

    return result;
  }
}
