import 'package:equatable/equatable.dart';
import '../model/circular_model.dart';

class CircularsState extends Equatable {
  final bool isLoading;
  final bool isPublishing;
  final List<CircularModel> allCirculars;
  final List<CircularModel> filteredCirculars;
  final String selectedPriority;
  final String searchQuery;
  final String errorMessage;
  final String? successMessage;

  const CircularsState({
    this.isLoading = false,
    this.isPublishing = false,
    this.allCirculars = const [],
    this.filteredCirculars = const [],
    this.selectedPriority = 'All',
    this.searchQuery = '',
    this.errorMessage = '',
    this.successMessage,
  });

  CircularsState copyWith({
    bool? isLoading,
    bool? isPublishing,
    List<CircularModel>? allCirculars,
    List<CircularModel>? filteredCirculars,
    String? selectedPriority,
    String? searchQuery,
    String? errorMessage,
    String? successMessage,
  }) {
    return CircularsState(
      isLoading: isLoading ?? this.isLoading,
      isPublishing: isPublishing ?? this.isPublishing,
      allCirculars: allCirculars ?? this.allCirculars,
      filteredCirculars: filteredCirculars ?? this.filteredCirculars,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isPublishing,
        allCirculars,
        filteredCirculars,
        selectedPriority,
        searchQuery,
        errorMessage,
        successMessage,
      ];
}
