import '../bloc/member_activities_bloc.dart';
import '../bloc/member_activities_event.dart';
import '../model/member_activity_model.dart';

/// MVP presenter: the view never dispatches BLoC events directly.
class MemberActivitiesPresenter {
  final MemberActivitiesBloc bloc;

  const MemberActivitiesPresenter({required this.bloc});

  void load({required String memberId, required MemberActivityType type}) {
    bloc.add(LoadMemberActivities(memberId: memberId, type: type));
  }

  void refresh() {
    final state = bloc.state;
    bloc.add(LoadMemberActivities(memberId: state.memberId, type: state.type));
  }

  void loadMore() => bloc.add(const LoadMoreMemberActivities());
}
