import '../model/requirement_model.dart';

class RequirementsState {
  final bool isLoading;
  final List<RequirementModel> requirements;
  final String errorMessage;

  const RequirementsState({
    this.isLoading = false,
    this.requirements = const [],
    this.errorMessage = '',
  });

  RequirementsState copyWith({
    bool? isLoading,
    List<RequirementModel>? requirements,
    String? errorMessage,
  }) {
    return RequirementsState(
      isLoading: isLoading ?? this.isLoading,
      requirements: requirements ?? this.requirements,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
