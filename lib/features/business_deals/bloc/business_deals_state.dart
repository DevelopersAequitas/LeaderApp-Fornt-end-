import '../model/business_deal_model.dart';

class BusinessDealsState {
  final bool isLoading;
  final bool isSubmitting;
  final List<BusinessDealModel> deals;
  final String errorMessage;
  final String successMessage;

  const BusinessDealsState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.deals = const [],
    this.errorMessage = '',
    this.successMessage = '',
  });

  BusinessDealsState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<BusinessDealModel>? deals,
    String? errorMessage,
    String? successMessage,
  }) {
    return BusinessDealsState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      deals: deals ?? this.deals,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
