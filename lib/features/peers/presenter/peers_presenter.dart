import '../bloc/peers_bloc.dart';
import '../bloc/peers_event.dart';
import '../bloc/peers_state.dart';

/// Contract interface defining Peers view callback events.
abstract class PeersViewContract {
  /// Invoked when loading begins.
  void onPeersLoading();

  /// Invoked when data successfully loads.
  void onPeersLoaded();

  /// Invoked when loading/operation errors occur.
  void onPeersError(String error);

  /// Invoked when a wish successfully triggers.
  void onWishSent(String peerName, String type);

  /// Invoked when active sub tab changes.
  void onTabChanged(int index);
}

/// Presenter coordinating presentation logic for Peers tab feature.
class PeersPresenter {
  /// View contract reference.
  final PeersViewContract view;

  /// BLoC reference.
  final PeersBloc bloc;

  PeersPresenter({required this.view, required this.bloc});

  /// Relays data fetch trigger.
  void load({String? selectedCircle}) {
    bloc.add(LoadPeersData(selectedCircle: selectedCircle));
  }

  /// Relays search input modifications.
  void search(String query) {
    bloc.add(SearchQueryChanged(query));
  }

  /// Relays status filter modifications.
  void filterStatus(String status) {
    bloc.add(StatusFilterChanged(status));
  }

  /// Relays sort metric modifications.
  void sortMetric(String metric) {
    bloc.add(MetricSortChanged(metric));
  }

  /// Relays active sub tab toggles.
  void changeSubTab(int tabIndex) {
    bloc.add(ToggleSubTab(tabIndex));
  }

  /// Relays wish triggers and invokes view confirmations.
  void sendWish(String peerName, String type) {
    bloc.add(SendWish(peerName, type));
    view.onWishSent(peerName, type);
  }

  /// Maps BLoC state changes back to view contract triggers.
  void handleStateChange(PeersState state) {
    view.onTabChanged(state.activeSubTab);

    if (state.isLoading) {
      view.onPeersLoading();
    } else {
      view.onPeersLoaded();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onPeersError(state.errorMessage);
    }
  }
}
