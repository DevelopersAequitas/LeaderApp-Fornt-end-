import '../bloc/impacts_bloc.dart';
import '../bloc/impacts_event.dart';
import '../bloc/impacts_state.dart';

abstract class ImpactsViewContract {
  void onImpactsLoading();
  void onImpactsLoaded();
  void onImpactsError(String message);
  void onImpactCreatedSuccess(String message);
}

class ImpactsPresenter {
  final ImpactsViewContract view;
  final ImpactsBloc bloc;

  ImpactsPresenter({required this.view, required this.bloc});

  void loadImpacts({String? circleId}) {
    bloc.add(LoadImpacts(circleId: circleId));
  }

  void createImpact({
    required String beneficiaryUserId,
    required String impactType,
    required String title,
    required String description,
  }) {
    bloc.add(CreateImpactEvent(
      beneficiaryUserId: beneficiaryUserId,
      impactType: impactType,
      title: title,
      description: description,
    ));
  }

  void handleStateChange(ImpactsState state) {
    if (state.isLoading) {
      view.onImpactsLoading();
    } else if (state.errorMessage.isNotEmpty) {
      view.onImpactsError(state.errorMessage);
    } else {
      view.onImpactsLoaded();
    }
    if (state.successMessage.isNotEmpty) {
      view.onImpactCreatedSuccess(state.successMessage);
    }
  }
}
