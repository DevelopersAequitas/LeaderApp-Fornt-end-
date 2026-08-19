import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../model/finance_model.dart';
import 'finance_event.dart';
import 'finance_state.dart';

/// Business Logic Component for managing Finance permissions.
class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  static const FinanceMetricsModel _mockMumbaiFinance = FinanceMetricsModel(
    totalRevenue: '₹42.2L',
    circleRevenue: '₹4.9L',
    dealsClosed: 7,
    commissionDue: '₹24.5k',
    revenueTrend: [
      FinanceChartPoint(month: 'Feb', value: 175),
      FinanceChartPoint(month: 'Mar', value: 240),
      FinanceChartPoint(month: 'Apr', value: 210),
      FinanceChartPoint(month: 'May', value: 310),
      FinanceChartPoint(month: 'Jun', value: 410),
      FinanceChartPoint(month: 'Jul', value: 500),
    ],
    businessDeals: [
      FinanceChartPoint(month: 'Feb', value: 40),
      FinanceChartPoint(month: 'Mar', value: 67),
      FinanceChartPoint(month: 'Apr', value: 55),
      FinanceChartPoint(month: 'May', value: 88),
      FinanceChartPoint(month: 'Jun', value: 110),
      FinanceChartPoint(month: 'Jul', value: 135),
    ],
    commissionRates: [
      CommissionRateModel(
        label: 'Direct Referral Cut',
        rate: '0%',
        description: 'You personally bring the peer',
        status: 'To be configured',
      ),
      CommissionRateModel(
        label: 'App Join Cut',
        rate: '0%',
        description: 'Peer joins via app',
        status: 'To be configured',
      ),
    ],
    commissionStructure: [
      CommissionStructureItemModel(
        role: 'Circle Founder',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.hub_outlined,
      ),
      CommissionStructureItemModel(
        role: 'Circle Director',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.track_changes_rounded,
      ),
      CommissionStructureItemModel(
        role: 'Industry Director',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.bar_chart_rounded,
      ),
      CommissionStructureItemModel(
        role: 'District Exec Director',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.map_outlined,
      ),
      CommissionStructureItemModel(
        role: 'Country Director',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.public_rounded,
      ),
      CommissionStructureItemModel(
        role: 'Super Admin',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.flash_on_outlined,
      ),
    ],
  );

  static const FinanceMetricsModel _mockPuneFinance = FinanceMetricsModel(
    totalRevenue: '₹42.2L',
    circleRevenue: '₹2.4L',
    dealsClosed: 4,
    commissionDue: '₹12.0k',
    revenueTrend: [
      FinanceChartPoint(month: 'Feb', value: 100),
      FinanceChartPoint(month: 'Mar', value: 150),
      FinanceChartPoint(month: 'Apr', value: 120),
      FinanceChartPoint(month: 'May', value: 200),
      FinanceChartPoint(month: 'Jun', value: 250),
      FinanceChartPoint(month: 'Jul', value: 300),
    ],
    businessDeals: [
      FinanceChartPoint(month: 'Feb', value: 30),
      FinanceChartPoint(month: 'Mar', value: 45),
      FinanceChartPoint(month: 'Apr', value: 35),
      FinanceChartPoint(month: 'May', value: 60),
      FinanceChartPoint(month: 'Jun', value: 80),
      FinanceChartPoint(month: 'Jul', value: 95),
    ],
    commissionRates: [
      CommissionRateModel(
        label: 'Direct Referral Cut',
        rate: '0%',
        description: 'You personally bring the peer',
        status: 'To be configured',
      ),
      CommissionRateModel(
        label: 'App Join Cut',
        rate: '0%',
        description: 'Peer joins via app',
        status: 'To be configured',
      ),
    ],
    commissionStructure: [
      CommissionStructureItemModel(
        role: 'Circle Founder',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.hub_outlined,
      ),
      CommissionStructureItemModel(
        role: 'Circle Director',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.track_changes_rounded,
      ),
      CommissionStructureItemModel(
        role: 'Industry Director',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.bar_chart_rounded,
      ),
      CommissionStructureItemModel(
        role: 'District Exec Director',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.map_outlined,
      ),
      CommissionStructureItemModel(
        role: 'Country Director',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.public_rounded,
      ),
      CommissionStructureItemModel(
        role: 'Super Admin',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.flash_on_outlined,
      ),
    ],
  );

  static const FinanceMetricsModel _mockHealthcareFinance = FinanceMetricsModel(
    totalRevenue: '₹31.5L',
    circleRevenue: '₹2.1L',
    dealsClosed: 5,
    commissionDue: '₹15.0k',
    revenueTrend: [
      FinanceChartPoint(month: 'Feb', value: 120),
      FinanceChartPoint(month: 'Mar', value: 180),
      FinanceChartPoint(month: 'Apr', value: 160),
      FinanceChartPoint(month: 'May', value: 240),
      FinanceChartPoint(month: 'Jun', value: 310),
      FinanceChartPoint(month: 'Jul', value: 380),
    ],
    businessDeals: [
      FinanceChartPoint(month: 'Feb', value: 30),
      FinanceChartPoint(month: 'Mar', value: 50),
      FinanceChartPoint(month: 'Apr', value: 45),
      FinanceChartPoint(month: 'May', value: 70),
      FinanceChartPoint(month: 'Jun', value: 90),
      FinanceChartPoint(month: 'Jul', value: 110),
    ],
    commissionRates: [
      CommissionRateModel(
        label: 'Direct Referral Cut',
        rate: '0%',
        description: 'You personally bring the peer',
        status: 'To be configured',
      ),
      CommissionRateModel(
        label: 'App Join Cut',
        rate: '0%',
        description: 'Peer joins via app',
        status: 'To be configured',
      ),
    ],
    commissionStructure: [
      CommissionStructureItemModel(
        role: 'Circle Founder',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.hub_outlined,
      ),
      CommissionStructureItemModel(
        role: 'Circle Director',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.track_changes_rounded,
      ),
      CommissionStructureItemModel(
        role: 'Industry Director',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.bar_chart_rounded,
      ),
      CommissionStructureItemModel(
        role: 'District Exec Director',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.map_outlined,
      ),
      CommissionStructureItemModel(
        role: 'Country Director',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.public_rounded,
      ),
      CommissionStructureItemModel(
        role: 'Super Admin',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.flash_on_outlined,
      ),
    ],
  );

  static const FinanceMetricsModel _mockStartupsFinance = FinanceMetricsModel(
    totalRevenue: '₹18.4L',
    circleRevenue: '₹1.5L',
    dealsClosed: 3,
    commissionDue: '₹8.5k',
    revenueTrend: [
      FinanceChartPoint(month: 'Feb', value: 80),
      FinanceChartPoint(month: 'Mar', value: 110),
      FinanceChartPoint(month: 'Apr', value: 95),
      FinanceChartPoint(month: 'May', value: 140),
      FinanceChartPoint(month: 'Jun', value: 180),
      FinanceChartPoint(month: 'Jul', value: 220),
    ],
    businessDeals: [
      FinanceChartPoint(month: 'Feb', value: 20),
      FinanceChartPoint(month: 'Mar', value: 35),
      FinanceChartPoint(month: 'Apr', value: 30),
      FinanceChartPoint(month: 'May', value: 45),
      FinanceChartPoint(month: 'Jun', value: 60),
      FinanceChartPoint(month: 'Jul', value: 75),
    ],
    commissionRates: [
      CommissionRateModel(
        label: 'Direct Referral Cut',
        rate: '0%',
        description: 'You personally bring the peer',
        status: 'To be configured',
      ),
      CommissionRateModel(
        label: 'App Join Cut',
        rate: '0%',
        description: 'Peer joins via app',
        status: 'To be configured',
      ),
    ],
    commissionStructure: [
      CommissionStructureItemModel(
        role: 'Circle Founder',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.hub_outlined,
      ),
      CommissionStructureItemModel(
        role: 'Circle Director',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.track_changes_rounded,
      ),
      CommissionStructureItemModel(
        role: 'Industry Director',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.bar_chart_rounded,
      ),
      CommissionStructureItemModel(
        role: 'District Exec Director',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.map_outlined,
      ),
      CommissionStructureItemModel(
        role: 'Country Director',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.public_rounded,
      ),
      CommissionStructureItemModel(
        role: 'Super Admin',
        directReferralCut: '0%',
        appJoinCut: '0%',
        icon: Icons.flash_on_outlined,
      ),
    ],
  );

  FinanceBloc() : super(const FinanceState()) {
    on<LoadFinanceData>(_onLoadFinanceData);
  }

  void _onLoadFinanceData(LoadFinanceData event, Emitter<FinanceState> emit) {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    final role = SessionManager().currentRole;
    final isRestricted = role == UserRole.circleChair;

    final mockPermission = FinancePermissionModel(
      role: role.label,
      isRestricted: isRestricted,
      requiredCapabilities: const [
        'view transaction logs',
        'view payment summaries',
      ],
    );

    final activeCircle =
        event.selectedCircle ?? state.selectedCircle ?? 'Technology';
    final FinanceMetricsModel metrics;
    if (activeCircle == 'Pune Tech Innovators') {
      metrics = _mockPuneFinance;
    } else if (activeCircle == 'Healthcare') {
      metrics = _mockHealthcareFinance;
    } else if (activeCircle == 'Startups') {
      metrics = _mockStartupsFinance;
    } else {
      metrics = _mockMumbaiFinance;
    }

    emit(
      state.copyWith(
        isLoading: false,
        permission: mockPermission,
        metrics: metrics,
        selectedCircle: activeCircle,
      ),
    );
  }
}
