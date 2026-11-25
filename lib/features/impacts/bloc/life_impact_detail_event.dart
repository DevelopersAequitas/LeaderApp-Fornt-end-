import '../model/life_impact_detail_model.dart';

abstract class LifeImpactDetailEvent {
  const LifeImpactDetailEvent();
}

class LoadLifeImpactDetail extends LifeImpactDetailEvent {
  final String impactId;
  final LifeImpactDetailModel? initialData;

  const LoadLifeImpactDetail({
    required this.impactId,
    this.initialData,
  });
}

class ApproveLifeImpact extends LifeImpactDetailEvent {
  final String? remarks;

  const ApproveLifeImpact({this.remarks});
}

class RejectLifeImpact extends LifeImpactDetailEvent {
  final String reason;

  const RejectLifeImpact({required this.reason});
}
