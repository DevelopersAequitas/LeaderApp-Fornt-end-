import '../bloc/business_deals_bloc.dart';
import '../bloc/business_deals_event.dart';
import '../bloc/business_deals_state.dart';

abstract class BusinessDealsViewContract {
  void onDealsLoading();
  void onDealsLoaded();
  void onDealsError(String message);
  void onDealCreatedSuccess(String message);
}

class BusinessDealsPresenter {
  final BusinessDealsViewContract view;
  final BusinessDealsBloc bloc;

  BusinessDealsPresenter({required this.view, required this.bloc});

  void loadDeals({String? circleId}) {
    bloc.add(LoadBusinessDeals(circleId: circleId));
  }

  void createDeal({
    required String withPeerId,
    required dynamic amount,
    String currency = 'INR',
    String dealType = 'closed',
    String? notes,
  }) {
    bloc.add(CreateBusinessDealEvent(
      withPeerId: withPeerId,
      amount: amount,
      currency: currency,
      dealType: dealType,
      notes: notes,
    ));
  }

  void handleStateChange(BusinessDealsState state) {
    if (state.isLoading) {
      view.onDealsLoading();
    } else if (state.errorMessage.isNotEmpty) {
      view.onDealsError(state.errorMessage);
    } else {
      view.onDealsLoaded();
    }
    if (state.successMessage.isNotEmpty) {
      view.onDealCreatedSuccess(state.successMessage);
    }
  }
}
