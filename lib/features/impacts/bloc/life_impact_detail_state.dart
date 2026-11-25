import '../model/life_impact_detail_model.dart';

class LifeImpactDetailState {
  final bool isLoading;
  final bool isSubmitting;
  final LifeImpactDetailModel? detail;
  final bool didMutate;
  final String actionMessage;
  final String errorMessage;

  const LifeImpactDetailState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.detail,
    this.didMutate = false,
    this.actionMessage = '',
    this.errorMessage = '',
  });

  LifeImpactDetailState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    LifeImpactDetailModel? detail,
    bool? didMutate,
    String? actionMessage,
    String? errorMessage,
  }) {
    return LifeImpactDetailState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      detail: detail ?? this.detail,
      didMutate: didMutate ?? this.didMutate,
      actionMessage: actionMessage ?? this.actionMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
