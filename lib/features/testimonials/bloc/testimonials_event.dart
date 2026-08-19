import 'package:flutter/material.dart';

@immutable
abstract class TestimonialsEvent {
  const TestimonialsEvent();
}

class LoadTestimonials extends TestimonialsEvent {
  const LoadTestimonials();
}

class FilterTestimonials extends TestimonialsEvent {
  final int? rating;
  const FilterTestimonials(this.rating);
}
