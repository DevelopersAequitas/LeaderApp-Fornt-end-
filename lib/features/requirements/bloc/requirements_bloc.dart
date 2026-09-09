import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/error_formatter.dart';
import '../../../data/repositories/activities_repository.dart';
import 'requirements_event.dart';
import 'requirements_state.dart';

class RequirementsBloc extends Bloc<RequirementsEvent, RequirementsState> {
  final ActivitiesRepository _repository;

  RequirementsBloc({ActivitiesRepository? repository})
      : _repository = repository ?? ActivitiesRepositoryImpl(),
        super(const RequirementsState()) {
    on<LoadRequirements>(_onLoadRequirements);
  }

  Future<void> _onLoadRequirements(
    LoadRequirements event,
    Emitter<RequirementsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    try {
      final response = await _repository.getRequirements(circleId: event.circleId);
      if (response.success && response.data != null) {
        emit(state.copyWith(isLoading: false, requirements: response.data!));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: response.message != null
              ? ErrorFormatter.format(response.message)
              : 'Unable to load peer requirements. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: ErrorFormatter.format(e)));
    }
  }
}
