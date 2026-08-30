import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/circulars_repository.dart';
import '../model/circular_model.dart';
import 'circulars_event.dart';
import 'circulars_state.dart';

class CircularsBloc extends Bloc<CircularsEvent, CircularsState> {
  final CircularsRepository _circularsRepository;

  CircularsBloc({CircularsRepository? circularsRepository})
      : _circularsRepository = circularsRepository ?? CircularsRepositoryImpl(),
        super(const CircularsState()) {
    on<LoadCirculars>(_onLoadCirculars);
    on<FilterCircularsByPriority>(_onFilterCircularsByPriority);
    on<SearchCircularsEvent>(_onSearchCirculars);
    on<PublishCircularEvent>(_onPublishCircular);
  }

  List<CircularModel> _applyFilters(List<CircularModel> list, String priority, String query) {
    return list.where((c) {
      final matchesPriority =
          priority == 'All' || c.priority.toLowerCase() == priority.toLowerCase();
      final q = query.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          c.title.toLowerCase().contains(q) ||
          c.content.toLowerCase().contains(q) ||
          c.authorName.toLowerCase().contains(q);
      return matchesPriority && matchesSearch;
    }).toList();
  }

  Future<void> _onLoadCirculars(LoadCirculars event, Emitter<CircularsState> emit) async {
    if (!event.isRefresh) {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
    }

    try {
      final response = await _circularsRepository.getCirculars();
      final all = response.data ?? const [];
      final filtered = _applyFilters(all, state.selectedPriority, state.searchQuery);

      emit(state.copyWith(
        isLoading: false,
        allCirculars: all,
        filteredCirculars: filtered,
        errorMessage: '',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onFilterCircularsByPriority(
      FilterCircularsByPriority event, Emitter<CircularsState> emit) {
    final filtered = _applyFilters(state.allCirculars, event.priority, state.searchQuery);
    emit(state.copyWith(
      selectedPriority: event.priority,
      filteredCirculars: filtered,
    ));
  }

  void _onSearchCirculars(
      SearchCircularsEvent event, Emitter<CircularsState> emit) {
    final filtered = _applyFilters(state.allCirculars, state.selectedPriority, event.query);
    emit(state.copyWith(
      searchQuery: event.query,
      filteredCirculars: filtered,
    ));
  }

  Future<void> _onPublishCircular(
      PublishCircularEvent event, Emitter<CircularsState> emit) async {
    emit(state.copyWith(isPublishing: true));

    // Optimistically insert locally into memory
    final updatedAll = List<CircularModel>.from(state.allCirculars)..insert(0, event.circular);
    final filtered = _applyFilters(updatedAll, state.selectedPriority, state.searchQuery);

    emit(state.copyWith(
      allCirculars: updatedAll,
      filteredCirculars: filtered,
      successMessage: 'Circular broadcasted successfully!',
    ));

    try {
      await _circularsRepository.publishCircular(event.circular);
      emit(state.copyWith(isPublishing: false));
    } catch (e) {
      emit(state.copyWith(isPublishing: false, errorMessage: e.toString()));
    }
  }
}
