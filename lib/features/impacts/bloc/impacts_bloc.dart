import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/error_formatter.dart';
import '../../../data/repositories/activities_repository.dart';
import 'impacts_event.dart';
import 'impacts_state.dart';

class ImpactsBloc extends Bloc<ImpactsEvent, ImpactsState> {
  final ActivitiesRepository _repository;

  ImpactsBloc({ActivitiesRepository? repository})
      : _repository = repository ?? ActivitiesRepositoryImpl(),
        super(const ImpactsState()) {
    on<LoadImpacts>(_onLoadImpacts);
    on<CreateImpactEvent>(_onCreateImpact);
  }

  Future<void> _onLoadImpacts(
    LoadImpacts event,
    Emitter<ImpactsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: '', successMessage: ''));
    try {
      final response = await _repository.getImpacts(circleId: event.circleId);
      if (response.success && response.data != null) {
        emit(state.copyWith(isLoading: false, impacts: response.data!));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: response.message != null
              ? ErrorFormatter.format(response.message)
              : 'Unable to load life impacts. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: ErrorFormatter.format(e)));
    }
  }

  Future<void> _onCreateImpact(
    CreateImpactEvent event,
    Emitter<ImpactsState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: '', successMessage: ''));
    try {
      final response = await _repository.createImpact(
        beneficiaryUserId: event.beneficiaryUserId,
        impactType: event.impactType,
        title: event.title,
        description: event.description,
      );
      if (response.success && response.data != null) {
        final updatedList = [response.data!, ...state.impacts];
        emit(state.copyWith(
          isSubmitting: false,
          impacts: updatedList,
          successMessage: 'Life Impact recorded successfully!',
        ));
      } else {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: response.message != null
              ? ErrorFormatter.format(response.message)
              : 'Unable to record life impact. Please check the details and try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: ErrorFormatter.format(e)));
    }
  }
}
