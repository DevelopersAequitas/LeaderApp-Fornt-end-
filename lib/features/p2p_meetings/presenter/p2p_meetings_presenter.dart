import '../bloc/p2p_meetings_bloc.dart';
import '../bloc/p2p_meetings_event.dart';
import '../bloc/p2p_meetings_state.dart';

abstract class P2PMeetingsViewContract {
  void onMeetingsLoading();
  void onMeetingsLoaded();
  void onMeetingsError(String message);
  void onMeetingCreatedSuccess(String message);
}

class P2PMeetingsPresenter {
  final P2PMeetingsViewContract view;
  final P2PMeetingsBloc bloc;

  P2PMeetingsPresenter({required this.view, required this.bloc});

  void loadMeetings({String? circleId}) {
    bloc.add(LoadP2PMeetings(circleId: circleId));
  }

  void createMeeting({
    required String peerUserId,
    required String scheduledAt,
    String mode = 'online',
    String location = 'Google Meet',
    String? notes,
  }) {
    bloc.add(CreateP2PMeetingEvent(
      peerUserId: peerUserId,
      scheduledAt: scheduledAt,
      mode: mode,
      location: location,
      notes: notes,
    ));
  }

  void handleStateChange(P2PMeetingsState state) {
    if (state.isLoading) {
      view.onMeetingsLoading();
    } else if (state.errorMessage.isNotEmpty) {
      view.onMeetingsError(state.errorMessage);
    } else {
      view.onMeetingsLoaded();
    }
    if (state.successMessage.isNotEmpty) {
      view.onMeetingCreatedSuccess(state.successMessage);
    }
  }
}
