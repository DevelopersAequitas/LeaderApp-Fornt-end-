import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../model/teams_model.dart';
import 'teams_event.dart';
import 'teams_state.dart';

/// Business Logic Component for managing Teams permissions.
class TeamsBloc extends Bloc<TeamsEvent, TeamsState> {
  static const List<CircleTeamModel> _mockCirclesDb = [
    // --- Technology circles ---
    CircleTeamModel(
      name: 'Mumbai Tech Sunrise',
      category: 'Technology',
      location: 'Mumbai',
      peersCount: 60,
      healthPercentage: 90,
      revenue: '₹5.5L',
      tags: ['Web & App Development', 'AI & Machine Learning', '+1'],
      founderName: 'Sanjana',
      directorName: 'Rohit',
      chairName: 'Arjun',
      status: 'Active',
    ),
    CircleTeamModel(
      name: 'Bangalore Digital Hub',
      category: 'Technology',
      location: 'Bangalore',
      peersCount: 65,
      healthPercentage: 91,
      revenue: '₹6.0L',
      tags: ['Data Analytics', 'Cloud Services', '+1'],
      founderName: 'Kiran',
      directorName: 'Pooja',
      chairName: 'Rohan',
      status: 'Active',
    ),
    CircleTeamModel(
      name: 'Pune Tech Innovators',
      category: 'Technology',
      location: 'Pune',
      peersCount: 50,
      healthPercentage: 82,
      revenue: '₹4.0L',
      tags: ['Cloud Computing', 'IoT Solutions', '+1'],
      founderName: 'Rahul',
      directorName: 'James',
      chairName: 'Amit',
      status: 'Active',
    ),
    CircleTeamModel(
      name: 'Hyderabad Software Collective',
      category: 'Technology',
      location: 'Hyderabad',
      peersCount: 42,
      healthPercentage: 78,
      revenue: '₹3.5L',
      tags: ['Cyber Security', 'DevOps', '+1'],
      founderName: 'Neha',
      directorName: 'Vikram',
      chairName: 'Sneha',
      status: 'Active',
    ),
    CircleTeamModel(
      name: 'Delhi AI Lab',
      category: 'Technology',
      location: 'Delhi',
      peersCount: 38,
      healthPercentage: 72,
      revenue: '₹2.5L',
      tags: ['Machine Learning', 'Big Data', '+1'],
      founderName: 'Akash',
      directorName: 'Naman',
      chairName: 'Kabir',
      status: 'Active',
    ),
    CircleTeamModel(
      name: 'Chennai SaaS Node',
      category: 'Technology',
      location: 'Chennai',
      peersCount: 30,
      healthPercentage: 62,
      revenue: '₹1.5L',
      tags: ['SaaS Products', 'Enterprise', '+1'],
      founderName: 'Anand',
      directorName: 'Bala',
      chairName: 'Chitra',
      status: 'At Risk',
    ),

    // --- Healthcare circles ---
    CircleTeamModel(
      name: 'Mumbai Health Circle',
      category: 'Healthcare',
      location: 'Mumbai',
      peersCount: 38,
      healthPercentage: 68,
      revenue: '₹2.5L',
      tags: ['Telemedicine', 'Wellness & Fitness', '+1'],
      founderName: 'Rahul',
      directorName: 'James',
      chairName: 'Pooja',
      status: 'At Risk',
    ),
    CircleTeamModel(
      name: 'Pune Healthcare Hub',
      category: 'Healthcare',
      location: 'Pune',
      peersCount: 44,
      healthPercentage: 78,
      revenue: '₹3.2L',
      tags: ['Medical Devices', 'Clinical Trials', '+1'],
      founderName: 'Amit',
      directorName: 'Suresh',
      chairName: 'Karthik',
      status: 'Active',
    ),

    // --- Startups circles ---
    CircleTeamModel(
      name: 'Mumbai Startup Club',
      category: 'Startups',
      location: 'Mumbai',
      peersCount: 25,
      healthPercentage: 86,
      revenue: '₹1.5L',
      tags: ['App Development', 'SaaS Platforms', '+1'],
      founderName: 'Rohan',
      directorName: 'Priya',
      chairName: 'Kunal',
      status: 'Active',
    ),
    CircleTeamModel(
      name: 'Bangalore Startup Nest',
      category: 'Startups',
      location: 'Bangalore',
      peersCount: 29,
      healthPercentage: 77,
      revenue: '₹2.0L',
      tags: ['FinTech', 'E-Commerce', '+1'],
      founderName: 'Sarah',
      directorName: 'David',
      chairName: 'Kim',
      status: 'Active',
    ),
    
    // --- Manufacturing and Real Estate ---
    CircleTeamModel(
      name: 'Pune Manufacturing Hub',
      category: 'Manufacturing',
      location: 'Pune',
      peersCount: 48,
      healthPercentage: 79,
      revenue: '₹3.8L',
      tags: ['Automotive Components', 'Steel & Metals', '+1'],
      founderName: 'Fatima',
      directorName: 'Marcus',
      chairName: 'Sneha',
      status: 'Active',
    ),
    CircleTeamModel(
      name: 'Mumbai Real Estate Elite',
      category: 'Real Estate',
      location: 'Mumbai',
      peersCount: 45,
      healthPercentage: 85,
      revenue: '₹6.2L',
      tags: ['Commercial Property', 'Residential Brokerage', '+1'],
      founderName: 'Vikram',
      directorName: 'Rohit',
      chairName: 'Siddharth',
      status: 'Active',
    ),
  ];

  TeamsBloc() : super(const TeamsState()) {
    on<LoadTeamsData>(_onLoadTeamsData);
    on<SearchCirclesQueryChanged>(_onSearchCirclesQueryChanged);
    on<StatusCirclesFilterChanged>(_onStatusCirclesFilterChanged);
    on<IndustryCirclesFilterChanged>(_onIndustryCirclesFilterChanged);
  }

  void _onLoadTeamsData(LoadTeamsData event, Emitter<TeamsState> emit) {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    final role = SessionManager().currentRole;
    final isRestricted = role == UserRole.circleChair;

    final mockPermission = TeamsPermissionModel(
      role: role.label,
      isRestricted: isRestricted,
      requiredCapabilities: const ['view industry data', 'view district data'],
    );

    final isIndustryDirector = role == UserRole.industryDirector;
    final isDistrictExec = role == UserRole.districtExecDirector;
    final activeCircle =
        event.selectedCircle ??
        state.selectedCircle ??
        (isIndustryDirector ? 'Technology' : 'All');

    final List<CircleTeamModel> scopeCircles;
    if (isDistrictExec) {
      scopeCircles = _mockCirclesDb
          .where((c) => c.location.toLowerCase().trim() == 'mumbai')
          .toList();
    } else if (isIndustryDirector) {
      scopeCircles = _mockCirclesDb
          .where(
            (c) =>
                c.category.toLowerCase().trim() ==
                activeCircle.toLowerCase().trim(),
          )
          .toList();
    } else {
      scopeCircles = _mockCirclesDb;
    }

    final filtered = _filterAndSortCircles(
      scopeCircles,
      state.searchQuery,
      state.selectedStatusFilter,
      state.selectedIndustryFilter,
    );

    emit(
      state.copyWith(
        isLoading: false,
        permission: mockPermission,
        allCircles: scopeCircles,
        filteredCircles: filtered,
        selectedCircle: activeCircle,
      ),
    );
  }

  void _onSearchCirclesQueryChanged(
    SearchCirclesQueryChanged event,
    Emitter<TeamsState> emit,
  ) {
    final filtered = _filterAndSortCircles(
      state.allCircles,
      event.query,
      state.selectedStatusFilter,
      state.selectedIndustryFilter,
    );
    emit(state.copyWith(searchQuery: event.query, filteredCircles: filtered));
  }

  void _onStatusCirclesFilterChanged(
    StatusCirclesFilterChanged event,
    Emitter<TeamsState> emit,
  ) {
    final filtered = _filterAndSortCircles(
      state.allCircles,
      state.searchQuery,
      event.status,
      state.selectedIndustryFilter,
    );
    emit(
      state.copyWith(
        selectedStatusFilter: event.status,
        filteredCircles: filtered,
      ),
    );
  }

  void _onIndustryCirclesFilterChanged(
    IndustryCirclesFilterChanged event,
    Emitter<TeamsState> emit,
  ) {
    final filtered = _filterAndSortCircles(
      state.allCircles,
      state.searchQuery,
      state.selectedStatusFilter,
      event.industry,
    );
    emit(
      state.copyWith(
        selectedIndustryFilter: event.industry,
        filteredCircles: filtered,
      ),
    );
  }

  List<CircleTeamModel> _filterAndSortCircles(
    List<CircleTeamModel> list,
    String query,
    String status,
    String industry,
  ) {
    var result = list;

    // 1. Text Query Filter
    if (query.trim().isNotEmpty) {
      final cleanQuery = query.toLowerCase().trim();
      result = result
          .where(
            (c) =>
                c.name.toLowerCase().contains(cleanQuery) ||
                c.category.toLowerCase().contains(cleanQuery) ||
                c.location.toLowerCase().contains(cleanQuery) ||
                c.founderName.toLowerCase().contains(cleanQuery),
          )
          .toList();
    }

    // 2. Status Filter
    if (status != 'All') {
      result = result.where((c) => c.status == status).toList();
    }

    // 3. Industry Filter
    if (industry != 'All Industries') {
      final cleanIndustry = industry.toLowerCase().trim();
      result = result
          .where((c) => c.category.toLowerCase().trim() == cleanIndustry)
          .toList();
    }

    return result;
  }
}
