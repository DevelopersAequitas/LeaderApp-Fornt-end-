abstract class RequirementsEvent {
  const RequirementsEvent();
}

class LoadRequirements extends RequirementsEvent {
  final String? circleId;
  const LoadRequirements({this.circleId});
}
