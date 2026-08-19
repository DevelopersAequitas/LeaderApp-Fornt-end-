import '../bloc/peers_by_coins_bloc.dart';
import '../bloc/peers_by_coins_event.dart';
import '../bloc/peers_by_coins_state.dart';

abstract class PeersByCoinsViewContract {
  void onPeersByCoinsLoading();
  void onPeersByCoinsLoaded();
  void onPeersByCoinsError(String message);
}

class PeersByCoinsPresenter {
  final PeersByCoinsViewContract view;
  final PeersByCoinsBloc bloc;

  PeersByCoinsPresenter({required this.view, required this.bloc});

  void load() {
    bloc.add(const LoadPeersByCoins());
  }

  void filterStatus(String status) {
    bloc.add(FilterPeersByCoins(status));
  }

  void handleStateChange(PeersByCoinsState state) {
    if (state.isLoading) {
      view.onPeersByCoinsLoading();
    } else {
      view.onPeersByCoinsLoaded();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onPeersByCoinsError(state.errorMessage);
    }
  }
}
