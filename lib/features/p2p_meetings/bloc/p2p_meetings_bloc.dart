import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/error_formatter.dart';
import '../../../data/repositories/activities_repository.dart';
import 'p2p_meetings_event.dart';
import 'p2p_meetings_state.dart';

class P2PMeetingsBloc extends Bloc<P2PMeetingsEvent, P2PMeetingsState> {
  final ActivitiesRepository _repository;

  P2PMeetingsBloc({ActivitiesRepository? repository})
      : _repository = repository ?? ActivitiesRepositoryImpl(),
        super(const P2PMeetingsState()) {
    on<LoadP2PMeetings>(_onLoadP2PMeetings);
    on<CreateP2PMeetingEvent>(_onCreateP2PMeeting);
  }

  Future<void> _onLoadP2PMeetings(
    LoadP2PMeetings event,
    Emitter<P2PMeetingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: '', successMessage: ''));
    try {
      final response = await _repository.getP2PMeetings(circleId: event.circleId);
      if (response.success && response.data != null) {
        emit(state.copyWith(isLoading: false, meetings: response.data!));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: response.message != null
              ? ErrorFormatter.format(response.message)
              : 'Unable to load P2P meetings. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: ErrorFormatter.format(e)));
    }
  }

  Future<void> _onCreateP2PMeeting(
    CreateP2PMeetingEvent event,
    Emitter<P2PMeetingsState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: '', successMessage: ''));
    try {
      final response = await _repository.createP2PMeeting(
        peerUserId: event.peerUserId,
        scheduledAt: event.scheduledAt,
        mode: event.mode,
        location: event.location,
        notes: event.notes,
      );
      if (response.success && response.data != null) {
        final updatedList = [response.data!, ...state.meetings];
        emit(state.copyWith(
          isSubmitting: false,
          meetings: updatedList,
          successMessage: 'P2P Meeting scheduled successfully!',
        ));
      } else {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: response.message != null
              ? ErrorFormatter.format(response.message)
              : 'Unable to schedule P2P meeting. Please check the details and try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: ErrorFormatter.format(e)));
    }
  }
}
