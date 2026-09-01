import 'package:equatable/equatable.dart';
import '../../peers/model/peer_model.dart';
import '../../teams/model/teams_model.dart';
import '../model/circle_event_model.dart';
import '../model/circle_sub_industry_model.dart';

class CircleDetailsState extends Equatable {
  final CircleTeamModel? circle;
  final int activeSubTab;
  final bool isLoadingCircle;
  final bool isLoadingPeers;
  final bool isLoadingMorePeers;
  final bool isLoadingSubIndustries;
  final bool isLoadingEvents;
  final List<PeerModel> circlePeers;
  final int peersCurrentPage;
  final int peersLastPage;
  final int totalPeersCount;
  final CircleSubIndustriesResponse? subIndustries;
  final List<CircleEventModel> allEvents;
  final List<CircleEventModel> filteredEvents;
  final String selectedEventFilter;
  final String errorMessage;

  const CircleDetailsState({
    this.circle,
    this.activeSubTab = 0,
    this.isLoadingCircle = false,
    this.isLoadingPeers = false,
    this.isLoadingMorePeers = false,
    this.isLoadingSubIndustries = false,
    this.isLoadingEvents = false,
    this.circlePeers = const [],
    this.peersCurrentPage = 1,
    this.peersLastPage = 1,
    this.totalPeersCount = 0,
    this.subIndustries,
    this.allEvents = const [],
    this.filteredEvents = const [],
    this.selectedEventFilter = 'All',
    this.errorMessage = '',
  });

  bool get isAnyLoading =>
      isLoadingCircle || isLoadingPeers || isLoadingSubIndustries || isLoadingEvents;

  bool get hasMorePeers => peersCurrentPage < peersLastPage;

  CircleDetailsState copyWith({
    CircleTeamModel? circle,
    int? activeSubTab,
    bool? isLoadingCircle,
    bool? isLoadingPeers,
    bool? isLoadingMorePeers,
    bool? isLoadingSubIndustries,
    bool? isLoadingEvents,
    List<PeerModel>? circlePeers,
    int? peersCurrentPage,
    int? peersLastPage,
    int? totalPeersCount,
    CircleSubIndustriesResponse? subIndustries,
    List<CircleEventModel>? allEvents,
    List<CircleEventModel>? filteredEvents,
    String? selectedEventFilter,
    String? errorMessage,
  }) {
    return CircleDetailsState(
      circle: circle ?? this.circle,
      activeSubTab: activeSubTab ?? this.activeSubTab,
      isLoadingCircle: isLoadingCircle ?? this.isLoadingCircle,
      isLoadingPeers: isLoadingPeers ?? this.isLoadingPeers,
      isLoadingMorePeers: isLoadingMorePeers ?? this.isLoadingMorePeers,
      isLoadingSubIndustries: isLoadingSubIndustries ?? this.isLoadingSubIndustries,
      isLoadingEvents: isLoadingEvents ?? this.isLoadingEvents,
      circlePeers: circlePeers ?? this.circlePeers,
      peersCurrentPage: peersCurrentPage ?? this.peersCurrentPage,
      peersLastPage: peersLastPage ?? this.peersLastPage,
      totalPeersCount: totalPeersCount ?? this.totalPeersCount,
      subIndustries: subIndustries ?? this.subIndustries,
      allEvents: allEvents ?? this.allEvents,
      filteredEvents: filteredEvents ?? this.filteredEvents,
      selectedEventFilter: selectedEventFilter ?? this.selectedEventFilter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        circle,
        activeSubTab,
        isLoadingCircle,
        isLoadingPeers,
        isLoadingMorePeers,
        isLoadingSubIndustries,
        isLoadingEvents,
        circlePeers,
        peersCurrentPage,
        peersLastPage,
        totalPeersCount,
        subIndustries,
        allEvents,
        filteredEvents,
        selectedEventFilter,
        errorMessage,
      ];
}
