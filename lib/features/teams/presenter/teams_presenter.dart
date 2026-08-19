import '../bloc/teams_bloc.dart';
import '../bloc/teams_event.dart';
import '../bloc/teams_state.dart';

/// Contract interface defining Teams view callbacks.
abstract class TeamsViewContract {
  void onTeamsLoading();
  void onTeamsLoaded();
  void onTeamsError(String error);
}

/// Presenter coordinating Teams access validations.
class TeamsPresenter {
  final TeamsViewContract view;
  final TeamsBloc bloc;

  TeamsPresenter({required this.view, required this.bloc});

  void load({String? selectedCircle}) {
    bloc.add(LoadTeamsData(selectedCircle: selectedCircle));
  }

  /// Relays search query changes for circle teams.
  void searchCircles(String query) {
    bloc.add(SearchCirclesQueryChanged(query));
  }

  /// Relays status filter changes for circle teams.
  void filterCirclesStatus(String status) {
    bloc.add(StatusCirclesFilterChanged(status));
  }

  /// Relays industry filter changes for circle teams.
  void filterCirclesIndustry(String industry) {
    bloc.add(IndustryCirclesFilterChanged(industry));
  }

  void handleStateChange(TeamsState state) {
    if (state.isLoading) {
      view.onTeamsLoading();
    } else {
      view.onTeamsLoaded();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onTeamsError(state.errorMessage);
    }
  }
}
