abstract class BusinessDealsEvent {
  const BusinessDealsEvent();
}

class LoadBusinessDeals extends BusinessDealsEvent {
  final String? circleId;
  const LoadBusinessDeals({this.circleId});
}

class CreateBusinessDealEvent extends BusinessDealsEvent {
  final String withPeerId;
  final dynamic amount;
  final String currency;
  final String dealType;
  final String? notes;

  const CreateBusinessDealEvent({
    required this.withPeerId,
    required this.amount,
    this.currency = 'INR',
    this.dealType = 'closed',
    this.notes,
  });
}
