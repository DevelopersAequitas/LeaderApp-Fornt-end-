import 'package:flutter/material.dart';
import '../model/testimonial_model.dart';

@immutable
class TestimonialsState {
  final bool isLoading;
  final List<TestimonialModel> allTestimonials;
  final List<TestimonialModel> filteredTestimonials;
  final int? selectedRatingFilter; // null means 'All'
  final String errorMessage;

  const TestimonialsState({
    this.isLoading = false,
    this.allTestimonials = const [],
    this.filteredTestimonials = const [],
    this.selectedRatingFilter,
    this.errorMessage = '',
  });

  TestimonialsState copyWith({
    bool? isLoading,
    List<TestimonialModel>? allTestimonials,
    List<TestimonialModel>? filteredTestimonials,
    int? selectedRatingFilter,
    String? errorMessage,
    bool clearRatingFilter = false,
  }) {
    return TestimonialsState(
      isLoading: isLoading ?? this.isLoading,
      allTestimonials: allTestimonials ?? this.allTestimonials,
      filteredTestimonials: filteredTestimonials ?? this.filteredTestimonials,
      selectedRatingFilter: clearRatingFilter ? null : (selectedRatingFilter ?? this.selectedRatingFilter),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
