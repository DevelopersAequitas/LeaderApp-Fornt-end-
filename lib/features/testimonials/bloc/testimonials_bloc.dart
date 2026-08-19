import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/testimonial_model.dart';
import 'testimonials_event.dart';
import 'testimonials_state.dart';

class TestimonialsBloc extends Bloc<TestimonialsEvent, TestimonialsState> {
  TestimonialsBloc() : super(const TestimonialsState()) {
    on<LoadTestimonials>(_onLoadTestimonials);
    on<FilterTestimonials>(_onFilterTestimonials);
  }

  void _onLoadTestimonials(LoadTestimonials event, Emitter<TestimonialsState> emit) {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    final mockTestimonials = const [
      TestimonialModel(
        id: '1',
        fromName: 'Priya Sharma',
        toName: 'Ananya Patel',
        fromCompany: 'TechVentures',
        toCompany: 'HealthFirst',
        fromInitials: 'PS',
        rating: 5,
        content: 'Ananya connected me with three healthcare clients through PEERS. Exceptional networker and a true peer!',
        date: 'Jul 27, 2026',
      ),
      TestimonialModel(
        id: '2',
        fromName: 'James O\'Brien',
        toName: 'Priya Sharma',
        fromCompany: 'FinTech Pvt',
        toCompany: 'TechVentures',
        fromInitials: 'JO',
        rating: 5,
        content: 'Priya\'s introduction led to a ₹28k deal. The PEERS platform is transforming how we do business.',
        date: 'Jul 24, 2026',
      ),
      TestimonialModel(
        id: '3',
        fromName: 'Marcus Lee',
        toName: 'James O\'Brien',
        fromCompany: 'DevStudio',
        toCompany: 'FinTech Pvt',
        fromInitials: 'ML',
        rating: 5,
        content: 'James helped us close our first fintech integration deal. Absolutely peer excellence!',
        date: 'Jul 20, 2026',
      ),
    ];

    emit(state.copyWith(
      isLoading: false,
      allTestimonials: mockTestimonials,
      filteredTestimonials: mockTestimonials,
    ));
  }

  void _onFilterTestimonials(FilterTestimonials event, Emitter<TestimonialsState> emit) {
    final rating = event.rating;
    final filtered = rating == null
        ? state.allTestimonials
        : state.allTestimonials.where((t) => t.rating == rating).toList();

    emit(state.copyWith(
      selectedRatingFilter: rating,
      filteredTestimonials: filtered,
      clearRatingFilter: rating == null,
    ));
  }
}
