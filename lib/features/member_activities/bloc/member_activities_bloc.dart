import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/error_formatter.dart';
import '../../../data/repositories/peers_repository.dart';
import '../model/member_activity_model.dart';
import 'member_activities_event.dart';
import 'member_activities_state.dart';

/// Fetches `GET /leader/members/{member_id}/activities` filtered by category.
class MemberActivitiesBloc
    extends Bloc<MemberActivitiesEvent, MemberActivitiesState> {
  static const int _pageSize = 20;

  final PeersRepository _repository;

  MemberActivitiesBloc({PeersRepository? repository})
    : _repository = repository ?? PeersRepositoryImpl(),
      super(const MemberActivitiesState()) {
    on<LoadMemberActivities>(_onLoad);
    on<LoadMoreMemberActivities>(_onLoadMore);
  }

  Future<void> _onLoad(
    LoadMemberActivities event,
    Emitter<MemberActivitiesState> emit,
  ) async {
    emit(
      state.copyWith(
        memberId: event.memberId,
        type: event.type,
        isLoading: true,
        errorMessage: '',
      ),
    );
    try {
      final response = await _fetch(event.memberId, event.type, 1);
      if (response.success && response.data != null) {
        final items = _filterByType(response.data!, event.type);
        emit(
          state.copyWith(
            isLoading: false,
            activities: items,
            page: 1,
            hasMore: _hasMore(response),
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: response.message != null
                ? ErrorFormatter.format(response.message)
                : 'Unable to load ${event.type.title.toLowerCase()}. Please try again.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: ErrorFormatter.format(e),
        ),
      );
    }
  }

  Future<void> _onLoadMore(
    LoadMoreMemberActivities event,
    Emitter<MemberActivitiesState> emit,
  ) async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true, errorMessage: ''));
    final nextPage = state.page + 1;
    try {
      final response = await _fetch(state.memberId, state.type, nextPage);
      if (response.success && response.data != null) {
        final items = _filterByType(response.data!, state.type);
        emit(
          state.copyWith(
            isLoadingMore: false,
            activities: [...state.activities, ...items],
            page: nextPage,
            hasMore: _hasMore(response),
          ),
        );
      } else {
        emit(state.copyWith(isLoadingMore: false, hasMore: false));
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: ErrorFormatter.format(e),
        ),
      );
    }
  }

  Future<ApiResponse<List<MemberActivityModel>>> _fetch(
    String memberId,
    MemberActivityType type,
    int page,
  ) {
    return _repository.getMemberActivities(
      memberId,
      type: type == MemberActivityType.other ? null : type.apiValue,
      endpointPath: type.endpointPath,
      page: page,
      limit: _pageSize,
    );
  }

  /// Guards against backends that ignore the `type` query param so each
  /// screen only ever shows its own category.
  List<MemberActivityModel> _filterByType(
    List<MemberActivityModel> items,
    MemberActivityType type,
  ) {
    if (type == MemberActivityType.other) return items;

    if (type == MemberActivityType.dealGiven) {
      return items
          .where(
            (a) =>
                a.type == MemberActivityType.dealGiven ||
                a.metadata['member_role'] == 'giver',
          )
          .toList();
    }
    if (type == MemberActivityType.dealReceived) {
      return items
          .where(
            (a) =>
                a.type == MemberActivityType.dealReceived ||
                a.metadata['member_role'] == 'receiver',
          )
          .toList();
    }
    if (type == MemberActivityType.referralGiven) {
      return items
          .where(
            (a) =>
                a.type == MemberActivityType.referralGiven ||
                a.metadata['member_role'] == 'giver',
          )
          .toList();
    }
    if (type == MemberActivityType.referralReceived) {
      return items
          .where(
            (a) =>
                a.type == MemberActivityType.referralReceived ||
                a.metadata['member_role'] == 'receiver',
          )
          .toList();
    }

    if (type == MemberActivityType.businessDeal) {
      return items
          .where(
            (a) =>
                a.type == MemberActivityType.businessDeal ||
                a.type == MemberActivityType.dealGiven ||
                a.type == MemberActivityType.dealReceived,
          )
          .toList();
    }
    if (type == MemberActivityType.businessReferral) {
      return items
          .where(
            (a) =>
                a.type == MemberActivityType.businessReferral ||
                a.type == MemberActivityType.referralGiven ||
                a.type == MemberActivityType.referralReceived,
          )
          .toList();
    }

    return items.where((a) {
      if (a.type == type) return true;
      if (type.endpointPath == a.type.endpointPath) return true;
      return false;
    }).toList();
  }

  bool _hasMore(ApiResponse<List<MemberActivityModel>> response) {
    final meta = response.meta;
    if (meta != null) return meta.currentPage < meta.lastPage;
    return (response.data?.length ?? 0) >= _pageSize;
  }
}
