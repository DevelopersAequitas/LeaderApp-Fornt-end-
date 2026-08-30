import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/teams_repository.dart';
import '../model/circle_event_model.dart';
import 'circle_details_event.dart';
import 'circle_details_state.dart';

class CircleDetailsBloc extends Bloc<CircleDetailsEvent, CircleDetailsState> {
  final TeamsRepository _teamsRepository;

  CircleDetailsBloc({TeamsRepository? teamsRepository})
      : _teamsRepository = teamsRepository ?? TeamsRepositoryImpl(),
        super(const CircleDetailsState()) {
    on<LoadCircleDetailsData>(_onLoadCircleDetailsData);
    on<ChangeCircleSubTabEvent>(_onChangeCircleSubTab);
    on<FilterCircleEventsEvent>(_onFilterCircleEvents);
  }

  List<CircleEventModel> _applyEventFilter(List<CircleEventModel> events, String filter) {
    if (filter == 'All') return events;
    return events.where((e) {
      if (filter.toLowerCase() == 'upcoming') {
        return e.status.toLowerCase() == 'upcoming' || e.status.toLowerCase() == 'scheduled';
      }
      if (filter.toLowerCase() == 'completed') {
        return e.status.toLowerCase() == 'completed' || e.status.toLowerCase() == 'concluded';
      }
      return e.status.toLowerCase() == filter.toLowerCase();
    }).toList();
  }

  Future<void> _onLoadCircleDetailsData(
      LoadCircleDetailsData event, Emitter<CircleDetailsState> emit) async {
    final cId = event.circleId;
    if (cId.isEmpty) return;

    emit(state.copyWith(
      isLoadingCircle: true,
      isLoadingPeers: true,
      isLoadingSubIndustries: true,
      isLoadingEvents: true,
      errorMessage: '',
    ));

    // 1. Fetch updated Circle Details
    try {
      final circleRes = await _teamsRepository.getCircleDetails(cId);
      if (circleRes.success && circleRes.data != null) {
        emit(state.copyWith(circle: circleRes.data, isLoadingCircle: false));
      } else {
        emit(state.copyWith(isLoadingCircle: false));
      }
    } catch (_) {
      emit(state.copyWith(isLoadingCircle: false));
    }

    // 2. Fetch Circle Peers
    try {
      final peersRes = await _teamsRepository.getCirclePeers(cId);
      final peers = (peersRes.data ?? []).where((p) {
        final peerCircleId = p.circleId;
        if (peerCircleId != null && peerCircleId.isNotEmpty && peerCircleId != cId) {
          return false;
        }
        return true;
      }).toList();

      emit(state.copyWith(circlePeers: peers, isLoadingPeers: false));
    } catch (_) {
      emit(state.copyWith(isLoadingPeers: false));
    }

    // 3. Fetch Sub-Industries
    try {
      final subIndRes = await _teamsRepository.getSubIndustries(cId);
      emit(state.copyWith(subIndustries: subIndRes.data, isLoadingSubIndustries: false));
    } catch (_) {
      emit(state.copyWith(isLoadingSubIndustries: false));
    }

    // 4. Fetch Circle Events
    try {
      final eventsRes = await _teamsRepository.getCircleEvents(cId, filter: state.selectedEventFilter);
      final events = (eventsRes.data ?? []).where((e) {
        if (e.circleId.isNotEmpty && e.circleId != cId) return false;
        return true;
      }).toList();

      final filtered = _applyEventFilter(events, state.selectedEventFilter);
      emit(state.copyWith(
        allEvents: events,
        filteredEvents: filtered,
        isLoadingEvents: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingEvents: false));
    }
  }

  void _onChangeCircleSubTab(
      ChangeCircleSubTabEvent event, Emitter<CircleDetailsState> emit) {
    emit(state.copyWith(activeSubTab: event.tabIndex));
  }

  void _onFilterCircleEvents(
      FilterCircleEventsEvent event, Emitter<CircleDetailsState> emit) {
    final filtered = _applyEventFilter(state.allEvents, event.filter);
    emit(state.copyWith(
      selectedEventFilter: event.filter,
      filteredEvents: filtered,
    ));
  }
}
