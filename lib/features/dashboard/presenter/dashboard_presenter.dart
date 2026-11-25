import '../../teams/model/teams_model.dart';
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

/// Presenter coordinating presentation logic and verified domain rules for the Dashboard.
class DashboardPresenter {
  /// View contract reference.
  final DashboardViewContract view;

  /// BLoC reference.
  final DashboardBloc bloc;

  DashboardPresenter({required this.view, required this.bloc});

  /// Relays initial data fetch trigger.
  void load() {
    bloc.add(const LoadDashboardData());
  }

  /// Relays pull-to-refresh or retry trigger.
  void refresh() {
    bloc.add(const LoadDashboardData(isRefresh: true));
  }

  /// Relays navigation tab modifications.
  void changeTab(int index) {
    bloc.add(TabChanged(index));
  }

  /// Relays active circle scope modifications.
  void selectCircle(String circleIdOrAll) {
    bloc.add(SelectCircle(circleIdOrAll));
  }

  /// Returns true ONLY when the backend explicitly marks a Circle's status or
  /// stage as requiring attention / at risk — never using invented numeric thresholds.
  static bool isBackendFlaggedCircle(CircleTeamModel circle) {
    final status = circle.status.trim().toLowerCase();
    final stage = (circle.stage ?? '').trim().toLowerCase();
    return status == 'at risk' ||
        status == 'at_risk' ||
        status == 'needs attention' ||
        status == 'needs_attention' ||
        stage == 'at risk' ||
        stage == 'needs attention';
  }

  /// Returns true when an active Circle has no Circle Director assigned in its
  /// leadership payload (`directors` list and `directorName` field both empty).
  static bool hasDirectorVacancy(CircleTeamModel circle) {
    if (circle.status.trim().toLowerCase() != 'active') return false;
    return circle.directors.isEmpty && circle.directorName.trim().isEmpty;
  }

  /// Returns true when an active Circle has no Circle Chairs assigned.
  static bool hasChairVacancy(CircleTeamModel circle) {
    if (circle.status.trim().toLowerCase() != 'active') return false;
    return circle.chairs.isEmpty && circle.chairName.trim().isEmpty;
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
