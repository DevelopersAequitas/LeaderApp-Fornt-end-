import '../../../core/helpers/session_manager.dart';
import '../model/life_impact_detail_model.dart';

/// Pure presentation logic for [LifeImpactDetailView].
class LifeImpactDetailPresenter {
  const LifeImpactDetailPresenter();

  /// Review actions (Accept / Reject) are shown ONLY when:
  /// 1. Authenticated user is Super Admin or District Executive Director (DED)
  /// 2. Submission is currently in `pending` status
  /// 3. User is not reviewing their own submission
  /// 4. Backend did not explicitly deny review permission (`canApprove != false`)
  bool canShowReviewActions(
    LifeImpactDetailModel detail,
    UserSession session,
  ) {
    if (!session.role.canReviewLifeImpacts) return false;
    if (!detail.isPending) return false;
    if (session.id.trim().isNotEmpty &&
        detail.submittedBy.id.trim() == session.id.trim()) {
      return false;
    }
    if (detail.canApprove == false && detail.canReject == false) {
      return false;
    }
    return true;
  }
}
