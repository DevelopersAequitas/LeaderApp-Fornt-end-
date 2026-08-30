import '../bloc/circle_details_bloc.dart';
import '../bloc/circle_details_event.dart';
import '../bloc/circle_details_state.dart';

abstract class CircleDetailsViewContract {
  void onCircleDetailsLoading();
  void onCircleDetailsLoaded();
  void onCircleDetailsError(String message);
}

class CircleDetailsPresenter {
  final CircleDetailsViewContract view;
  final CircleDetailsBloc bloc;

  CircleDetailsPresenter({required this.view, required this.bloc});

  void load({required String circleId, bool isRefresh = false}) {
    bloc.add(LoadCircleDetailsData(circleId: circleId, isRefresh: isRefresh));
  }

  void changeSubTab(int tabIndex) {
    bloc.add(ChangeCircleSubTabEvent(tabIndex));
  }

  void filterEvents(String filter) {
    bloc.add(FilterCircleEventsEvent(filter));
  }

  void handleStateChange(CircleDetailsState state) {
    if (state.isAnyLoading) {
      view.onCircleDetailsLoading();
    } else {
      view.onCircleDetailsLoaded();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onCircleDetailsError(state.errorMessage);
    }
  }
}
