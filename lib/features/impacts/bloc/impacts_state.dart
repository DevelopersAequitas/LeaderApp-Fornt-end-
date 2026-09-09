import '../model/impact_model.dart';

class ImpactsState {
  final bool isLoading;
  final bool isSubmitting;
  final List<ImpactModel> impacts;
  final String errorMessage;
  final String successMessage;

  const ImpactsState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.impacts = const [],
    this.errorMessage = '',
    this.successMessage = '',
  });

  ImpactsState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<ImpactModel>? impacts,
    String? errorMessage,
    String? successMessage,
  }) {
    return ImpactsState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      impacts: impacts ?? this.impacts,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
