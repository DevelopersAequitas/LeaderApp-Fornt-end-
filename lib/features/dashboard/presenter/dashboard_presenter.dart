import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

/// Contract interface defining dashboard view actions.
abstract class DashboardViewContract {
  /// Invoked when loading begins.
  void onDashboardLoading();

  /// Invoked when data is successfully loaded.
  void onDashboardLoaded();

  /// Invoked when loading fails.
  void onDashboardError(String error);

  /// Invoked when active tab is changed.
  void onTabUpdated(int activeIndex);
}

/// Presenter coordinating presentation logic for Dashboard feature.
class DashboardPresenter {
  /// View contract reference.
  final DashboardViewContract view;

  /// BLoC reference.
  final DashboardBloc bloc;

  DashboardPresenter({required this.view, required this.bloc});

  /// Relays data fetch trigger.
  void load() {
    bloc.add(const LoadDashboardData());
  }

  /// Relays navigation tab modifications.
  void changeTab(int index) {
    bloc.add(TabChanged(index));
  }

  /// Relays active circle modifications.
  void selectCircle(String circleName) {
    bloc.add(SelectCircle(circleName));
  }

  /// Maps BLoC state changes back to view contract triggers.
  void handleStateChange(DashboardState state) {
    view.onTabUpdated(state.activeTab);

    if (state.isLoading) {
      view.onDashboardLoading();
    } else if (state.metrics != null) {
      view.onDashboardLoaded();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onDashboardError(state.errorMessage);
    }
  }
}
