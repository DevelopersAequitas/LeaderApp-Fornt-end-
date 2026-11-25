import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/error_formatter.dart';
import '../../../data/repositories/activities_repository.dart';
import '../model/life_impact_detail_model.dart';
import 'life_impact_detail_event.dart';
import 'life_impact_detail_state.dart';

class LifeImpactDetailBloc
    extends Bloc<LifeImpactDetailEvent, LifeImpactDetailState> {
  final ActivitiesRepository _activitiesRepository;

  LifeImpactDetailBloc({ActivitiesRepository? activitiesRepository})
      : _activitiesRepository =
            activitiesRepository ?? ActivitiesRepositoryImpl(),
        super(const LifeImpactDetailState()) {
    on<LoadLifeImpactDetail>(_onLoadDetail);
    on<ApproveLifeImpact>(_onApprove);
    on<RejectLifeImpact>(_onReject);
  }

  Future<void> _onLoadDetail(
    LoadLifeImpactDetail event,
    Emitter<LifeImpactDetailState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      detail: event.initialData ?? state.detail,
      actionMessage: '',
      errorMessage: '',
    ));

    try {
      final res = await _activitiesRepository.getImpactDetail(event.impactId);
      if (res.success && res.data != null) {
        emit(state.copyWith(
          isLoading: false,
          detail: res.data,
          errorMessage: '',
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: (res.message ?? '').trim().isNotEmpty
              ? res.message!.trim()
              : 'Unable to load Life Impact details.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ErrorFormatter.format(e),
      ));
    }
  }

  Future<void> _onApprove(
    ApproveLifeImpact event,
    Emitter<LifeImpactDetailState> emit,
  ) async {
    final current = state.detail;
    if (current == null || current.id.trim().isEmpty || state.isSubmitting) {
      return;
    }

    emit(state.copyWith(
      isSubmitting: true,
      actionMessage: '',
      errorMessage: '',
    ));

    try {
      final res = await _activitiesRepository.approveImpact(
        id: current.id,
        remarks: event.remarks,
      );
      if (res.success) {
        // Reload authoritative server detail (reviewer, timestamps, verification history)
        final refreshed = await _activitiesRepository.getImpactDetail(current.id);
        final msg = (res.message ?? '').trim();
        emit(state.copyWith(
          isSubmitting: false,
          didMutate: true,
          detail: (refreshed.success && refreshed.data != null)
              ? refreshed.data
              : LifeImpactDetailModel(
                  id: current.id,
                  title: current.title,
                  impactCategory: current.impactCategory,
                  description: current.description,
                  storyToShare: current.storyToShare,
                  additionalRemarks: current.additionalRemarks,
                  livesImpacted: current.livesImpacted,
                  status: 'approved',
                  statusLabel: 'Approved',
                  impactDate: current.impactDate,
                  submittedAt: current.submittedAt,
                  location: current.location,
                  organizationName: current.organizationName,
                  circleId: current.circleId,
                  circleName: current.circleName,
                  districtId: current.districtId,
                  districtName: current.districtName,
                  peerCode: current.peerCode,
                  submittedBy: current.submittedBy,
                  beneficiary: current.beneficiary,
                  attachments: current.attachments,
                  reviewRemarks: event.remarks,
                  canApprove: false,
                  canReject: false,
                ),
          actionMessage: msg.isNotEmpty
              ? msg
              : 'Life Impact approved successfully.',
        ));
      } else {
        final msg = (res.message ?? '').trim();
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: msg.isNotEmpty
              ? msg
              : 'Unable to approve Life Impact submission.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: ErrorFormatter.format(e),
      ));
    }
  }

  Future<void> _onReject(
    RejectLifeImpact event,
    Emitter<LifeImpactDetailState> emit,
  ) async {
    final current = state.detail;
    final cleanReason = event.reason.trim();
    if (current == null || current.id.trim().isEmpty || state.isSubmitting) {
      return;
    }
    if (cleanReason.length < 3) {
      emit(state.copyWith(
        errorMessage: 'A rejection reason (at least 3 characters) is required.',
      ));
      return;
    }

    emit(state.copyWith(
      isSubmitting: true,
      actionMessage: '',
      errorMessage: '',
    ));

    try {
      final res = await _activitiesRepository.rejectImpact(
        id: current.id,
        reason: cleanReason,
      );
      if (res.success) {
        final refreshed = await _activitiesRepository.getImpactDetail(current.id);
        final msg = (res.message ?? '').trim();
        emit(state.copyWith(
          isSubmitting: false,
          didMutate: true,
          detail: (refreshed.success && refreshed.data != null)
              ? refreshed.data
              : LifeImpactDetailModel(
                  id: current.id,
                  title: current.title,
                  impactCategory: current.impactCategory,
                  description: current.description,
                  storyToShare: current.storyToShare,
                  additionalRemarks: current.additionalRemarks,
                  livesImpacted: current.livesImpacted,
                  status: 'rejected',
                  statusLabel: 'Rejected',
                  impactDate: current.impactDate,
                  submittedAt: current.submittedAt,
                  location: current.location,
                  organizationName: current.organizationName,
                  circleId: current.circleId,
                  circleName: current.circleName,
                  districtId: current.districtId,
                  districtName: current.districtName,
                  peerCode: current.peerCode,
                  submittedBy: current.submittedBy,
                  beneficiary: current.beneficiary,
                  attachments: current.attachments,
                  reviewRemarks: cleanReason,
                  canApprove: false,
                  canReject: false,
                ),
          actionMessage: msg.isNotEmpty
              ? msg
              : 'Life Impact rejected with reason recorded.',
        ));
      } else {
        final msg = (res.message ?? '').trim();
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: msg.isNotEmpty
              ? msg
              : 'Unable to reject Life Impact submission.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: ErrorFormatter.format(e),
      ));
    }
  }
}
