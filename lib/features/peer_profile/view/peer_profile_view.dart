import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../peers/model/peer_model.dart';
import '../bloc/peer_profile_bloc.dart';
import '../bloc/peer_profile_event.dart';
import '../bloc/peer_profile_state.dart';
import '../model/peer_profile_model.dart';
import '../presenter/peer_profile_presenter.dart';

/// Screen component rendering a comprehensive Peer Profile view.
class PeerProfileView extends StatefulWidget {
  final PeerModel peer;

  const PeerProfileView({super.key, required this.peer});

  @override
  State<PeerProfileView> createState() => _PeerProfileViewState();
}

class _PeerProfileViewState extends State<PeerProfileView>
    implements PeerProfileViewContract {
  late final PeerProfileBloc _bloc;
  late final PeerProfilePresenter _presenter;

  int _activeSubTab = 0;
  bool _isLoading = false;
  PeerProfileDetailModel? _details;

  @override
  void initState() {
    super.initState();
    _bloc = PeerProfileBloc();
    _presenter = PeerProfilePresenter(view: this, bloc: _bloc);
    _presenter.load(widget.peer);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // --- PeerProfileViewContract Implementations ---

  @override
  void onProfileLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void onProfileLoaded() {
    setState(() {
      _isLoading = false;
      _details = _bloc.state.details;
    });
  }

  @override
  void onProfileError(String error) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void onSubTabChanged(int index) {
    if (_activeSubTab != index) {
      setState(() {
        _activeSubTab = index;
      });
    }
  }

  // --- UI Widget Builders ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F2541),
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
        ),
      ),
      title: const Text(
        'Peer Profile',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildHeroCardHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEDEFF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Dark Blue Header Block
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF0F2541),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Initials Avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.peer.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Name & Company
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.peer.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.peer.company,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Badges row
                Row(
                  children: [
                    // Impact badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB48A3A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.peer.impactCount} Lives Impacted',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.peer.status,
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Direct',
                        style: const TextStyle(
                          color: Colors.white,
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
          // White Details List Section
          _buildDetailRow(
            icon: Icons.corporate_fare_outlined,
            label: 'CIRCLE',
            value: widget.peer.circle,
          ),
          const Divider(height: 1, color: Color(0xFFEDEFF3)),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: 'CITY',
            value: widget.peer.location,
          ),
          const Divider(height: 1, color: Color(0xFFEDEFF3)),
          _buildDetailRow(
            icon: Icons.local_offer_outlined,
            label: 'INDUSTRY',
            value: widget.peer.tags,
          ),
          const Divider(height: 1, color: Color(0xFFEDEFF3)),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'MEMBER SINCE',
            value: 'Jan 2024',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF5B718F), size: 18),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabSegmentBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildSegmentTab(0, 'Overview'),
          _buildSegmentTab(1, 'Activity'),
          _buildSegmentTab(2, 'Testimonials (2)'),
        ],
      ),
    );
  }

  Widget _buildSegmentTab(int index, String label) {
    final isSelected = _activeSubTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => _presenter.changeSubTab(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF8B9CB4),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  // --- Subtab 0: Overview Builders ---

  Widget _buildStatsCard() {
    if (_details == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F6F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(19),
                topRight: Radius.circular(19),
              ),
            ),
            child: Text(
              'PERFORMANCE STATS',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Rows
          _buildStatRow(
            icon: Icons.card_membership_outlined,
            title: 'Deals Closed',
            value: _details!.dealsClosed,
            valueColor: const Color(0xFF2E7D32),
          ),
          const Divider(height: 1, color: Color(0xFFEDEFF3)),
          _buildStatRow(
            icon: Icons.campaign_outlined,
            title: 'Referrals Given',
            value: _details!.referralsGiven.toString(),
            valueColor: const Color(0xFF1565C0),
          ),
          const Divider(height: 1, color: Color(0xFFEDEFF3)),
          _buildStatRow(
            icon: Icons.swap_horiz_rounded,
            title: 'P2P Sessions',
            value: _details!.p2pSessions.toString(),
            valueColor: const Color(0xFFD84315),
          ),
          const Divider(height: 1, color: Color(0xFFEDEFF3)),
          _buildStatRow(
            icon: Icons.monetization_on_outlined,
            title: 'Coins Earned',
            value: _details!.coinsEarned.toString(),
            valueColor: const Color(0xFFC28500),
          ),
          const Divider(height: 1, color: Color(0xFFEDEFF3)),
          _buildStatRow(
            icon: Icons.calendar_today_outlined,
            title: 'Attendance Rate',
            value: _details!.attendanceRate,
            valueColor: const Color(0xFF2E7D32),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo.shade300, size: 20),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationsCard() {
    if (_details == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F6F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(19),
                topRight: Radius.circular(19),
              ),
            ),
            child: Text(
              'CELEBRATIONS',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Horizontal Row containing Birthday & Anniversary panels
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Birthday Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFEBD5)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cake_outlined,
                          color: Color(0xFFD97706),
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Birthday',
                          style: TextStyle(
                            color: Color(0xFFB45309),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _details!.birthday,
                          style: const TextStyle(
                            color: Color(0xFF78350F),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Anniversary Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDCFCE7)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.album_outlined, // Ring-like representation
                          color: Color(0xFF15803D),
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Anniversary',
                          style: TextStyle(
                            color: Color(0xFF15803D),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _details!.anniversary,
                          style: const TextStyle(
                            color: Color(0xFF14532D),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingsCard() {
    if (_details == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F6F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(19),
                topRight: Radius.circular(19),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CIRCLE MEETINGS',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.peer.circle,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Meetings list
          ..._details!.meetings.map(
            (m) => Column(
              children: [
                _buildMeetingRow(m),
                if (m != _details!.meetings.last)
                  const Divider(height: 1, color: Color(0xFFEDEFF3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingRow(PeerMeetingModel meeting) {
    Color statusBg = Colors.grey.shade100;
    Color statusText = Colors.grey.shade600;

    if (meeting.status == 'Confirmed') {
      statusBg = const Color(0xFFE8F5E9);
      statusText = const Color(0xFF2E7D32);
    } else if (meeting.status == 'Open') {
      statusBg = const Color(0xFFE8F0FE);
      statusText = const Color(0xFF1565C0);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Date block badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0F2541),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  meeting.day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  meeting.month,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Meeting details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meeting.timeLocation,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              meeting.status,
              style: TextStyle(
                color: statusText,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Subtab 1: Activity Builder ---

  Widget _buildActivityTab() {
    if (_details == null || _details!.activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(
          child: Text(
            'No recent activity.',
            style: TextStyle(color: Color(0xFF8B9CB4), fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F6F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(19),
                topRight: Radius.circular(19),
              ),
            ),
            child: Text(
              'RECENT ACTIVITY',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Activity list items
          ..._details!.activities.map((act) => _buildActivityRow(act)),
        ],
      ),
    );
  }

  Widget _buildActivityRow(PeerActivityModel activity) {
    IconData iconData = Icons.notifications_none;
    switch (activity.iconType) {
      case 'arrows':
        iconData = Icons.swap_horiz_rounded;
        break;
      case 'speaker':
        iconData = Icons.campaign_outlined;
        break;
      case 'star':
        iconData = Icons.star_rounded;
        break;
      case 'trophy':
        iconData = Icons.emoji_events_outlined;
        break;
      case 'target':
        iconData = Icons.track_changes_outlined;
        break;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Box
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(iconData, color: const Color(0xFF1565C0), size: 20),
              ),
              const SizedBox(width: 16),
              // Titles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activity.subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Time
              Text(
                activity.time,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (activity != _details!.activities.last)
          const Divider(height: 1, color: Color(0xFFEDEFF3)),
      ],
    );
  }

  // --- Subtab 2: Testimonials Builder ---

  Widget _buildTestimonialsTab() {
    if (_details == null || _details!.testimonials.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(
          child: Text(
            'No testimonials submitted.',
            style: TextStyle(color: Color(0xFF8B9CB4), fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: _details!.testimonials
          .map((test) => _buildTestimonialCard(test))
          .toList(),
    );
  }

  Widget _buildTestimonialCard(PeerTestimonialModel testimonial) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Initials Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF0F2541),
                  child: Text(
                    testimonial.authorInitials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testimonial.authorName,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        testimonial.subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rating Stars
                Row(
                  children: List.generate(
                    testimonial.rating,
                    (_) => const Icon(
                      Icons.star_rate_rounded,
                      color: Color(0xFFFBC02D),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEDEFF3)),
          // Body Content Block
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '"${testimonial.content}"',
              style: TextStyle(
                color: AppColors.text.withOpacity(0.85),
                fontSize: 13,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PeerProfileBloc>.value(
      value: _bloc,
      child: BlocListener<PeerProfileBloc, PeerProfileState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF9FAFC),
          appBar: _buildAppBar(),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeroCardHeader(),
                      _buildSubTabSegmentBar(),
                      if (_activeSubTab == 0) ...[
                        _buildStatsCard(),
                        _buildCelebrationsCard(),
                        _buildMeetingsCard(),
                      ] else if (_activeSubTab == 1)
                        _buildActivityTab()
                      else
                        _buildTestimonialsTab(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
