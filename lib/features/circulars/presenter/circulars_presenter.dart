import '../bloc/circulars_bloc.dart';
import '../bloc/circulars_event.dart';
import '../bloc/circulars_state.dart';
import '../model/circular_model.dart';

abstract class CircularsViewContract {
  void onCircularsLoading();
  void onCircularsLoaded();
  void onCircularsError(String message);
  void onCircularPublishSuccess(String message);
}

class CircularsPresenter {
  final CircularsViewContract view;
  final CircularsBloc bloc;

  CircularsPresenter({required this.view, required this.bloc});

  void load({bool isRefresh = false}) {
    bloc.add(LoadCirculars(isRefresh: isRefresh));
  }

  void filterPriority(String priority) {
    bloc.add(FilterCircularsByPriority(priority));
  }

  void search(String query) {
    bloc.add(SearchCircularsEvent(query));
  }

  void publish(CircularModel circular) {
    bloc.add(PublishCircularEvent(circular));
  }

  void handleStateChange(CircularsState state) {
    if (state.isLoading) {
      view.onCircularsLoading();
    } else {
      view.onCircularsLoaded();
    }

    if (state.errorMessage.isNotEmpty) {
      view.onCircularsError(state.errorMessage);
    }

    if (state.successMessage != null && state.successMessage!.isNotEmpty) {
      view.onCircularPublishSuccess(state.successMessage!);
    }
  }
}
