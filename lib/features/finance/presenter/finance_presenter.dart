import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';

/// Contract interface defining Finance view callbacks.
abstract class FinanceViewContract {
  void onFinanceLoading();
  void onFinanceLoaded();
  void onFinanceError(String error);
}

/// Presenter coordinating Finance access validations.
class FinancePresenter {
  final FinanceViewContract view;
  final FinanceBloc bloc;

  FinancePresenter({required this.view, required this.bloc});

  void load({String? selectedCircle}) {
    bloc.add(LoadFinanceData(selectedCircle: selectedCircle));
  }

  void handleStateChange(FinanceState state) {
    if (state.isLoading) {
      view.onFinanceLoading();
    } else {
      view.onFinanceLoaded();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onFinanceError(state.errorMessage);
    }
  }
}
