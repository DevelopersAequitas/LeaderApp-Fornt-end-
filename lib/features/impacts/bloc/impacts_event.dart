abstract class ImpactsEvent {
  const ImpactsEvent();
}

class LoadImpacts extends ImpactsEvent {
  final String? circleId;
  const LoadImpacts({this.circleId});
}

class CreateImpactEvent extends ImpactsEvent {
  final String beneficiaryUserId;
  final String impactType;
  final String title;
  final String description;

  const CreateImpactEvent({
    required this.beneficiaryUserId,
    required this.impactType,
    required this.title,
    required this.description,
  });
}
