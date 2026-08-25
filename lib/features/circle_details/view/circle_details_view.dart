import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/repositories/peers_repository.dart';
import '../../../data/repositories/teams_repository.dart';
import '../../peers/model/peer_model.dart';
import '../../teams/model/teams_model.dart';
import '../model/circle_event_model.dart';
import '../model/circle_sub_industry_model.dart';
import 'widgets/circle_details_hero_card.dart';
import 'widgets/circle_details_tab_selector.dart';
import 'widgets/circle_events_section.dart';
import 'widgets/circle_leadership_card.dart';
import 'widgets/circle_overview_section.dart';
import 'widgets/circle_peers_section.dart';
import 'widgets/circle_sub_industries_section.dart';

/// Screen displaying comprehensive details about a specific Circle.
class CircleDetailsView extends StatefulWidget {
  final CircleTeamModel circle;

  const CircleDetailsView({super.key, required this.circle});

  @override
  State<CircleDetailsView> createState() => _CircleDetailsViewState();
}

class _CircleDetailsViewState extends State<CircleDetailsView> {
  int _activeSubTab = 0; // 0: Overview, 1: Peers, 2: Sub-Industries, 3: Events
  String _selectedEventFilter = 'All';

  List<PeerModel> _circlePeers = [];
  bool _isLoadingPeers = false;

  CircleSubIndustriesResponse? _subIndustries;
  bool _isLoadingSubIndustries = false;

  List<CircleEventModel> _circleEvents = [];
  bool _isLoadingEvents = false;

  @override
  void initState() {
    super.initState();
    _loadCirclePeers();
    _loadSubIndustries();
    _loadCircleEvents();
  }

  Future<void> _loadCirclePeers() async {
    setState(() => _isLoadingPeers = true);
    try {
      final res =
          await PeersRepositoryImpl().getPeers(circleId: widget.circle.id);
      if (mounted) {
        setState(() {
          _circlePeers = res.data ?? [];
          _isLoadingPeers = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPeers = false);
    }
  }

  Future<void> _loadSubIndustries() async {
    setState(() => _isLoadingSubIndustries = true);
    try {
      final res =
          await TeamsRepositoryImpl().getSubIndustries(widget.circle.id);
      if (mounted) {
        setState(() {
          _subIndustries = res.data;
          _isLoadingSubIndustries = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingSubIndustries = false);
    }
  }

  Future<void> _loadCircleEvents() async {
    setState(() => _isLoadingEvents = true);
    try {
      final res = await TeamsRepositoryImpl().getCircleEvents(
        widget.circle.id,
        filter: _selectedEventFilter,
      );
      if (mounted) {
        setState(() {
          _circleEvents = res.data ?? [];
          _isLoadingEvents = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingEvents = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Circle Details',
        subtitle: widget.circle.name,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleDetailsHeroCard(circle: widget.circle),
            CircleLeadershipCard(circle: widget.circle),
            CircleDetailsTabSelector(
              activeTab: _activeSubTab,
              peersCount: _circlePeers.length,
              eventsCount: _circleEvents.length,
              onTabChanged: (idx) => setState(() => _activeSubTab = idx),
            ),
            if (_activeSubTab == 0)
              CircleOverviewSection(circle: widget.circle),
            if (_activeSubTab == 1)
              CirclePeersSection(
                peers: _circlePeers,
                isLoading: _isLoadingPeers,
              ),
            if (_activeSubTab == 2)
              CircleSubIndustriesSection(
                subIndustries: _subIndustries,
                isLoading: _isLoadingSubIndustries,
                categoryName: widget.circle.category,
              ),
            if (_activeSubTab == 3)
              CircleEventsSection(
                events: _circleEvents,
                isLoading: _isLoadingEvents,
                selectedFilter: _selectedEventFilter,
                onFilterChanged: (filter) {
                  setState(() => _selectedEventFilter = filter);
                  _loadCircleEvents();
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
