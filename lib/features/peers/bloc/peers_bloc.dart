import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../model/peer_model.dart';
import '../model/celebration_model.dart';
import 'peers_event.dart';
import 'peers_state.dart';

/// Business Logic Component for managing Peers listings, filtering, sorting, and celebrations.
class PeersBloc extends Bloc<PeersEvent, PeersState> {
  PeersBloc() : super(const PeersState()) {
    on<LoadPeersData>(_onLoadPeersData);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<StatusFilterChanged>(_onStatusFilterChanged);
    on<MetricSortChanged>(_onMetricSortChanged);
    on<ToggleSubTab>(_onToggleSubTab);
    on<SendWish>(_onSendWish);
  }

  // Raw mock database of peers matching circle and industry configurations
  static const List<PeerModel> _mockPeersDb = [
    // --- Technology Industry / Mumbai Tech Sunrise ---
    PeerModel(
      initials: 'KN',
      name: 'Kiran Nair',
      company: 'CloudSoft',
      circle: 'Bangalore Digital Hub',
      location: 'Bangalore',
      tags: 'Technology · Cloud Services',
      impactCount: 41,
      dealsFormatted: '₹1.20Cr',
      coins: 450,
      attendance: '90%',
      status: 'Active',
      industry: 'Technology',
    ),
    PeerModel(
      initials: 'PS',
      name: 'Priya Sharma',
      company: 'TechVentures',
      circle: 'Mumbai Tech Sunrise',
      location: 'Mumbai',
      tags: 'Technology · AI & Machine Learning',
      impactCount: 38,
      dealsFormatted: '₹1.10Cr',
      coins: 420,
      attendance: '95%',
      status: 'Active',
      industry: 'Technology',
    ),
    PeerModel(
      initials: 'PR',
      name: 'Pooja Reddy',
      company: 'DataDriven',
      circle: 'Bangalore Digital Hub',
      location: 'Bangalore',
      tags: 'Analytics · Data Analytics',
      impactCount: 33,
      dealsFormatted: '₹80L',
      coins: 340,
      attendance: '92%',
      status: 'Active',
      industry: 'Technology',
    ),
    PeerModel(
      initials: 'JO',
      name: "James O'Brien",
      company: 'FinTech Pvt',
      circle: 'Mumbai Tech Sunrise',
      location: 'Mumbai',
      tags: 'Finance · SaaS & Platforms',
      impactCount: 31,
      dealsFormatted: '₹85L',
      coins: 380,
      attendance: '88%',
      status: 'Active',
      industry: 'Technology',
    ),
    PeerModel(
      initials: 'AP',
      name: 'Ananya Patel',
      company: 'HealthFirst',
      circle: 'Mumbai Tech Sunrise',
      location: 'Mumbai',
      tags: 'Healthcare · Web & App Development',
      impactCount: 27,
      dealsFormatted: '₹65L',
      coins: 340,
      attendance: '92%',
      status: 'Active',
      industry: 'Technology',
    ),
    PeerModel(
      initials: 'ML',
      name: 'Marcus Lee',
      company: 'DevStudio',
      circle: 'Mumbai Tech Sunrise',
      location: 'Mumbai',
      tags: 'Technology · Web & App Development',
      impactCount: 22,
      dealsFormatted: '₹50L',
      coins: 310,
      attendance: '85%',
      status: 'Active',
      industry: 'Technology',
    ),
    PeerModel(
      initials: 'FA',
      name: 'Fatima Al-Rashid',
      company: 'LegalEdge',
      circle: 'Mumbai Tech Sunrise',
      location: 'Mumbai',
      tags: 'Legal · Data Analytics',
      impactCount: 18,
      dealsFormatted: '₹45L',
      coins: 290,
      attendance: '90%',
      status: 'Active',
      industry: 'Technology',
    ),
    PeerModel(
      initials: 'VM',
      name: 'Vikram Malhotra',
      company: 'EduInnovate',
      circle: 'Mumbai Tech Sunrise',
      location: 'Mumbai',
      tags: 'Education · EdTech Solutions',
      impactCount: 15,
      dealsFormatted: '₹30L',
      coins: 250,
      attendance: '78%',
      status: 'Active',
      industry: 'Technology',
    ),
    PeerModel(
      initials: 'SR',
      name: 'Sanjana Rao',
      company: 'CreativeHub',
      circle: 'Mumbai Tech Sunrise',
      location: 'Mumbai',
      tags: 'Design · UI/UX Agency',
      impactCount: 12,
      dealsFormatted: '₹25L',
      coins: 220,
      attendance: '94%',
      status: 'Active',
      industry: 'Technology',
    ),
    PeerModel(
      initials: 'RD',
      name: 'Rajan Das',
      company: 'MedCare',
      circle: 'Mumbai Health Circle',
      location: 'Mumbai',
      tags: 'Healthcare · Telemedicine',
      impactCount: 10,
      dealsFormatted: '₹20L',
      coins: 200,
      attendance: '80%',
      status: 'At Risk',
      industry: 'Technology',
    ),
    PeerModel(
      initials: 'DK',
      name: 'David Kim',
      company: 'ConsultPro',
      circle: 'Mumbai Tech Sunrise',
      location: 'Mumbai',
      tags: 'Consulting · Cloud Services',
      impactCount: 8,
      dealsFormatted: '₹15L',
      coins: 180,
      attendance: '75%',
      status: 'At Risk',
      industry: 'Technology',
    ),
    PeerModel(
      initials: 'RG',
      name: 'Rohan Gupta',
      company: 'SaaSify',
      circle: 'Pune Digital Node',
      location: 'Pune',
      tags: 'Technology · SaaS Products',
      impactCount: 20,
      dealsFormatted: '₹28L',
      coins: 280,
      attendance: '87%',
      status: 'Active',
      industry: 'Technology',
    ),
    PeerModel(
      initials: 'NS',
      name: 'Neha Sen',
      company: 'CyberShield',
      circle: 'Goa Creators Circle',
      location: 'Goa',
      tags: 'Technology · Cyber Security',
      impactCount: 16,
      dealsFormatted: '₹24L',
      coins: 240,
      attendance: '85%',
      status: 'Active',
      industry: 'Technology',
    ),
    PeerModel(
      initials: 'SC',
      name: 'Sarah Connor',
      company: 'TechOps',
      circle: 'Pune Digital Node',
      location: 'Pune',
      tags: 'Technology · DevOps',
      impactCount: 14,
      dealsFormatted: '₹21L',
      coins: 210,
      attendance: '84%',
      status: 'Active',
      industry: 'Technology',
    ),
    // Fallback/extra original peers for other circles
    PeerModel(
      initials: 'KN',
      name: 'Kavitha Nair',
      company: 'AgriGrow',
      circle: 'Mumbai Tech Sunrise',
      location: 'Mumbai',
      tags: 'Agriculture · AgriTech',
      impactCount: 9,
      dealsFormatted: '₹15L',
      coins: 185,
      attendance: '72%',
      status: 'At Risk',
      industry: 'Agriculture',
    ),
    // Pune Tech Innovators Mock Database
    PeerModel(
      initials: 'PS',
      name: 'Priya Sharma',
      company: 'TechVentures',
      circle: 'Pune Tech Innovators',
      location: 'Pune',
      tags: 'Technology · AI & Machine Learning',
      impactCount: 56,
      dealsFormatted: '₹2.10Cr',
      coins: 680,
      attendance: '98%',
      status: 'Active',
      industry: 'Technology',
    ),
    PeerModel(
      initials: 'JO',
      name: "James O'Brien",
      company: 'FinTech Pvt',
      circle: 'Pune Tech Innovators',
      location: 'Pune',
      tags: 'Finance · SaaS & Platforms',
      impactCount: 48,
      dealsFormatted: '₹1.50Cr',
      coins: 520,
      attendance: '90%',
      status: 'Active',
      industry: 'Technology',
    ),
    PeerModel(
      initials: 'AP',
      name: 'Ananya Patel',
      company: 'HealthFirst',
      circle: 'Pune Tech Innovators',
      location: 'Pune',
      tags: 'Healthcare · Web & App Development',
      impactCount: 41,
      dealsFormatted: '₹1.20Cr',
      coins: 460,
      attendance: '94%',
      status: 'Active',
      industry: 'Healthcare',
    ),
    PeerModel(
      initials: 'KR',
      name: 'Karthik Raja',
      company: 'Apex Labs',
      circle: 'Pune Tech Innovators',
      location: 'Pune',
      tags: 'Technology · Web & App Development',
      impactCount: 38,
      dealsFormatted: '₹95L',
      coins: 410,
      attendance: '87%',
      status: 'Active',
      industry: 'Technology',
    ),
    PeerModel(
      initials: 'SK',
      name: 'Suresh Kumar',
      circle: 'Pune Tech Innovators',
      company: 'IndieGames',
      location: 'Pune',
      tags: 'Gaming · Indie Games',
      impactCount: 33,
      dealsFormatted: '₹75L',
      coins: 390,
      attendance: '74%',
      status: 'At Risk',
      industry: 'Technology',
    ),
    // --- Healthcare Industry Specific ---
    PeerModel(
      initials: 'AV',
      name: 'Dr. Amit Verma',
      company: 'CarePlus',
      circle: 'Pune Manufacturing Hub',
      location: 'Pune',
      tags: 'Healthcare · Clinical Trials',
      impactCount: 35,
      dealsFormatted: '₹90L',
      coins: 390,
      attendance: '88%',
      status: 'Active',
      industry: 'Healthcare',
    ),
    PeerModel(
      initials: 'SJ',
      name: 'Sarah Jenkins',
      company: 'MedTech',
      circle: 'Mumbai Tech Sunrise',
      location: 'Mumbai',
      tags: 'Healthcare · Medical Devices',
      impactCount: 28,
      dealsFormatted: '₹80L',
      coins: 310,
      attendance: '91%',
      status: 'Active',
      industry: 'Healthcare',
    ),
    // --- Startups Industry Specific ---
    PeerModel(
      initials: 'RJ',
      name: 'Rohan Joshi',
      company: 'SwiftApp',
      circle: 'Mumbai Tech Sunrise',
      location: 'Mumbai',
      tags: 'Startups · App Development',
      impactCount: 30,
      dealsFormatted: '₹70L',
      coins: 320,
      attendance: '89%',
      status: 'Active',
      industry: 'Startups',
    ),
    PeerModel(
      initials: 'KS',
      name: 'Kunal Shah',
      company: 'FinTech Pvt',
      circle: 'Pune Tech Innovators',
      location: 'Pune',
      tags: 'Startups · SaaS Platforms',
      impactCount: 22,
      dealsFormatted: '₹55L',
      coins: 250,
      attendance: '84%',
      status: 'Active',
      industry: 'Startups',
    ),
  ];

  static const List<CelebrationModel> _mockBirthdays = [
    CelebrationModel(
      peerName: 'Ananya Patel',
      company: 'HealthFirst',
      date: '18 Aug',
      type: 'birthday',
    ),
  ];

  static const List<CelebrationModel> _mockAnniversaries = [
    CelebrationModel(
      peerName: 'Marcus Lee',
      company: 'DevStudio',
      date: '28 Aug',
      type: 'anniversary',
    ),
  ];

  void _onLoadPeersData(LoadPeersData event, Emitter<PeersState> emit) {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    final session = SessionManager().currentSession;
    final isIndustryDirector =
        session.role == UserRole.industryDirector ||
        session.role == UserRole.districtExecDirector ||
        session.role == UserRole.countryDirector ||
        session.role == UserRole.superAdmin;
    final activeCircle =
        event.selectedCircle ??
        state.selectedCircle ??
        (isIndustryDirector ? 'Technology' : 'Mumbai Tech Sunrise');

    // 1. Get all peers for the active circle or industry
    final circlePeers = isIndustryDirector
        ? _mockPeersDb.where((p) => p.industry == activeCircle).toList()
        : _mockPeersDb.where((p) => p.circle == activeCircle).toList();

    // 2. Filter and sort those peers based on active state parameters
    final filtered = _filterAndSort(
      circlePeers,
      state.searchQuery,
      state.selectedStatus,
      state.selectedSort,
    );

    // 3. Filter celebrations to only those peers belonging to the active circle
    final birthdays = _mockBirthdays
        .where((b) => circlePeers.any((p) => p.name == b.peerName))
        .toList();
    final anniversaries = _mockAnniversaries
        .where((a) => circlePeers.any((p) => p.name == a.peerName))
        .toList();

    emit(
      state.copyWith(
        isLoading: false,
        allPeers: circlePeers,
        filteredPeers: filtered,
        birthdays: birthdays,
        anniversaries: anniversaries,
        selectedCircle: activeCircle,
      ),
    );
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<PeersState> emit,
  ) {
    final filtered = _filterAndSort(
      state.allPeers,
      event.query,
      state.selectedStatus,
      state.selectedSort,
    );
    emit(state.copyWith(searchQuery: event.query, filteredPeers: filtered));
  }

  void _onStatusFilterChanged(
    StatusFilterChanged event,
    Emitter<PeersState> emit,
  ) {
    final filtered = _filterAndSort(
      state.allPeers,
      state.searchQuery,
      event.status,
      state.selectedSort,
    );
    emit(state.copyWith(selectedStatus: event.status, filteredPeers: filtered));
  }

  void _onMetricSortChanged(MetricSortChanged event, Emitter<PeersState> emit) {
    final filtered = _filterAndSort(
      state.allPeers,
      state.searchQuery,
      state.selectedStatus,
      event.metric,
    );
    emit(state.copyWith(selectedSort: event.metric, filteredPeers: filtered));
  }

  void _onToggleSubTab(ToggleSubTab event, Emitter<PeersState> emit) {
    emit(state.copyWith(activeSubTab: event.tabIndex));
  }

  void _onSendWish(SendWish event, Emitter<PeersState> emit) {
    // Simulates sending wishes by triggering a message response
    // Handled in UI by view contracts, doesn't require complex states
  }

  // --- Filtering & Sorting Helpers ---

  List<PeerModel> _filterAndSort(
    List<PeerModel> list,
    String query,
    String status,
    String sort,
  ) {
    // 1. Text Search Filter
    var result = list;
    if (query.trim().isNotEmpty) {
      final cleanQuery = query.toLowerCase().trim();
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(cleanQuery) ||
                p.company.toLowerCase().contains(cleanQuery),
          )
          .toList();
    }

    // 2. Status Filter
    if (status != 'All') {
      result = result.where((p) => p.status == status).toList();
    }

    // 3. Metric Sort
    result = List.from(result); // make mutable copy
    if (sort == 'Impact') {
      result.sort((a, b) => b.impactCount.compareTo(a.impactCount));
    } else if (sort == 'Deals') {
      result.sort(
        (a, b) => _parseDeals(
          b.dealsFormatted,
        ).compareTo(_parseDeals(a.dealsFormatted)),
      );
    } else if (sort == 'Coins') {
      result.sort((a, b) => b.coins.compareTo(a.coins));
    } else if (sort == 'Attendance') {
      result.sort(
        (a, b) => _parseAttendance(
          b.attendance,
        ).compareTo(_parseAttendance(a.attendance)),
      );
    }

    return result;
  }

  double _parseDeals(String deals) {
    final clean = deals.replaceAll('₹', '').replaceAll(' ', '');
    if (clean.contains('Cr')) {
      final val = double.tryParse(clean.replaceAll('Cr', '')) ?? 0.0;
      return val * 100.0; // scale Crore up relative to Lakhs
    } else if (clean.contains('L')) {
      return double.tryParse(clean.replaceAll('L', '')) ?? 0.0;
    }
    return 0.0;
  }

  int _parseAttendance(String val) {
    final clean = val.replaceAll('%', '').trim();
    return int.tryParse(clean) ?? 0;
  }
}
