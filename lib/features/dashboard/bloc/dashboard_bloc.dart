import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../model/dashboard_metrics_model.dart';
import '../model/impacter_model.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// Business Logic Component for managing Circle Chair dashboard statistics.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardState()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<TabChanged>(_onTabChanged);
    on<SelectCircle>(_onSelectCircle);
  }

  void _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    final session = SessionManager().currentSession;

    // Determine which circle or industry is currently active/selected
    final activeCircle =
        state.selectedCircle ??
        (session.role == UserRole.industryDirector ||
                session.role == UserRole.districtExecDirector ||
                session.role == UserRole.countryDirector ||
                session.role == UserRole.superAdmin
            ? 'Technology'
            : (session.managedCircles.isNotEmpty
                  ? session.managedCircles.first
                  : 'Mumbai Tech Sunrise'));

    final DashboardMetricsModel mockMetrics;
    final List<ImpacterModel> mockImpacters;

    if (activeCircle == 'Technology' || activeCircle == 'Mumbai Tech Sunrise') {
      mockMetrics = DashboardMetricsModel(
        impact: session.role == UserRole.superAdmin ? 321 : 169,
        deals: session.role == UserRole.superAdmin ? '₹0.4Cr' : '₹1.34Cr',
        p2pMeetings: 5,
        totalPeers: session.role == UserRole.superAdmin ? 14 : 56,
        totalPeersGrowth: 3,
        referrals: 11,
        testimonials: session.role == UserRole.superAdmin ? 4 : 3,
        coins: 3840,
        overallRevenue: session.role == UserRole.industryDirector
            ? '₹20.6L'
            : (session.role == UserRole.districtExecDirector
                  ? '₹13.2L'
                  : (session.role == UserRole.countryDirector ||
                         session.role == UserRole.superAdmin
                        ? '₹42.2L'
                        : '₹4.9L')),
        overallDealsClosed: '₹1.34Cr',
      );

      mockImpacters = session.role == UserRole.superAdmin
          ? const [
              ImpacterModel(
                rank: 1,
                name: 'Kiran Nair',
                initials: 'KN',
                company: 'CloudSoft',
                location: 'Bangalore',
                lives: 41,
                coins: 450,
              ),
              ImpacterModel(
                rank: 2,
                name: 'Priya Sharma',
                initials: 'PS',
                company: 'TechVentures',
                location: 'Mumbai',
                lives: 38,
                coins: 420,
              ),
              ImpacterModel(
                rank: 3,
                name: 'Pooja Reddy',
                initials: 'PR',
                company: 'DataDriven',
                location: 'Bangalore',
                lives: 33,
                coins: 390,
              ),
              ImpacterModel(
                rank: 4,
                name: "James O'Brien",
                initials: 'JO',
                company: 'FinTech Pvt',
                location: 'Mumbai',
                lives: 31,
                coins: 380,
              ),
              ImpacterModel(
                rank: 5,
                name: 'Ananya Patel',
                initials: 'AP',
                company: 'HealthFirst',
                location: 'Mumbai',
                lives: 27,
                coins: 340,
              ),
            ]
          : const [
              ImpacterModel(
                rank: 1,
                name: 'Priya Sharma',
                initials: 'PS',
                company: 'TechVentures',
                location: 'Mumbai',
                lives: 38,
                coins: 420,
              ),
              ImpacterModel(
                rank: 2,
                name: "James O'Brien",
                initials: 'JO',
                company: 'FinTech Pvt',
                location: 'Mumbai',
                lives: 31,
                coins: 380,
              ),
              ImpacterModel(
                rank: 3,
                name: 'Ananya Patel',
                initials: 'AP',
                company: 'HealthFirst',
                location: 'Mumbai',
                lives: 27,
                coins: 340,
              ),
              ImpacterModel(
                rank: 4,
                name: 'Marcus Lee',
                initials: 'ML',
                company: 'DevStudio',
                location: 'Mumbai',
                lives: 22,
                coins: 310,
              ),
              ImpacterModel(
                rank: 5,
                name: 'Fatima Al-Rashid',
                initials: 'FA',
                company: 'GlobalCorp',
                location: 'Mumbai',
                lives: 19,
                coins: 290,
              ),
            ];
    } else if (activeCircle == 'Healthcare') {
      mockMetrics = const DashboardMetricsModel(
        impact: 112,
        deals: '₹95.0L',
        p2pMeetings: 3,
        totalPeers: 42,
        totalPeersGrowth: 2,
        referrals: 7,
        testimonials: 2,
        coins: 2840,
        overallRevenue: '₹15.2L',
        overallDealsClosed: '₹95.0L',
      );

      mockImpacters = const [
        ImpacterModel(
          rank: 1,
          name: 'Dr. Amit Verma',
          initials: 'AV',
          company: 'CarePlus',
          location: 'Pune',
          lives: 35,
          coins: 390,
        ),
        ImpacterModel(
          rank: 2,
          name: 'Sarah Jenkins',
          initials: 'SJ',
          company: 'MedTech',
          location: 'Mumbai',
          lives: 28,
          coins: 310,
        ),
        ImpacterModel(
          rank: 3,
          name: 'Vikram Malhotra',
          initials: 'VM',
          company: 'HealthFirst',
          location: 'Mumbai',
          lives: 24,
          coins: 280,
        ),
        ImpacterModel(
          rank: 4,
          name: 'Neha Sen',
          initials: 'NS',
          company: 'BioLife',
          location: 'Pune',
          lives: 20,
          coins: 240,
        ),
        ImpacterModel(
          rank: 5,
          name: 'Rajesh Patel',
          initials: 'RP',
          company: 'PharmaCorp',
          location: 'Mumbai',
          lives: 15,
          coins: 180,
        ),
      ];
    } else if (activeCircle == 'Startups') {
      mockMetrics = const DashboardMetricsModel(
        impact: 88,
        deals: '₹65.0L',
        p2pMeetings: 2,
        totalPeers: 30,
        totalPeersGrowth: 4,
        referrals: 5,
        testimonials: 1,
        coins: 1540,
        overallRevenue: '₹9.8L',
        overallDealsClosed: '₹65.0L',
      );

      mockImpacters = const [
        ImpacterModel(
          rank: 1,
          name: 'Rohan Joshi',
          initials: 'RJ',
          company: 'SwiftApp',
          location: 'Mumbai',
          lives: 30,
          coins: 320,
        ),
        ImpacterModel(
          rank: 2,
          name: 'Priya Sharma',
          initials: 'PS',
          company: 'TechVentures',
          location: 'Mumbai',
          lives: 25,
          coins: 290,
        ),
        ImpacterModel(
          rank: 3,
          name: 'Kunal Shah',
          initials: 'KS',
          company: 'FinTech Pvt',
          location: 'Pune',
          lives: 22,
          coins: 250,
        ),
        ImpacterModel(
          rank: 4,
          name: 'Marcus Lee',
          initials: 'ML',
          company: 'DevStudio',
          location: 'Mumbai',
          lives: 18,
          coins: 210,
        ),
        ImpacterModel(
          rank: 5,
          name: 'Aisha Khan',
          initials: 'AK',
          company: 'GrowthHack',
          location: 'Mumbai',
          lives: 12,
          coins: 150,
        ),
      ];
    } else if (activeCircle == 'Pune Manufacturing Hub' ||
        activeCircle == 'Pune Tech Innovators') {
      mockMetrics = const DashboardMetricsModel(
        impact: 245,
        deals: '₹1.92Cr',
        p2pMeetings: 8,
        totalPeers: 78,
        totalPeersGrowth: 5,
        referrals: 15,
        testimonials: 4,
        coins: 4920,
        overallRevenue: '₹6.8L',
        overallDealsClosed: '₹1.92Cr',
      );

      mockImpacters = const [
        ImpacterModel(
          rank: 1,
          name: 'Priya Sharma',
          initials: 'PS',
          company: 'TechVentures',
          location: 'Mumbai',
          lives: 56,
          coins: 680,
        ),
        ImpacterModel(
          rank: 2,
          name: "James O'Brien",
          initials: 'JO',
          company: 'FinTech Pvt',
          location: 'Mumbai',
          lives: 48,
          coins: 520,
        ),
        ImpacterModel(
          rank: 3,
          name: 'Ananya Patel',
          initials: 'AP',
          company: 'HealthFirst',
          location: 'Mumbai',
          lives: 41,
          coins: 460,
        ),
        ImpacterModel(
          rank: 4,
          name: 'Karthik Raja',
          initials: 'KR',
          company: 'Apex Labs',
          location: 'Bengaluru',
          lives: 38,
          coins: 410,
        ),
        ImpacterModel(
          rank: 5,
          name: 'Suresh Kumar',
          initials: 'SK',
          company: 'IndieGames',
          location: 'Bengaluru',
          lives: 33,
          coins: 390,
        ),
      ];
    } else {
      mockMetrics = const DashboardMetricsModel(
        impact: 312,
        deals: '₹2.50Cr',
        p2pMeetings: 10,
        totalPeers: 95,
        totalPeersGrowth: 6,
        referrals: 18,
        testimonials: 6,
        coins: 6150,
        overallRevenue: '₹8.5L',
        overallDealsClosed: '₹2.50Cr',
      );

      mockImpacters = const [
        ImpacterModel(
          rank: 1,
          name: 'Ananya Patel',
          initials: 'AP',
          company: 'HealthFirst',
          location: 'Mumbai',
          lives: 45,
          coins: 510,
        ),
        ImpacterModel(
          rank: 2,
          name: 'Priya Sharma',
          initials: 'PS',
          company: 'TechVentures',
          location: 'Mumbai',
          lives: 42,
          coins: 480,
        ),
        ImpacterModel(
          rank: 3,
          name: "James O'Brien",
          initials: 'JO',
          company: 'FinTech Pvt',
          location: 'Mumbai',
          lives: 37,
          coins: 430,
        ),
        ImpacterModel(
          rank: 4,
          name: 'Fatima Al-Rashid',
          initials: 'FA',
          company: 'GlobalCorp',
          location: 'Mumbai',
          lives: 29,
          coins: 350,
        ),
        ImpacterModel(
          rank: 5,
          name: 'Marcus Lee',
          initials: 'ML',
          company: 'DevStudio',
          location: 'Mumbai',
          lives: 25,
          coins: 320,
        ),
      ];
    }

    emit(
      state.copyWith(
        isLoading: false,
        metrics: mockMetrics,
        impacters: mockImpacters,
        selectedCircle: activeCircle,
      ),
    );
  }

  void _onSelectCircle(SelectCircle event, Emitter<DashboardState> emit) {
    emit(state.copyWith(selectedCircle: event.circleName));
    add(const LoadDashboardData());
  }

  void _onTabChanged(TabChanged event, Emitter<DashboardState> emit) {
    emit(state.copyWith(activeTab: event.index));
  }
}
