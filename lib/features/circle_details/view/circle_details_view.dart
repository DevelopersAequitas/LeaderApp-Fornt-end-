import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../teams/model/teams_model.dart';
import '../../../core/widgets/widgets.dart';

/// Screen displaying comprehensive details about a specific Circle.
class CircleDetailsView extends StatefulWidget {
  final CircleTeamModel circle;

  const CircleDetailsView({super.key, required this.circle});

  @override
  State<CircleDetailsView> createState() => _CircleDetailsViewState();
}

class _CircleDetailsViewState extends State<CircleDetailsView> {
  int _activeSubTab =
      0; // 0: Overview, 1: Peers (8), 2: Sub-Industries, 3: Events (6)
  String _selectedEventFilter = 'All';

  // Mock peers data in circle
  final List<Map<String, String>> _mockPeers = const [
    {
      'name': 'Priya Sharma',
      'initials': 'PS',
      'company': 'TechVentures',
      'role': 'AI Specialist',
    },
    {
      'name': 'James O\'Brien',
      'initials': 'JO',
      'company': 'FinTech Pvt',
      'role': 'SaaS Developer',
    },
    {
      'name': 'Ananya Patel',
      'initials': 'AP',
      'company': 'HealthFirst',
      'role': 'Web Engineer',
    },
    {
      'name': 'Marcus Lee',
      'initials': 'ML',
      'company': 'DevStudio',
      'role': 'DevOps Lead',
    },
    {
      'name': 'Fatima Al-Rashid',
      'initials': 'FA',
      'company': 'LegalEdge',
      'role': 'Advisor',
    },
    {
      'name': 'Sanjana Rao',
      'initials': 'SR',
      'company': 'CreativeHub',
      'role': 'UI Designer',
    },
    {
      'name': 'David Kim',
      'initials': 'DK',
      'company': 'ConsultPro',
      'role': 'Architect',
    },
    {
      'name': 'Rajan Das',
      'initials': 'RD',
      'company': 'MedCare',
      'role': 'Fullstack Dev',
    },
  ];

  // Mock events data in circle
  final List<Map<String, String>> _mockEvents = const [
    {
      'title': 'Tech Growth Summit 2026',
      'date': 'Aug 1, 2026',
      'time': '10:00 AM',
      'location': 'In-Person',
      'filter': 'Upcoming',
    },
    {
      'title': 'AI & ML Peer Workshop',
      'date': 'Jul 20, 2026',
      'time': '3:00 PM',
      'location': 'Online',
      'filter': 'Completed',
    },
    {
      'title': 'B2B Deal Day',
      'date': 'Jul 5, 2026',
      'time': '9:00 AM',
      'location': 'In-Person',
      'filter': 'Completed',
    },
    {
      'title': 'Startup Pitch Night',
      'date': 'Aug 14, 2026',
      'time': '2:00 PM',
      'location': 'Hybrid',
      'filter': 'Upcoming',
    },
    {
      'title': 'Monthly Circle Assembly',
      'date': 'Aug 24, 2026',
      'time': '6:30 PM',
      'location': 'In-Person',
      'filter': 'Upcoming',
    },
    {
      'title': 'Sub-Industry Roundtable',
      'date': 'Aug 29, 2026',
      'time': '5:00 PM',
      'location': 'Online',
      'filter': 'Upcoming',
    },
  ];



  Widget _buildHeroCard() {
    final circle = widget.circle;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.chartPrimary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      circle.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${circle.category}, IT & Digital Services · ${circle.location}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successLightBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              color: AppColors.successDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Est. Jan 2023',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Circular Health Score Widget
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: CircularProgressIndicator(
                          value: circle.healthPercentage / 100,
                          strokeWidth: 5,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          color: AppColors.healthGreen,
                        ),
                      ),
                      Text(
                        '${circle.healthPercentage}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'HEALTH',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 4 Grid metrics cards
          Row(
            children: [
              _buildHeroMetricCard('${circle.peersCount}', 'PEERS'),
              _buildHeroMetricCard(circle.revenue, 'REVENUE'),
              _buildHeroMetricCard('₹1.34Cr', 'DEALS'),
              _buildHeroMetricCard('214 Lives', 'IMPACT'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetricCard(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleLeadership() {
    final circle = widget.circle;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'CIRCLE LEADERSHIP',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLeaderCard('FOUNDER 🔒', circle.founderName),
              const SizedBox(width: 8),
              _buildLeaderCard('DIRECTOR', circle.directorName),
              const SizedBox(width: 8),
              _buildLeaderCard('CHAIR', circle.chairName),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderCard(String label, String name) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.leaderCardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    final tabs = const [
      'Overview',
      'Peers (8)',
      'Sub-Industries',
      'Events (6)',
    ];
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(tabs.length, (idx) {
          final isSelected = _activeSubTab == idx;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeSubTab = idx),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.chartPrimary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tabs[idx],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final circle = widget.circle;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Health Score',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _buildHealthProgressBar(
            'Overall',
            circle.healthPercentage,
            AppColors.chartPrimary,
          ),
          const SizedBox(height: 12),
          _buildHealthProgressBar('Attendance', 83, AppColors.successDark),
          const SizedBox(height: 12),
          _buildHealthProgressBar('Engagement', 75, AppColors.engagementGold),
          const SizedBox(height: 28),
          const Text(
            'Sub-Industries',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Open: 4 · Active: 3',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _SubIndustryChip(label: 'Web & App Development'),
              _SubIndustryChip(label: 'AI & Machine Learning'),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHealthProgressBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '$value%',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            color: color,
            backgroundColor: AppColors.progressBg,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildPeersTab() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _mockPeers.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, idx) {
        final peer = _mockPeers[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.chartPrimary,
              child: Text(
                peer['initials']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            title: Text(
              peer['name']!,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            subtitle: Text('${peer['company']} · ${peer['role']}'),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubIndustriesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Active Sub-Industries',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _buildSubIndustryItem(
            'Web & App Development',
            '2 peers',
            'Active',
            true,
          ),
          _buildSubIndustryItem(
            'AI & Machine Learning',
            '2 peers',
            'Active',
            true,
          ),
          _buildSubIndustryItem('SaaS & Platforms', '2 peers', 'Active', true),
          const SizedBox(height: 24),
          const Text(
            'Open Sub-Industries',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Not yet filled from Technology, IT & Digital Services',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _buildSubIndustryItem('Cloud Services', null, 'Open', false),
          _buildSubIndustryItem('Cybersecurity', null, 'Open', false),
          _buildSubIndustryItem('Data Analytics', null, 'Open', false),
          _buildSubIndustryItem('IoT Solutions', null, 'Open', false),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSubIndustryItem(
    String name,
    String? count,
    String status,
    bool isActive,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (count != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successLightBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count,
                style: const TextStyle(
                  color: AppColors.successDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.successLightBg
                  : AppColors.leaderCardBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isActive
                    ? AppColors.successDark
                    : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    final filters = const ['All', 'Today', 'Upcoming', 'Completed'];
    final filteredEvents = _mockEvents.where((ev) {
      if (_selectedEventFilter == 'All') return true;
      return ev['filter'] == _selectedEventFilter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Horizontal Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            children: filters.map((filter) {
              final isSelected = _selectedEventFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedEventFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.chartPrimary : AppColors.secondaryBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // Events List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredEvents.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, idx) {
            final ev = filteredEvents[idx];
            
            Color bg = AppColors.infoBg;
            Color fg = AppColors.info;
            IconData icon = Icons.mic_none_rounded;
            if (ev['title']!.contains('Summit') || ev['title']!.contains('Assembly')) {
              bg = AppColors.warningLightBg;
              fg = AppColors.warningDark;
              icon = Icons.adjust_rounded;
            } else if (ev['title']!.contains('Pitch')) {
              bg = AppColors.successLightBg;
              fg = AppColors.successDark;
              icon = Icons.adjust_rounded;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: bg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        color: fg,
                        size: 18,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ev['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${ev['date']} · ${ev['time']} · ${ev['location']}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey,
                      size: 14,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
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
            _buildHeroCard(),
            _buildCircleLeadership(),
            _buildTabSelector(),
            if (_activeSubTab == 0) _buildOverviewTab(),
            if (_activeSubTab == 1) _buildPeersTab(),
            if (_activeSubTab == 2) _buildSubIndustriesTab(),
            if (_activeSubTab == 3) _buildEventsTab(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SubIndustryChip extends StatelessWidget {
  final String label;

  const _SubIndustryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.leaderCardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
