import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/referrals_repository.dart';
import 'testimonials_event.dart';
import 'testimonials_state.dart';

class TestimonialsBloc extends Bloc<TestimonialsEvent, TestimonialsState> {
  final ReferralsRepository _referralsRepository;

  TestimonialsBloc({ReferralsRepository? referralsRepository})
      : _referralsRepository = referralsRepository ?? ReferralsRepositoryImpl(),
        super(const TestimonialsState()) {
    on<LoadTestimonials>(_onLoadTestimonials);
    on<FilterTestimonials>(_onFilterTestimonials);
  }

  Future<void> _onLoadTestimonials(
    LoadTestimonials event,
    Emitter<TestimonialsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    try {
      final response = await _referralsRepository.getTestimonials();
      final allTestimonials = response.data ?? const [];

      emit(state.copyWith(
        isLoading: false,
        allTestimonials: allTestimonials,
        filteredTestimonials: allTestimonials,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onFilterTestimonials(
    FilterTestimonials event,
    Emitter<TestimonialsState> emit,
  ) {
    emit(state.copyWith(
      filteredTestimonials: state.allTestimonials,
    ));
  }
}
