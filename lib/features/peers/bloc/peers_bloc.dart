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
    on<LoadMorePeersData>(_onLoadMorePeersData);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<StatusFilterChanged>(_onStatusFilterChanged);
    on<MetricSortChanged>(_onMetricSortChanged);
    on<ToggleSubTab>(_onToggleSubTab);
    on<SendWish>(_onSendWish);
  }

  Future<void> _onLoadPeersData(
    LoadPeersData event,
    Emitter<PeersState> emit,
  ) async {
    if (state.allPeers.isEmpty) {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
    }

    final session = SessionManager().currentSession;
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );

    String? activeCircle = event.selectedCircle ?? state.selectedCircle;
    if (activeCircle != null && !uuidRegex.hasMatch(activeCircle.trim())) {
      activeCircle = null;
    }
    if (activeCircle == null && session.managedCircles.isNotEmpty) {
      final first = session.managedCircles.first.trim();
      if (uuidRegex.hasMatch(first)) {
        activeCircle = first;
      }
    }

    try {
      final peersResponse = await _peersRepository.getPeers(
        circleId: activeCircle,
        status: state.selectedStatus,
        search: state.searchQuery,
        page: 1,
        perPage: 20,
      );

      final celebrationsResponse = await _peersRepository.getCelebrations(
        circleId: activeCircle,
      );

      final allPeers = peersResponse.data ?? const [];
      final filtered = _filterAndSort(
        allPeers,
        state.searchQuery,
        state.selectedStatus,
        state.selectedSort,
      );

      final meta = peersResponse.meta;
      final total = meta?.total ?? (allPeers.isNotEmpty ? allPeers.length : 0);

      emit(
        state.copyWith(
          isLoading: false,
          allPeers: allPeers,
          filteredPeers: filtered,
          currentPage: meta?.currentPage ?? 1,
          lastPage: meta?.lastPage ?? 1,
          totalPeersCount: total,
          birthdays: celebrationsResponse.data?.birthdays ?? const [],
          anniversaries: celebrationsResponse.data?.anniversaries ?? const [],
          selectedCircle: activeCircle,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMorePeersData(
    LoadMorePeersData event,
    Emitter<PeersState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));
    try {
      final nextPage = state.currentPage + 1;
      final peersResponse = await _peersRepository.getPeers(
        circleId: state.selectedCircle,
        status: state.selectedStatus,
        search: state.searchQuery,
        page: nextPage,
        perPage: 20,
      );

      final newPeers = peersResponse.data ?? const [];
      final existingIds = state.allPeers.map((p) => p.id).toSet();
      final combined = [
        ...state.allPeers,
        ...newPeers.where((p) => !existingIds.contains(p.id)),
      ];

      final filtered = _filterAndSort(
        combined,
        state.searchQuery,
        state.selectedStatus,
        state.selectedSort,
      );

      final meta = peersResponse.meta;
      emit(
        state.copyWith(
          isLoadingMore: false,
          allPeers: combined,
          filteredPeers: filtered,
          currentPage: meta?.currentPage ?? nextPage,
          lastPage: meta?.lastPage ?? state.lastPage,
          totalPeersCount: meta?.total ?? state.totalPeersCount,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
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
      await _peersRepository.sendWish(event.peerName, type: event.type);
    } catch (_) {}
  }

  // --- Filtering & Top-to-Bottom App-Side Sorting Logic ---

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
                p.location.toLowerCase().contains(cleanQuery) ||
                (p.level4Category != null &&
                    p.level4Category!.toLowerCase().contains(cleanQuery)) ||
                (p.industry != null &&
                    p.industry!.toLowerCase().contains(cleanQuery)),
          )
          .toList();
    }

    if (status != 'All') {
      final cleanStatus = status
          .toLowerCase()
          .replaceAll(' ', '')
          .replaceAll('_', '');
      result = result.where((p) {
        final pStatus = p.status
            .toLowerCase()
            .replaceAll(' ', '')
            .replaceAll('_', '');
        return pStatus == cleanStatus;
      }).toList();
    }

    result = List.from(result);
    final sortLower = sort.toLowerCase().trim();

    if (sortLower == 'impact') {
      // Top to bottom by highest Impact Count
      result.sort((a, b) {
        final cmp = b.impactCount.compareTo(a.impactCount);
        if (cmp != 0) return cmp;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    } else if (sortLower == 'deals') {
      // Top to bottom by highest Closed Deals value
      result.sort((a, b) {
        final cmp = _parseDeals(
          b.dealsFormatted,
        ).compareTo(_parseDeals(a.dealsFormatted));
        if (cmp != 0) return cmp;
        return b.impactCount.compareTo(a.impactCount);
      });
    } else if (sortLower == 'coins') {
      // Top to bottom by highest Coins earned
      result.sort((a, b) {
        final cmp = b.coins.compareTo(a.coins);
        if (cmp != 0) return cmp;
        return b.impactCount.compareTo(a.impactCount);
      });
    } else if (sortLower == 'attendance') {
      // Top to bottom by highest Attendance percentage
      result.sort((a, b) {
        final cmp = _parseAttendance(
          b.attendance,
        ).compareTo(_parseAttendance(a.attendance));
        if (cmp != 0) return cmp;
        return b.impactCount.compareTo(a.impactCount);
      });
    } else if (sortLower == 'name') {
      // Alphabetical A to Z
      result.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    } else {
      // Default: Top to bottom by Impact
      result.sort((a, b) => b.impactCount.compareTo(a.impactCount));
    }

    return result;
  }

  double _parseDeals(String deals) {
    if (deals.isEmpty) return 0.0;
    final clean = deals
        .replaceAll('₹', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();
    if (clean.toUpperCase().contains('CR')) {
      final val =
          double.tryParse(clean.toUpperCase().replaceAll('CR', '')) ?? 0.0;
      return val * 10000000.0;
    } else if (clean.toUpperCase().contains('L')) {
      final val =
          double.tryParse(clean.toUpperCase().replaceAll('L', '')) ?? 0.0;
      return val * 100000.0;
    } else if (clean.toUpperCase().contains('K')) {
      final val =
          double.tryParse(clean.toUpperCase().replaceAll('K', '')) ?? 0.0;
      return val * 1000.0;
    }
    return double.tryParse(clean) ?? 0.0;
  }

  double _parseAttendance(String val) {
    if (val.isEmpty) return 0.0;
    final clean = val.replaceAll('%', '').replaceAll(' ', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }
}
