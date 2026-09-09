import '../bloc/requirements_bloc.dart';
import '../bloc/requirements_event.dart';
import '../bloc/requirements_state.dart';

abstract class RequirementsViewContract {
  void onRequirementsLoading();
  void onRequirementsLoaded();
  void onRequirementsError(String message);
}

class RequirementsPresenter {
  final RequirementsViewContract view;
  final RequirementsBloc bloc;

  RequirementsPresenter({required this.view, required this.bloc});

  void loadRequirements({String? circleId}) {
    bloc.add(LoadRequirements(circleId: circleId));
  }

  void handleStateChange(RequirementsState state) {
    if (state.isLoading) {
      view.onRequirementsLoading();
    } else if (state.errorMessage.isNotEmpty) {
      view.onRequirementsError(state.errorMessage);
    } else {
      view.onRequirementsLoaded();
    }
  }
}
