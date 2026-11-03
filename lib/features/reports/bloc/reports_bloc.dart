import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../data/repositories/reports_repository.dart';
import '../../../data/repositories/teams_repository.dart';
import '../model/report_model.dart';
import 'reports_event.dart';
import 'reports_state.dart';

/// Business Logic Component for managing leadership report creations, history, analytics and PDF exports.
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository _reportsRepository;
  final TeamsRepository _teamsRepository;
  final Map<String, String> _circleNameToId = {};

  ReportsBloc({
    ReportsRepository? reportsRepository,
    TeamsRepository? teamsRepository,
  })  : _reportsRepository = reportsRepository ?? ReportsRepositoryImpl(),
        _teamsRepository = teamsRepository ?? TeamsRepositoryImpl(),
        super(const ReportsState()) {
    on<LoadReports>(_onLoadReports);
    on<FilterReportsByType>(_onFilterReportsByType);
    on<FilterReportsByStatus>(_onFilterReportsByStatus);
    on<ToggleReportSubTab>(_onToggleReportSubTab);
    on<ChangeReportType>(_onChangeReportType);
    on<ChangeSelectedCircle>(_onChangeSelectedCircle);
    on<ReportPeriodChanged>(_onReportPeriodChanged);
    on<ReportContentChanged>(_onReportContentChanged);
    on<ReportHighlightsChanged>(_onReportHighlightsChanged);
    on<ReportChallengesChanged>(_onReportChallengesChanged);
    on<ReportActionItemsChanged>(_onReportActionItemsChanged);
    on<ReportAttendanceChanged>(_onReportAttendanceChanged);
    on<ReportDealsValueChanged>(_onReportDealsValueChanged);
    on<ReportRevenueChanged>(_onReportRevenueChanged);
    on<TogglePeersScopeMode>(_onTogglePeersScopeMode);
    on<ToggleSelectAllPeers>(_onToggleSelectAllPeers);
    on<ToggleSelectPeer>(_onToggleSelectPeer);
    on<ToggleActivitiesScopeMode>(_onToggleActivitiesScopeMode);
    on<ToggleSelectAllActivities>(_onToggleSelectAllActivities);
    on<ToggleSelectActivity>(_onToggleSelectActivity);
    on<ToggleIncludePeerWithActivities>(_onToggleIncludePeerWithActivities);
    on<LoadCirclePeersForReport>(_onLoadCirclePeersForReport);
    on<SubmitReportForm>(_onSubmitReportForm);
    on<FetchReportDetails>(_onFetchReportDetails);
    on<DownloadReportPdf>(_onDownloadReportPdf);
  }

  static bool _isValidUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(str.trim());
  }

  String _resolveCircleId(String? circleNameOrId) {
    if (circleNameOrId == null || circleNameOrId.isEmpty) return '';
    if (_isValidUuid(circleNameOrId)) return circleNameOrId.trim();
    return _circleNameToId[circleNameOrId] ?? '';
  }

  static String _defaultPeriod() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.year}';
  }

  Future<void> _onLoadReports(
    LoadReports event,
    Emitter<ReportsState> emit,
  ) async {
    if (state.submittedReports.isEmpty) {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
    }

    final isSuperAdmin = SessionManager().isSuperAdmin;
    final activeCircle = event.selectedCircle ?? state.selectedCircle ?? '';

    // Retrieve available circles for this user's scope
    List<String> circlesList = List<String>.from(state.availableCircles);
    try {
      final circlesRes = await _teamsRepository.getCircles();
      if (circlesRes.success && circlesRes.data != null && circlesRes.data!.isNotEmpty) {
        for (final c in circlesRes.data!) {
          if (c.name.isNotEmpty) {
            _circleNameToId[c.name] = c.id;
          }
        }
        circlesList = circlesRes.data!.map((c) => c.name).where((n) => n.isNotEmpty).toList();
      }
    } catch (_) {
      // Fallback to session circles if remote fetch fails
    }

    if (circlesList.isEmpty) {
      final sessionCircles = SessionManager().currentSession.managedCircles;
      if (sessionCircles.isNotEmpty) {
        circlesList = List<String>.from(sessionCircles);
      }
    }

    if (isSuperAdmin && !circlesList.contains('All Circles')) {
      circlesList.insert(0, 'All Circles');
    }

    final String resolvedCircleName;
    if (isSuperAdmin && (activeCircle.isEmpty || activeCircle == 'All Circles')) {
      resolvedCircleName = 'All Circles';
    } else {
      resolvedCircleName = state.circleName.isNotEmpty
          ? state.circleName
          : (activeCircle.isNotEmpty
              ? activeCircle
              : (circlesList.isNotEmpty ? circlesList.first : ''));
    }

    final resolvedCircleId = (resolvedCircleName == 'All Circles' || resolvedCircleName.isEmpty)
        ? ''
        : _resolveCircleId(resolvedCircleName.isNotEmpty ? resolvedCircleName : activeCircle);

    final currentPeriod = state.period.isNotEmpty ? state.period : _defaultPeriod();

    try {
      final reportsResponse = await _reportsRepository.getReports(
        circleId: resolvedCircleId.isNotEmpty ? resolvedCircleId : null,
        reportType: event.reportType ?? state.filterType,
        status: event.status ?? state.filterStatus,
        districtId: event.districtId,
      );
      final trendResponse = await _reportsRepository.getAttendanceTrend(
        circleId: resolvedCircleId.isNotEmpty ? resolvedCircleId : null,
      );

      final reportsList = (reportsResponse.data ?? const <ReportModel>[])
          .where((r) => !ReportModel.isDummyReport(r))
          .toList();
      List<ReportsChartPoint> trendList = trendResponse.data ?? const <ReportsChartPoint>[];

      // If remote attendance trend is empty, derive live points from submitted reports
      if (trendList.isEmpty && reportsList.isNotEmpty) {
        final Map<String, List<double>> monthToAtt = {};
        for (final r in reportsList) {
          if (r.attendancePercentage != null && r.attendancePercentage! > 0) {
            final m = (r.period?.isNotEmpty == true ? r.period! : r.date).trim();
            final shortM = m.length > 3 ? m.substring(0, 3) : m;
            monthToAtt.putIfAbsent(shortM, () => []).add(r.attendancePercentage!);
          }
        }
        if (monthToAtt.isNotEmpty) {
          trendList = monthToAtt.entries.map((e) {
            final avg = e.value.reduce((a, b) => a + b) / e.value.length;
            return ReportsChartPoint(month: e.key, value: avg);
          }).toList();
        }
      }

      emit(
        state.copyWith(
          isLoading: false,
          submittedReports: reportsList,
          attendanceTrend: trendList,
          selectedCircle: activeCircle,
          availableCircles: circlesList,
          circleName: resolvedCircleName,
          selectedCircleId: resolvedCircleId,
          period: currentPeriod,
        ),
      );

      // Automatically fetch circle peers for report roster
      if (resolvedCircleId.isNotEmpty) {
        add(LoadCirclePeersForReport(resolvedCircleId));
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
          availableCircles: circlesList,
          circleName: resolvedCircleName,
          selectedCircleId: resolvedCircleId,
          period: currentPeriod,
        ),
      );
    }
  }

  Future<void> _onFilterReportsByType(
    FilterReportsByType event,
    Emitter<ReportsState> emit,
  ) async {
    emit(state.copyWith(filterType: event.reportType, isLoading: true));
    try {
      final res = await _reportsRepository.getReports(
        circleId: state.selectedCircleId,
        reportType: event.reportType,
        status: state.filterStatus,
      );
      final list = (res.data ?? const <ReportModel>[])
          .where((r) => !ReportModel.isDummyReport(r))
          .toList();
      emit(state.copyWith(
        isLoading: false,
        submittedReports: list,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onFilterReportsByStatus(
    FilterReportsByStatus event,
    Emitter<ReportsState> emit,
  ) async {
    emit(state.copyWith(filterStatus: event.status, isLoading: true));
    try {
      final res = await _reportsRepository.getReports(
        circleId: state.selectedCircleId,
        reportType: state.filterType,
        status: event.status,
      );
      final list = (res.data ?? const <ReportModel>[])
          .where((r) => !ReportModel.isDummyReport(r))
          .toList();
      emit(state.copyWith(
        isLoading: false,
        submittedReports: list,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onToggleReportSubTab(
    ToggleReportSubTab event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(activeSubTab: event.index, isSuccess: false));
  }

  void _onChangeReportType(ChangeReportType event, Emitter<ReportsState> emit) {
    emit(state.copyWith(selectedType: event.type));
  }

  void _onChangeSelectedCircle(
    ChangeSelectedCircle event,
    Emitter<ReportsState> emit,
  ) {
    final circleId = event.circleName == 'All Circles'
        ? ''
        : (event.circleId ?? _resolveCircleId(event.circleName));
    emit(state.copyWith(circleName: event.circleName, selectedCircleId: circleId));
    add(LoadReports(selectedCircle: event.circleName));
    if (circleId.isNotEmpty) {
      add(LoadCirclePeersForReport(circleId));
    }
  }

  void _onReportPeriodChanged(ReportPeriodChanged event, Emitter<ReportsState> emit) {
    emit(state.copyWith(period: event.period));
  }

  void _onReportContentChanged(
    ReportContentChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(reportContent: event.content, errorMessage: ''));
  }

  void _onReportHighlightsChanged(
    ReportHighlightsChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(highlights: event.highlights));
  }

  void _onReportChallengesChanged(
    ReportChallengesChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(challengesFaced: event.challenges));
  }

  void _onReportActionItemsChanged(
    ReportActionItemsChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(actionItems: event.actionItems));
  }

  void _onReportAttendanceChanged(
    ReportAttendanceChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(attendancePercentage: event.attendance));
  }

  void _onReportDealsValueChanged(
    ReportDealsValueChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(dealsClosedValue: event.dealsValue));
  }

  void _onReportRevenueChanged(
    ReportRevenueChanged event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(totalRevenue: event.revenue));
  }

  void _onTogglePeersScopeMode(
    TogglePeersScopeMode event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(peersScopeMode: event.mode));
  }

  void _onToggleSelectAllPeers(
    ToggleSelectAllPeers event,
    Emitter<ReportsState> emit,
  ) {
    if (event.selectAll) {
      final allIds = state.availableCirclePeers
          .map((p) => p.peerId)
          .where((id) => id.isNotEmpty)
          .toSet();
      emit(state.copyWith(selectedPeerIds: allIds));
    } else {
      emit(state.copyWith(selectedPeerIds: const <String>{}));
    }
  }

  void _onToggleSelectPeer(
    ToggleSelectPeer event,
    Emitter<ReportsState> emit,
  ) {
    final nextIds = Set<String>.from(state.selectedPeerIds);
    if (nextIds.contains(event.peerId)) {
      nextIds.remove(event.peerId);
    } else {
      nextIds.add(event.peerId);
    }
    emit(state.copyWith(selectedPeerIds: nextIds));
  }

  void _onToggleActivitiesScopeMode(
    ToggleActivitiesScopeMode event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(activitiesScopeMode: event.mode));
  }

  void _onToggleSelectAllActivities(
    ToggleSelectAllActivities event,
    Emitter<ReportsState> emit,
  ) {
    const allKeys = {
      'p2p_meetings',
      'referrals',
      'deals_closed',
      'testimonials',
      'visitor_registrations',
      'attendance',
    };
    if (event.selectAll) {
      emit(state.copyWith(selectedActivityKeys: allKeys));
    } else {
      emit(state.copyWith(selectedActivityKeys: const <String>{}));
    }
  }

  void _onToggleSelectActivity(
    ToggleSelectActivity event,
    Emitter<ReportsState> emit,
  ) {
    final nextKeys = Set<String>.from(state.selectedActivityKeys);
    if (nextKeys.contains(event.activityKey)) {
      nextKeys.remove(event.activityKey);
    } else {
      nextKeys.add(event.activityKey);
    }
    emit(state.copyWith(selectedActivityKeys: nextKeys));
  }

  void _onToggleIncludePeerWithActivities(
    ToggleIncludePeerWithActivities event,
    Emitter<ReportsState> emit,
  ) {
    emit(state.copyWith(includePeerWithActivities: event.include));
  }

  Future<void> _onLoadCirclePeersForReport(
    LoadCirclePeersForReport event,
    Emitter<ReportsState> emit,
  ) async {
    if (event.circleId.isEmpty) return;
    emit(state.copyWith(isLoadingPeers: true));
    try {
      final res = await _teamsRepository.getCirclePeers(event.circleId);
      if (res.success && res.data != null && res.data!.isNotEmpty) {
        final peers = res.data!
            .where((p) => !ReportModel.isDummyPeer(p.name, p.id))
            .map((p) => ReportPeerRosterItem(
                  peerId: p.id,
                  name: p.name,
                  avatarUrl: p.avatarUrl,
                  company: p.company,
                  designation: p.designation ?? '',
                  status: p.status,
                  platformMembershipStart: p.joinedDate ?? '',
                  platformMembershipEnd: '',
                  circleJoiningDate: p.joinedDate ?? '',
                  circleRenewalDate: '',
                  attendance: p.attendance,
                  dealsClosed: p.dealsFormatted,
                  p2pCount: p.p2pMeetings ?? 0,
                  referralsCount: p.referralsGiven ?? 0,
                ))
            .toList();

        final allIds = peers.map((p) => p.peerId).where((id) => id.isNotEmpty).toSet();
        emit(
          state.copyWith(
            isLoadingPeers: false,
            availableCirclePeers: peers,
            selectedPeerIds: allIds,
          ),
        );
      } else {
        emit(state.copyWith(isLoadingPeers: false));
      }
    } catch (_) {
      emit(state.copyWith(isLoadingPeers: false));
    }
  }

  Future<void> _onSubmitReportForm(
    SubmitReportForm event,
    Emitter<ReportsState> emit,
  ) async {
    if (state.reportContent.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Report executive summary cannot be empty.'));
      return;
    }

    final targetCircleId = _resolveCircleId(
      state.selectedCircleId?.isNotEmpty == true
          ? state.selectedCircleId
          : state.circleName,
    );

    if (targetCircleId.isEmpty && state.circleName.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please select a valid circle for this report.'));
      return;
    }

    emit(
      state.copyWith(isSubmitting: true, errorMessage: '', isSuccess: false),
    );

    try {
      final session = SessionManager().currentSession;
      final periodToSubmit = state.period.isNotEmpty ? state.period : _defaultPeriod();

      // Filter peers roster based on scope mode & manual selection
      final List<ReportPeerRosterItem> effectivePeers = state.peersScopeMode == 'specific'
          ? state.availableCirclePeers
              .where((p) => state.selectedPeerIds.contains(p.peerId))
              .toList()
          : state.availableCirclePeers;

      // Filter activities based on scope mode & manual selection
      final List<String> effectiveActivities = state.activitiesScopeMode == 'specific'
          ? state.selectedActivityKeys.toList()
          : const [
              'p2p_meetings',
              'referrals',
              'deals_closed',
              'testimonials',
              'visitor_registrations',
              'attendance',
            ];

      // Build JSON roster if peer with activities breakdown is enabled
      final peersRosterJson = state.includePeerWithActivities
          ? effectivePeers.map((p) => p.toJson()).toList()
          : <Map<String, dynamic>>[];

      final response = await _reportsRepository.submitReport(
        circleId: targetCircleId.isNotEmpty ? targetCircleId : state.circleName,
        reportType: state.selectedType,
        period: periodToSubmit,
        summaryText: state.reportContent.trim(),
        attendancePercentage: state.attendancePercentage,
        dealsClosedValue: state.dealsClosedValue.isNotEmpty ? state.dealsClosedValue : null,
        totalRevenue: state.totalRevenue.isNotEmpty ? state.totalRevenue : null,
        highlights: state.highlights.isNotEmpty ? state.highlights : null,
        challengesFaced: state.challengesFaced.isNotEmpty ? state.challengesFaced : null,
        actionItems: state.actionItems.isNotEmpty ? state.actionItems : null,
        includedSections: effectiveActivities,
        peersRoster: peersRosterJson,
      );

      if (response.success && response.data != null) {
        final submitData = response.data!;
        final newReport = ReportModel(
          id: submitData.reportId,
          type: state.selectedType,
          status: submitData.status,
          date: periodToSubmit,
          period: periodToSubmit,
          circleName: state.circleName,
          circleId: targetCircleId,
          content: state.reportContent,
          author: '${session.name} · ${state.circleName}',
          authorRole: session.role.label,
          authorAvatarUrl: session.avatarUrl ?? session.profilePhotoUrl,
          attendancePercentage: state.attendancePercentage,
          dealsClosedValue: state.dealsClosedValue.isNotEmpty ? state.dealsClosedValue : null,
          totalRevenue: state.totalRevenue.isNotEmpty ? state.totalRevenue : null,
          highlights: state.highlights.isNotEmpty ? state.highlights : null,
          challengesFaced: state.challengesFaced.isNotEmpty ? state.challengesFaced : null,
          actionItems: state.actionItems.isNotEmpty ? state.actionItems : null,
          includedSections: effectiveActivities,
          peersRoster: effectivePeers,
        );

        final updatedList = [newReport, ...state.submittedReports];

        emit(
          state.copyWith(
            isSubmitting: false,
            isSuccess: true,
            successMessage: response.message ?? 'Report submitted successfully and routed to higher leadership.',
            submittedReports: updatedList,
            reportContent: '',
            highlights: '',
            challengesFaced: '',
            actionItems: '',
            activeSubTab: 1, // Automatically switch to History tab so user sees new report
          ),
        );
      } else {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: response.message ?? 'Report submission failed. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onFetchReportDetails(
    FetchReportDetails event,
    Emitter<ReportsState> emit,
  ) async {
    emit(state.copyWith(isLoadingDetail: true));
    try {
      final res = await _reportsRepository.getReportDetails(event.reportId);
      if (res.success && res.data != null) {
        final detailed = res.data!;
        final updatedList = state.submittedReports.map((r) {
          return r.id == detailed.id ? detailed : r;
        }).toList();

        emit(state.copyWith(
          isLoadingDetail: false,
          selectedReportDetail: detailed,
          submittedReports: updatedList,
        ));
      } else {
        emit(state.copyWith(isLoadingDetail: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoadingDetail: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDownloadReportPdf(
    DownloadReportPdf event,
    Emitter<ReportsState> emit,
  ) async {
    emit(state.copyWith(isDownloading: true));
    try {
      final res = await _reportsRepository.getReportDownloadUrl(event.reportId);
      if (res.success && res.data != null) {
        emit(state.copyWith(
          isDownloading: false,
          activeDownload: res.data,
        ));
      } else {
        emit(state.copyWith(
          isDownloading: false,
          errorMessage: res.message ?? 'Unable to retrieve PDF download link.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(isDownloading: false, errorMessage: e.toString()));
    }
  }
}
