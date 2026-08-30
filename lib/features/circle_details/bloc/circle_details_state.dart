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
  final bool isLoadingSubIndustries;
  final bool isLoadingEvents;
  final List<PeerModel> circlePeers;
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
    this.isLoadingSubIndustries = false,
    this.isLoadingEvents = false,
    this.circlePeers = const [],
    this.subIndustries,
    this.allEvents = const [],
    this.filteredEvents = const [],
    this.selectedEventFilter = 'All',
    this.errorMessage = '',
  });

  bool get isAnyLoading =>
      isLoadingCircle || isLoadingPeers || isLoadingSubIndustries || isLoadingEvents;

  CircleDetailsState copyWith({
    CircleTeamModel? circle,
    int? activeSubTab,
    bool? isLoadingCircle,
    bool? isLoadingPeers,
    bool? isLoadingSubIndustries,
    bool? isLoadingEvents,
    List<PeerModel>? circlePeers,
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
      isLoadingSubIndustries: isLoadingSubIndustries ?? this.isLoadingSubIndustries,
      isLoadingEvents: isLoadingEvents ?? this.isLoadingEvents,
      circlePeers: circlePeers ?? this.circlePeers,
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
        isLoadingSubIndustries,
        isLoadingEvents,
        circlePeers,
        subIndustries,
        allEvents,
        filteredEvents,
        selectedEventFilter,
        errorMessage,
      ];
}
