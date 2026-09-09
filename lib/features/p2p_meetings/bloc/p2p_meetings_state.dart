import '../model/p2p_meeting_model.dart';

class P2PMeetingsState {
  final bool isLoading;
  final bool isSubmitting;
  final List<P2PMeetingModel> meetings;
  final String errorMessage;
  final String successMessage;

  const P2PMeetingsState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.meetings = const [],
    this.errorMessage = '',
    this.successMessage = '',
  });

  P2PMeetingsState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<P2PMeetingModel>? meetings,
    String? errorMessage,
    String? successMessage,
  }) {
    return P2PMeetingsState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      meetings: meetings ?? this.meetings,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
