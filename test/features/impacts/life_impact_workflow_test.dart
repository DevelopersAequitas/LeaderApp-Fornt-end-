import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/enums/user_role.dart';
import 'package:leaderapp/core/helpers/session_manager.dart';
import 'package:leaderapp/core/models/leader_permissions.dart';
import 'package:leaderapp/core/network/api_response.dart';
import 'package:leaderapp/core/theme/app_theme.dart';
import 'package:leaderapp/data/repositories/activities_repository.dart';
import 'package:leaderapp/features/impacts/bloc/life_impact_detail_bloc.dart';
import 'package:leaderapp/features/impacts/bloc/life_impact_detail_event.dart';
import 'package:leaderapp/features/impacts/model/life_impact_detail_model.dart';
import 'package:leaderapp/features/impacts/presenter/life_impact_detail_presenter.dart';
import 'package:leaderapp/features/impacts/view/life_impact_detail_view.dart';
import 'package:leaderapp/features/leader_activities/model/leader_activity_item_model.dart';

class _FakeLifeImpactRepository implements ActivitiesRepository {
  LifeImpactDetailModel currentDetail;
  int approveCalls = 0;
  int rejectCalls = 0;
  String? lastApproveRemarks;
  String? lastRejectReason;
  bool shouldFailNextAction = false;
  String failMessage = 'Conflict error';

  _FakeLifeImpactRepository({required this.currentDetail});

  @override
  Future<ApiResponse<LifeImpactDetailModel>> getImpactDetail(String id) async {
    return ApiResponse<LifeImpactDetailModel>(
      success: true,
      data: currentDetail,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> approveImpact({
    required String id,
    String? remarks,
  }) async {
    approveCalls++;
    lastApproveRemarks = remarks;
    if (shouldFailNextAction) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: failMessage,
      );
    }
    currentDetail = LifeImpactDetailModel(
      id: currentDetail.id,
      title: currentDetail.title,
      impactCategory: currentDetail.impactCategory,
      description: currentDetail.description,
      storyToShare: currentDetail.storyToShare,
      livesImpacted: currentDetail.livesImpacted,
      status: 'approved',
      statusLabel: 'Approved',
      impactDate: currentDetail.impactDate,
      submittedAt: currentDetail.submittedAt,
      location: currentDetail.location,
      circleName: currentDetail.circleName,
      districtName: currentDetail.districtName,
      peerCode: currentDetail.peerCode,
      submittedBy: currentDetail.submittedBy,
      beneficiary: currentDetail.beneficiary,
      attachments: currentDetail.attachments,
      approvedByName: 'Reviewer',
      approvedAt: '2026-11-25T12:00:00Z',
      reviewRemarks: remarks,
      verificationHistory: [
        ...currentDetail.verificationHistory,
        ImpactVerificationEventModel(
          event: 'approved',
          label: 'Impact Approved',
          status: 'approved',
          actorName: 'Reviewer',
          actorRole: 'District Executive Director',
          timestamp: '2026-11-25T12:00:00Z',
          remarks: remarks,
        ),
      ],
      canApprove: false,
      canReject: false,
    );
    return const ApiResponse<Map<String, dynamic>>(
      success: true,
      message: 'Life impact approved successfully.',
      data: {'status': 'approved'},
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> rejectImpact({
    required String id,
    required String reason,
  }) async {
    rejectCalls++;
    lastRejectReason = reason;
    if (shouldFailNextAction) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: failMessage,
      );
    }
    currentDetail = LifeImpactDetailModel(
      id: currentDetail.id,
      title: currentDetail.title,
      impactCategory: currentDetail.impactCategory,
      description: currentDetail.description,
      storyToShare: currentDetail.storyToShare,
      livesImpacted: currentDetail.livesImpacted,
      status: 'rejected',
      statusLabel: 'Rejected',
      impactDate: currentDetail.impactDate,
      submittedAt: currentDetail.submittedAt,
      location: currentDetail.location,
      circleName: currentDetail.circleName,
      districtName: currentDetail.districtName,
      peerCode: currentDetail.peerCode,
      submittedBy: currentDetail.submittedBy,
      beneficiary: currentDetail.beneficiary,
      attachments: currentDetail.attachments,
      rejectedByName: 'Reviewer',
      rejectedAt: '2026-11-25T12:00:00Z',
      reviewRemarks: reason,
      verificationHistory: [
        ...currentDetail.verificationHistory,
        ImpactVerificationEventModel(
          event: 'rejected',
          label: 'Impact Rejected',
          status: 'rejected',
          actorName: 'Reviewer',
          actorRole: 'Super Admin',
          timestamp: '2026-11-25T12:00:00Z',
          remarks: reason,
        ),
      ],
      canApprove: false,
      canReject: false,
    );
    return const ApiResponse<Map<String, dynamic>>(
      success: true,
      message: 'Life impact rejected successfully.',
      data: {'status': 'rejected'},
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      Future<dynamic>.value(null);
}

void main() {
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => null,
    );
  });

  LifeImpactDetailModel buildPendingDetail({
    String submitterId = 'peer-user-1',
    bool canApprove = true,
    String status = 'pending',
  }) {
    return LifeImpactDetailModel(
      id: 'imp-100',
      title: 'Mentored Rural Tech Entrepreneurs',
      impactCategory: 'Business Mentorship',
      description: 'Conducted 6 mentoring sessions guiding 3 founders on GTM.',
      storyToShare: 'Two startups closed seed customers within 60 days.',
      livesImpacted: 3,
      status: status,
      statusLabel: status == 'pending'
          ? 'Pending'
          : (status == 'approved' ? 'Approved' : 'Rejected'),
      impactDate: '2026-11-20',
      submittedAt: '2026-11-21T08:00:00Z',
      location: 'Ahmedabad, Gujarat',
      organizationName: 'TechScale India',
      circleId: 'circle-1',
      circleName: 'Ahmedabad Titans',
      districtId: 'dist-1',
      districtName: 'Ahmedabad District',
      peerCode: 'PG-042',
      submittedBy: ImpactPeerSummaryModel(
        id: submitterId,
        peerCode: 'PG-042',
        name: 'Aarav Patel',
        designation: 'Founder',
        companyName: 'TechScale India',
        city: 'Ahmedabad',
        circleName: 'Ahmedabad Titans',
        districtName: 'Ahmedabad District',
      ),
      beneficiary: const ImpactPeerSummaryModel(
        id: 'peer-user-2',
        peerCode: 'PG-088',
        name: 'Neha Shah',
        companyName: 'CraftNext',
      ),
      attachments: const [
        ImpactAttachmentModel(
          id: 'att-1',
          url: 'https://example.com/proof.pdf',
          title: 'Session Certificate',
          mimeType: 'application/pdf',
          isImage: false,
        ),
      ],
      verificationHistory: const [
        ImpactVerificationEventModel(
          event: 'submitted',
          label: 'Impact Submitted',
          status: 'pending',
          actorName: 'Aarav Patel',
          actorRole: 'Peer',
          timestamp: '2026-11-21T08:00:00Z',
        ),
      ],
      canApprove: canApprove,
      canReject: canApprove,
    );
  }

  Future<void> setRole(UserRole role, {String id = 'leader-1'}) async {
    await SessionManager().setAuthSession(
      token: 'leader-token',
      session: UserSession(
        id: id,
        name: 'Leader Reviewer',
        email: 'leader@peersglobal.com',
        phone: '+919999999999',
        role: role,
        regionalScope: 'Ahmedabad',
        managedCircles: const ['Ahmedabad Titans'],
        memberSince: 'Jan 2025',
        capabilitiesCount: 21,
      ),
      permissions: LeaderPermissions.allGranted,
    );
  }

  group('LifeImpactDetailPresenter role & guard rules', () {
    const presenter = LifeImpactDetailPresenter();

    test('allows Super Admin and DED on non-self pending submissions', () async {
      await setRole(UserRole.superAdmin);
      expect(
        presenter.canShowReviewActions(
          buildPendingDetail(),
          SessionManager().currentSession,
        ),
        isTrue,
      );

      await setRole(UserRole.districtExecDirector);
      expect(
        presenter.canShowReviewActions(
          buildPendingDetail(),
          SessionManager().currentSession,
        ),
        isTrue,
      );
    });

    test('denies Circle Chair, Circle Founder, self-review, and already decided',
        () async {
      await setRole(UserRole.circleChair);
      expect(
        presenter.canShowReviewActions(
          buildPendingDetail(),
          SessionManager().currentSession,
        ),
        isFalse,
      );

      await setRole(UserRole.circleFounder);
      expect(
        presenter.canShowReviewActions(
          buildPendingDetail(),
          SessionManager().currentSession,
        ),
        isFalse,
      );

      await setRole(UserRole.superAdmin, id: 'peer-user-1');
      expect(
        presenter.canShowReviewActions(
          buildPendingDetail(submitterId: 'peer-user-1'),
          SessionManager().currentSession,
        ),
        isFalse,
      );

      await setRole(UserRole.superAdmin);
      expect(
        presenter.canShowReviewActions(
          buildPendingDetail(status: 'approved'),
          SessionManager().currentSession,
        ),
        isFalse,
      );
      expect(
        presenter.canShowReviewActions(
          buildPendingDetail(canApprove: false),
          SessionManager().currentSession,
        ),
        isFalse,
      );
    });
  });

  group('LifeImpactDetailView & BLoC workflow', () {
    testWidgets(
        'DED views full detail, verification history & approves via confirmation dialog',
        (tester) async {
      await setRole(UserRole.districtExecDirector);
      final repo = _FakeLifeImpactRepository(
        currentDetail: buildPendingDetail(),
      );
      final bloc = LifeImpactDetailBloc(activitiesRepository: repo)
        ..add(const LoadLifeImpactDetail(impactId: 'imp-100'));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LifeImpactDetailView(impactId: 'imp-100', bloc: bloc),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mentored Rural Tech Entrepreneurs'), findsOneWidget);
      expect(find.text('Aarav Patel'), findsAtLeastNWidgets(1));
      expect(
        find.textContaining('Neha Shah', findRichText: true),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('Impact Submitted'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Session Certificate'), findsOneWidget);
      expect(find.text('Impact Submitted'), findsOneWidget);

      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      expect(find.text('Approve Life Impact'), findsOneWidget);
      await tester.tap(find.text('Confirm Approval'));
      await tester.pumpAndSettle();

      expect(repo.approveCalls, 1);
      expect(bloc.state.didMutate, isTrue);
      expect(find.text('Impact Approved'), findsOneWidget);
      // Sticky bar disappears after approval
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Reject'), findsNothing);
    });

    testWidgets(
        'Rejection requires >= 3 char reason and two-step confirmation dialog',
        (tester) async {
      await setRole(UserRole.superAdmin);
      final repo = _FakeLifeImpactRepository(
        currentDetail: buildPendingDetail(),
      );
      final bloc = LifeImpactDetailBloc(activitiesRepository: repo)
        ..add(const LoadLifeImpactDetail(impactId: 'imp-100'));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LifeImpactDetailView(impactId: 'imp-100', bloc: bloc),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      expect(find.text('Reject Life Impact'), findsOneWidget);

      // Too short reason blocked inline
      await tester.enterText(find.byType(TextField), 'no');
      await tester.tap(find.text('Review & Reject'));
      await tester.pumpAndSettle();
      expect(
        find.text('Please enter a rejection reason (at least 3 characters).'),
        findsOneWidget,
      );
      expect(repo.rejectCalls, 0);

      // Valid reason -> moves to confirmation summary step
      await tester.enterText(
        find.byType(TextField),
        'Missing beneficiary verification evidence',
      );
      await tester.tap(find.text('Review & Reject'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Rejection'), findsAtLeastNWidgets(1));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm Rejection'));
      await tester.pumpAndSettle();

      expect(repo.rejectCalls, 1);
      expect(
        repo.lastRejectReason,
        'Missing beneficiary verification evidence',
      );
      expect(bloc.state.detail?.isRejected, isTrue);
    });

    testWidgets('Dark mode & 320px narrow screen renders without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await setRole(UserRole.superAdmin);
      final repo = _FakeLifeImpactRepository(
        currentDetail: buildPendingDetail(),
      );
      final bloc = LifeImpactDetailBloc(activitiesRepository: repo)
        ..add(const LoadLifeImpactDetail(impactId: 'imp-100'));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: LifeImpactDetailView(impactId: 'imp-100', bloc: bloc),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  test('LifeImpactDetailModel.fromActivityItem preserves card context cleanly', () {
    const item = LeaderActivityItemModel(
      id: 'imp-99',
      type: 'impacts',
      title: 'Community Drive',
      subtitle: 'Social',
      description: 'Organized relief camp.',
      status: 'pending',
      date: '2026-11-24',
      peerId: 'p-9',
      peerName: 'Kiran Desai',
      peerCode: 'PG-99',
      city: 'Surat',
      designation: 'Director',
      company: 'Desai Infra',
      category: 'Infrastructure',
      circleName: 'Surat Icons',
      districtName: 'Surat',
      livesImpacted: 12,
    );
    final detail = LifeImpactDetailModel.fromActivityItem(item);
    expect(detail.id, 'imp-99');
    expect(detail.peerCode, 'PG-99');
    expect(detail.livesImpacted, 12);
    expect(detail.submittedBy.name, 'Kiran Desai');
    expect(detail.isPending, isTrue);
  });
}
