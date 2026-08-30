import '../bloc/maintenance_bloc.dart';
import '../bloc/maintenance_event.dart';
import '../bloc/maintenance_state.dart';

abstract class MaintenanceViewContract {
  void onMaintenanceChecking();
  void onMaintenanceActive();
  void onMaintenanceCleared();
  void onMaintenanceBypassed();
  void onMaintenanceError(String error);
}

class MaintenancePresenter {
  final MaintenanceViewContract view;
  final MaintenanceBloc bloc;

  MaintenancePresenter({required this.view, required this.bloc});

  void checkStatus() {
    bloc.add(const CheckMaintenanceStatus());
  }

  void bypass() {
    bloc.add(const BypassMaintenanceEvent());
  }

  void handleStateChange(MaintenanceState state) {
    if (state.isChecking) {
      view.onMaintenanceChecking();
    } else if (state.isCleared) {
      view.onMaintenanceCleared();
    } else if (state.isBypassed) {
      view.onMaintenanceBypassed();
    } else if (state.errorMessage.isNotEmpty) {
      view.onMaintenanceError(state.errorMessage);
    } else {
      view.onMaintenanceActive();
    }
  }
}
