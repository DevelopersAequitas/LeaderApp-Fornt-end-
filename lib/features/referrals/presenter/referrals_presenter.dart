import '../bloc/referrals_bloc.dart';
import '../bloc/referrals_event.dart';
import '../bloc/referrals_state.dart';

abstract class ReferralsViewContract {
  void onReferralsLoading();
  void onReferralsLoaded();
  void onReferralsError(String message);
}

class ReferralsPresenter {
  final ReferralsViewContract view;
  final ReferralsBloc bloc;

  ReferralsPresenter({required this.view, required this.bloc});

  void load() {
    bloc.add(const LoadReferrals());
  }

  void filterStatus(String status) {
    bloc.add(FilterReferrals(status));
  }

  void handleStateChange(ReferralsState state) {
    if (state.isLoading) {
      view.onReferralsLoading();
    } else {
      view.onReferralsLoaded();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onReferralsError(state.errorMessage);
    }
  }
}
