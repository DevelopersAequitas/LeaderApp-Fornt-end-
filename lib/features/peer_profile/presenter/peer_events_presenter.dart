import '../bloc/peer_events_bloc.dart';
import '../bloc/peer_events_event.dart';
import '../bloc/peer_events_state.dart';

abstract class PeerEventsViewContract {
  void onPeerEventsLoading();
  void onPeerEventsLoaded();
  void onPeerEventsError(String message);
}

class PeerEventsPresenter {
  final PeerEventsViewContract view;
  final PeerEventsBloc bloc;

  PeerEventsPresenter({required this.view, required this.bloc});

  void load({required String memberId, bool isRefresh = false}) {
    bloc.add(LoadPeerEventsData(memberId: memberId, isRefresh: isRefresh));
  }

  void changeTab(int tabIndex) {
    bloc.add(ChangePeerEventsTab(tabIndex));
  }

  void handleStateChange(PeerEventsState state) {
    if (state.isLoading) {
      view.onPeerEventsLoading();
    } else {
      view.onPeerEventsLoaded();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onPeerEventsError(state.errorMessage);
    }
  }
}
