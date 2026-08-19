import '../bloc/testimonials_bloc.dart';
import '../bloc/testimonials_event.dart';
import '../bloc/testimonials_state.dart';

abstract class TestimonialsViewContract {
  void onTestimonialsLoading();
  void onTestimonialsLoaded();
  void onTestimonialsError(String message);
}

class TestimonialsPresenter {
  final TestimonialsViewContract view;
  final TestimonialsBloc bloc;

  TestimonialsPresenter({required this.view, required this.bloc});

  void load() {
    bloc.add(const LoadTestimonials());
  }

  void filterByRating(int? rating) {
    bloc.add(FilterTestimonials(rating));
  }

  void handleStateChange(TestimonialsState state) {
    if (state.isLoading) {
      view.onTestimonialsLoading();
    } else {
      view.onTestimonialsLoaded();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onTestimonialsError(state.errorMessage);
    }
  }
}
