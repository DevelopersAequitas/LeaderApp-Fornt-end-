import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/error_formatter.dart';
import '../../../data/repositories/activities_repository.dart';
import 'business_deals_event.dart';
import 'business_deals_state.dart';

class BusinessDealsBloc extends Bloc<BusinessDealsEvent, BusinessDealsState> {
  final ActivitiesRepository _repository;

  BusinessDealsBloc({ActivitiesRepository? repository})
      : _repository = repository ?? ActivitiesRepositoryImpl(),
        super(const BusinessDealsState()) {
    on<LoadBusinessDeals>(_onLoadBusinessDeals);
    on<CreateBusinessDealEvent>(_onCreateBusinessDeal);
  }

  Future<void> _onLoadBusinessDeals(
    LoadBusinessDeals event,
    Emitter<BusinessDealsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: '', successMessage: ''));
    try {
      final response = await _repository.getBusinessDeals(circleId: event.circleId);
      if (response.success && response.data != null) {
        emit(state.copyWith(isLoading: false, deals: response.data!));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: response.message != null
              ? ErrorFormatter.format(response.message)
              : 'Unable to load business deals. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: ErrorFormatter.format(e)));
    }
  }

  Future<void> _onCreateBusinessDeal(
    CreateBusinessDealEvent event,
    Emitter<BusinessDealsState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: '', successMessage: ''));
    try {
      final response = await _repository.createBusinessDeal(
        withPeerId: event.withPeerId,
        amount: event.amount,
        currency: event.currency,
        dealType: event.dealType,
        notes: event.notes,
      );
      if (response.success && response.data != null) {
        final updatedList = [response.data!, ...state.deals];
        emit(state.copyWith(
          isSubmitting: false,
          deals: updatedList,
          successMessage: 'Business deal recorded successfully!',
        ));
      } else {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: response.message != null
              ? ErrorFormatter.format(response.message)
              : 'Unable to record business deal. Please check the details and try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: ErrorFormatter.format(e)));
    }
  }
}
