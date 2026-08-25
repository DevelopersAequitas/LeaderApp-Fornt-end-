import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/peers_repository.dart';
import '../../../core/helpers/session_manager.dart';
import '../model/peer_model.dart';
import 'peers_event.dart';
import 'peers_state.dart';

/// Business Logic Component for managing Peers listings, filtering, sorting, and celebrations.
class PeersBloc extends Bloc<PeersEvent, PeersState> {
  final PeersRepository _peersRepository;

  PeersBloc({PeersRepository? peersRepository})
      : _peersRepository = peersRepository ?? PeersRepositoryImpl(),
        super(const PeersState()) {
    on<LoadPeersData>(_onLoadPeersData);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<StatusFilterChanged>(_onStatusFilterChanged);
    on<MetricSortChanged>(_onMetricSortChanged);
    on<ToggleSubTab>(_onToggleSubTab);
    on<SendWish>(_onSendWish);
  }

  Future<void> _onLoadPeersData(LoadPeersData event, Emitter<PeersState> emit) async {
    if (state.allPeers.isEmpty) {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
    }

    final session = SessionManager().currentSession;
    final activeCircle =
        event.selectedCircle ??
        state.selectedCircle ??
        (session.managedCircles.isNotEmpty
            ? session.managedCircles.first
            : (session.regionalScope.isNotEmpty ? session.regionalScope : null));

    try {
      final peersResponse = await _peersRepository.getPeers(
        circleId: activeCircle,
        status: state.selectedStatus,
        sort: state.selectedSort,
        search: state.searchQuery,
      );

      final celebrationsResponse = await _peersRepository.getCelebrations(circleId: activeCircle);

      final allPeers = peersResponse.data ?? const [];
      final filtered = _filterAndSort(
        allPeers,
        state.searchQuery,
        state.selectedStatus,
        state.selectedSort,
      );

      emit(
        state.copyWith(
          isLoading: false,
          allPeers: allPeers,
          filteredPeers: filtered,
          birthdays: celebrationsResponse.data?.birthdays ?? const [],
          anniversaries: celebrationsResponse.data?.anniversaries ?? const [],
          selectedCircle: activeCircle,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<PeersState> emit,
  ) {
    final filtered = _filterAndSort(
      state.allPeers,
      event.query,
      state.selectedStatus,
      state.selectedSort,
    );
    emit(state.copyWith(searchQuery: event.query, filteredPeers: filtered));
  }

  void _onStatusFilterChanged(
    StatusFilterChanged event,
    Emitter<PeersState> emit,
  ) {
    final filtered = _filterAndSort(
      state.allPeers,
      state.searchQuery,
      event.status,
      state.selectedSort,
    );
    emit(state.copyWith(selectedStatus: event.status, filteredPeers: filtered));
  }

  void _onMetricSortChanged(MetricSortChanged event, Emitter<PeersState> emit) {
    final filtered = _filterAndSort(
      state.allPeers,
      state.searchQuery,
      state.selectedStatus,
      event.metric,
    );
    emit(state.copyWith(selectedSort: event.metric, filteredPeers: filtered));
  }

  void _onToggleSubTab(ToggleSubTab event, Emitter<PeersState> emit) {
    emit(state.copyWith(activeSubTab: event.tabIndex));
  }

  Future<void> _onSendWish(SendWish event, Emitter<PeersState> emit) async {
    try {
      await _peersRepository.sendWish(
        event.peerName,
        type: event.type,
      );
    } catch (_) {}
  }

  // --- Filtering & Sorting Helpers ---

  List<PeerModel> _filterAndSort(
    List<PeerModel> list,
    String query,
    String status,
    String sort,
  ) {
    var result = list;
    if (query.trim().isNotEmpty) {
      final cleanQuery = query.toLowerCase().trim();
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(cleanQuery) ||
                p.company.toLowerCase().contains(cleanQuery) ||
                p.circle.toLowerCase().contains(cleanQuery) ||
                p.tags.toLowerCase().contains(cleanQuery) ||
                p.location.toLowerCase().contains(cleanQuery),
          )
          .toList();
    }

    if (status != 'All') {
      final cleanStatus = status.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
      result = result.where((p) {
        final pStatus = p.status.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
        return pStatus == cleanStatus;
      }).toList();
    }

    result = List.from(result);
    if (sort == 'Impact') {
      result.sort((a, b) => b.impactCount.compareTo(a.impactCount));
    } else if (sort == 'Deals') {
      result.sort(
        (a, b) => _parseDeals(
          b.dealsFormatted,
        ).compareTo(_parseDeals(a.dealsFormatted)),
      );
    } else if (sort == 'Coins') {
      result.sort((a, b) => b.coins.compareTo(a.coins));
    } else if (sort == 'Attendance') {
      result.sort(
        (a, b) => _parseAttendance(
          b.attendance,
        ).compareTo(_parseAttendance(a.attendance)),
      );
    }

    return result;
  }

  double _parseDeals(String deals) {
    final clean = deals.replaceAll('₹', '').replaceAll(' ', '');
    if (clean.contains('Cr')) {
      final val = double.tryParse(clean.replaceAll('Cr', '')) ?? 0.0;
      return val * 100.0;
    } else if (clean.contains('L')) {
      return double.tryParse(clean.replaceAll('L', '')) ?? 0.0;
    }
    return 0.0;
  }

  int _parseAttendance(String val) {
    final clean = val.replaceAll('%', '').trim();
    return int.tryParse(clean) ?? 0;
  }
}
