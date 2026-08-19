import '../../peers/model/peer_model.dart';
import '../bloc/peer_profile_bloc.dart';
import '../bloc/peer_profile_event.dart';
import '../bloc/peer_profile_state.dart';

/// Contract interface defining Peer Profile view actions.
abstract class PeerProfileViewContract {
  void onProfileLoading();
  void onProfileLoaded();
  void onProfileError(String error);
  void onSubTabChanged(int index);
}

/// Presenter coordinating visual transitions for Peer Profile screen.
class PeerProfilePresenter {
  final PeerProfileViewContract view;
  final PeerProfileBloc bloc;

  PeerProfilePresenter({required this.view, required this.bloc});

  void load(PeerModel peer) {
    bloc.add(LoadPeerProfile(peer));
  }

  void changeSubTab(int index) {
    bloc.add(ChangeProfileSubTab(index));
  }

  void handleStateChange(PeerProfileState state) {
    view.onSubTabChanged(state.activeSubTab);

    if (state.isLoading) {
      view.onProfileLoading();
    } else {
      view.onProfileLoaded();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onProfileError(state.errorMessage);
    }
  }
}
