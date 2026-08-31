import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_video_player.dart';
import '../../../../core/widgets/expandable_text.dart';
import '../../../peers/model/peer_model.dart';
import '../../model/peer_profile_model.dart';

/// Renders the rich Overview tab for Peer Profile:
/// - Intro video player
/// - Bio with 2-line expandable Read More
/// - Direct Contact details & privacy
/// - Personal Milestones (Birthday, Anniversary, Joined Date)
/// - Comprehensive 8-Metric Grid (Deals Given/Received/Closed, Referrals Given/Received, P2P, Coins, Attendance)
/// - Industry & Specialization Tags
/// - P2P Meetings with 2-line expandable meeting notes
/// - Recent Activities timeline
class PeerProfileOverviewSection extends StatelessWidget {
  final PeerModel peer;
  final PeerProfileDetailModel details;

  const PeerProfileOverviewSection({
    super.key,
    required this.peer,
    required this.details,
  });

  String _formatCompactNumber(dynamic value) {
    if (value == null) return '0';
    int? numVal;
    if (value is int) {
      numVal = value;
    } else {
      numVal = int.tryParse(value.toString().replaceAll(',', '').trim());
    }
    if (numVal == null) return value.toString();
    if (numVal >= 1000000) {
      final double inM = numVal / 1000000.0;
      return '${inM.toStringAsFixed(inM.truncateToDouble() == inM ? 0 : 1)}M';
    } else if (numVal >= 1000) {
      final double inK = numVal / 1000.0;
      return '${inK.toStringAsFixed(inK.truncateToDouble() == inK ? 0 : 1)}k';
    }
    return '$numVal';
  }

  Future<void> _launchUri(String uriString) async {
    final uri = Uri.tryParse(uriString);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final bio = details.bio.isNotEmpty ? details.bio : (peer.bio ?? '');
    final birthday = details.birthday.isNotEmpty
        ? details.birthday
        : (peer.birthday ?? '');
    final anniversary = details.anniversary.isNotEmpty
        ? details.anniversary
        : (peer.anniversary ?? '');
    final joinedDate = details.joinedDate.isNotEmpty
        ? details.joinedDate
        : (peer.joinedDate ?? '');

    final tags = details.tags.isNotEmpty
        ? details.tags
        : (peer.tags.isNotEmpty
            ? peer.tags.split(' · ')
            : <String>[]);

    final phone = details.phone ?? peer.phone;
    final email = details.email ?? peer.email;
    final whatsapp = details.whatsapp ?? peer.whatsapp;
    final linkedin = details.linkedin ?? peer.linkedin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Intro Video Pitch (if present)
        if (peer.introVideoUrl != null &&
            peer.introVideoUrl!.trim().isNotEmpty &&
            peer.introVideoUrl!.startsWith('http'))
          _buildIntroVideoCard(context),

        // 2. About / Bio Card (with 2-lines Read More)
        if (bio.trim().isNotEmpty) _buildBioCard(bio.trim()),

        // 3. Contact & Social Links
        _buildContactCard(
          phone: phone,
          email: email,
          whatsapp: whatsapp,
          linkedin: linkedin,
        ),

        // 4. Personal Milestones (Birthday, Anniversary, Joined Date)
        if (birthday.isNotEmpty || anniversary.isNotEmpty || joinedDate.isNotEmpty)
          _buildMilestonesCard(
            birthday: birthday,
            anniversary: anniversary,
            joinedDate: joinedDate,
          ),

        // 5. 8-Metric Performance Grid
        _buildPerformanceMetricsCard(),

        // 6. Industry & Specialization Tags
        if (tags.isNotEmpty) _buildTagsCard(tags),

        // 7. P2P Meetings (with 2-lines expandable Read More)
        if (details.meetings.isNotEmpty) _buildMeetingsCard(),

        // 8. Recent Activities
        if (details.activities.isNotEmpty) _buildActivitiesCard(),

        const SizedBox(height: 20),
      ],
    );
  }

  // --- 1. Intro Video Pitch ---
  Widget _buildIntroVideoCard(BuildContext context) {
    final videoUrl = peer.introVideoUrl!.trim();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.play_circle_outline_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6),
                Text(
                  'INTRO VIDEO & PITCH',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      color: const Color(0xFF0F172A),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.smart_display_rounded,
                              size: 44,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap to play peer intro pitch',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => Dialog(
                                insetPadding: const EdgeInsets.all(16),
                                backgroundColor: Colors.black,
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      color: Colors.black87,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${peer.name} · Intro Pitch',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: AppVideoPlayer(videoUrl: videoUrl),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Center(
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                    blurRadius: 14,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Bio Card with 2-lines Read More ---
  Widget _buildBioCard(String bio) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.person_pin_outlined,
                size: 15,
                color: AppColors.primary,
              ),
              SizedBox(width: 6),
              Text(
                'ABOUT & PROFESSIONAL BIO',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ExpandableText(
            text: bio,
            maxLines: 2,
            style: TextStyle(
              color: AppColors.text.withValues(alpha: 0.9),
              fontSize: 12.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. Contact & Social Links ---
  Widget _buildContactCard({
    String? phone,
    String? email,
    String? whatsapp,
    String? linkedin,
  }) {
    final hasPhone = phone != null && phone.trim().isNotEmpty;
    final hasEmail = email != null && email.trim().isNotEmpty;
    final hasWhatsApp = whatsapp != null && whatsapp.trim().isNotEmpty;
    final hasLinkedIn = linkedin != null && linkedin.trim().isNotEmpty;

    if (!hasPhone && !hasEmail && !hasWhatsApp && !hasLinkedIn) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.connect_without_contact_outlined,
                  size: 15,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6),
                Text(
                  'CONTACT & CONNECTIVITY',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          if (hasPhone) ...[
            _buildContactRow(
              icon: Icons.phone_outlined,
              label: 'PHONE',
              value: peer.hidePhone ? 'Hidden by Peer 🔒' : phone,
              onTap: peer.hidePhone ? null : () => _launchUri('tel:$phone'),
              trailingIcon: peer.hidePhone ? null : Icons.call_outlined,
            ),
            const Divider(height: 1, color: AppColors.border),
          ],
          if (hasEmail) ...[
            _buildContactRow(
              icon: Icons.email_outlined,
              label: 'EMAIL',
              value: peer.hideEmail ? 'Hidden by Peer 🔒' : email,
              onTap: peer.hideEmail ? null : () => _launchUri('mailto:$email'),
              trailingIcon: peer.hideEmail ? null : Icons.mail_outline_rounded,
            ),
            if (hasWhatsApp || hasLinkedIn)
              const Divider(height: 1, color: AppColors.border),
          ],
          if (hasWhatsApp) ...[
            _buildContactRow(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'WHATSAPP',
              value: whatsapp,
              onTap: () {
                final cleanWa = whatsapp.replaceAll('+', '').replaceAll(' ', '');
                _launchUri('https://wa.me/$cleanWa');
              },
              trailingIcon: Icons.open_in_new_rounded,
            ),
            if (hasLinkedIn) const Divider(height: 1, color: AppColors.border),
          ],
          if (hasLinkedIn) ...[
            _buildContactRow(
              icon: Icons.public_rounded,
              label: 'LINKEDIN',
              value: linkedin,
              onTap: () => _launchUri(
                linkedin.startsWith('http')
                    ? linkedin
                    : 'https://$linkedin',
              ),
              trailingIcon: Icons.open_in_new_rounded,
            ),
          ],
        ],
      ),
    );
    
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
    IconData? trailingIcon,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: onTap != null
                          ? const Color(0xFF1E6091)
                          : AppColors.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailingIcon != null)
              Icon(trailingIcon, color: const Color(0xFF1E6091), size: 16),
          ],
        ),
      ),
    );
  }

  // --- 4. Personal Milestones (Birthday, Anniversary, Joined Date) ---
  Widget _buildMilestonesCard({
    required String birthday,
    required String anniversary,
    required String joinedDate,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.celebration_outlined,
                size: 15,
                color: Color(0xFFD97706),
              ),
              SizedBox(width: 6),
              Text(
                'MILESTONES & CELEBRATIONS',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (birthday.isNotEmpty)
                Expanded(
                  child: _buildMilestoneTile(
                    icon: Icons.cake_outlined,
                    iconColor: const Color(0xFFE11D48),
                    bg: const Color(0xFFFFF1F2),
                    title: 'Birthday',
                    value: birthday,
                  ),
                ),
              if (birthday.isNotEmpty &&
                  (anniversary.isNotEmpty || joinedDate.isNotEmpty))
                const SizedBox(width: 8),
              if (anniversary.isNotEmpty)
                Expanded(
                  child: _buildMilestoneTile(
                    icon: Icons.favorite_outline_rounded,
                    iconColor: const Color(0xFF9333EA),
                    bg: const Color(0xFFFAF5FF),
                    title: 'Anniversary',
                    value: anniversary,
                  ),
                ),
              if (anniversary.isNotEmpty && joinedDate.isNotEmpty)
                const SizedBox(width: 8),
              if (joinedDate.isNotEmpty)
                Expanded(
                  child: _buildMilestoneTile(
                    icon: Icons.verified_user_outlined,
                    iconColor: const Color(0xFF0284C7),
                    bg: const Color(0xFFF0F9FF),
                    title: 'Joined Date',
                    value: joinedDate,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneTile({
    required IconData icon,
    required Color iconColor,
    required Color bg,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- 5. 8-Metric Performance Grid ---
  Widget _buildPerformanceMetricsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6),
                Text(
                  'PEER PERFORMANCE & CONTRIBUTION',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Row 1: Deals Closed & Deals Given
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Deals Closed',
                        value: details.dealsClosed,
                        valueColor: const Color(0xFF16A34A),
                        icon: Icons.monetization_on_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Deals Given',
                        value: details.dealsGiven,
                        valueColor: AppColors.primary,
                        icon: Icons.outbox_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Row 2: Referrals Given & Referrals Received
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Referrals Given',
                        value: '${details.referralsGiven}',
                        valueColor: const Color(0xFF2563EB),
                        icon: Icons.campaign_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Ref. Received',
                        value: '${details.referralsReceived}',
                        valueColor: const Color(0xFF0284C7),
                        icon: Icons.inbox_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Row 3: P2P Sessions & Coins Earned
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        label: 'P2P Meetings',
                        value: '${details.p2pSessions}',
                        valueColor: const Color(0xFFD97706),
                        icon: Icons.swap_horiz_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Coins Earned',
                        value: _formatCompactNumber(details.coinsEarned),
                        valueColor: const Color(0xFFCA8A04),
                        icon: Icons.stars_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Row 4: Attendance & Deals Received
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Attendance',
                        value: details.attendanceRate,
                        valueColor: const Color(0xFF16A34A),
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Deals Received',
                        value: details.dealsReceived,
                        valueColor: const Color(0xFF0D9488),
                        icon: Icons.handshake_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- 6. Industry & Specialization Tags ---
  Widget _buildTagsCard(List<String> tags) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: 15,
                color: AppColors.primary,
              ),
              SizedBox(width: 6),
              Text(
                'INDUSTRY & SPECIALIZATION TAGS',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((tag) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- 7. P2P Meetings (with 2-lines Read More) ---
  Widget _buildMeetingsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'P2P MEETINGS & DISCUSSIONS',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${details.meetings.length} Recorded',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ...details.meetings.asMap().entries.map((entry) {
            final idx = entry.key;
            final meeting = entry.value;
            final isLast = idx == details.meetings.length - 1;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Box
                      Container(
                        width: 40,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              meeting.day,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              meeting.month.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Details with Expandable Description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ExpandableText(
                              text: meeting.title,
                              maxLines: 2,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                            if (meeting.timeLocation.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      meeting.timeLocation,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          meeting.status,
                          style: const TextStyle(
                            color: Color(0xFF16A34A),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(height: 1, color: AppColors.border),
              ],
            );
          }),
        ],
      ),
    );
  }

  // --- 8. Recent Activities ---
  Widget _buildActivitiesCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.secondaryBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'RECENT ACTIVITIES',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${details.activities.length} Events',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ...details.activities.asMap().entries.map((entry) {
            final idx = entry.key;
            final activity = entry.value;
            final isLast = idx == details.activities.length - 1;

            IconData icon = Icons.star_rounded;
            Color iconColor = const Color(0xFFEAB308);
            Color bg = const Color(0xFFFEFCE8);

            if (activity.iconType == 'speaker' ||
                activity.title.toLowerCase().contains('referral')) {
              icon = Icons.campaign_rounded;
              iconColor = const Color(0xFF2563EB);
              bg = const Color(0xFFEFF6FF);
            } else if (activity.iconType == 'arrows' ||
                activity.title.toLowerCase().contains('p2p')) {
              icon = Icons.swap_horiz_rounded;
              iconColor = const Color(0xFFD97706);
              bg = const Color(0xFFFFFBEB);
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: bg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: iconColor, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.title,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (activity.subtitle.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              ExpandableText(
                                text: activity.subtitle,
                                maxLines: 2,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        activity.time,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(height: 1, color: AppColors.border),
              ],
            );
          }),
        ],
      ),
    );
  }
}
