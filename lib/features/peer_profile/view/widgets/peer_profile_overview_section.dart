import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_video_player.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../peers/model/peer_model.dart';
import '../../model/peer_profile_model.dart';
import '../peer_business_deals_screen.dart';
import '../peer_business_referrals_screen.dart';
import '../peer_coins_screen.dart';
import '../peer_introduced_by_screen.dart';
import '../peer_membership_screen.dart';
import '../peer_testimonials_screen.dart';

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
        _buildPerformanceMetricsCard(context),

        // 7. Industry & Specialization Tags
        if (tags.isNotEmpty) _buildTagsCard(tags),

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
                    fontWeight: FontWeight.w500,
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
                                fontWeight: FontWeight.w500,
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
                                              fontWeight: FontWeight.w500,
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
                  fontWeight: FontWeight.w500,
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
                GradientIcon(
                  icon: Icons.connect_without_contact_outlined,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  'CONTACT & CONNECTIVITY',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
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
            ),
            const Divider(height: 1, color: AppColors.border),
          ],
          if (hasEmail) ...[
            _buildContactRow(
              icon: Icons.email_outlined,
              label: 'EMAIL',
              value: peer.hideEmail ? 'Hidden by Peer 🔒' : email,
              onTap: peer.hideEmail ? null : () => _launchUri('mailto:$email'),
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
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            GradientIcon(
              icon: icon,
              size: 20,
            ),
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
                      fontWeight: FontWeight.w500,
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
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
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
              GradientIcon(
                icon: Icons.celebration_outlined,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'MILESTONES & CELEBRATIONS',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
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
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
              GradientIcon(
                icon: icon,
                size: 14,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
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
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- 5. Performance Grid (1 Row of 4 Items: Business Deals, Business Referrals, Coins, Membership) ---
  Widget _buildPerformanceMetricsCard(BuildContext context) {
    final totalRef = details.referralsGiven + details.referralsReceived;

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
                SquareRoundedGradientIcon(
                  icon: Icons.insights_rounded,
                  boxSize: 24,
                  iconSize: 13,
                  borderRadius: 6,
                ),
                SizedBox(width: 8),
                Text(
                  'PEER PERFORMANCE & CONTRIBUTION',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
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
                // Row 1: Business Deals, Business Referrals, Coins
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Business Deals',
                        value: details.dealsClosed,
                        icon: Icons.monetization_on_outlined,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PeerBusinessDealsScreen(
                                peer: peer,
                                details: details,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Business Referrals',
                        value: '$totalRef',
                        icon: Icons.campaign_outlined,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PeerBusinessReferralsScreen(
                                peer: peer,
                                details: details,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Coins',
                        value: _formatCompactNumber(details.coinsEarned),
                        icon: Icons.stars_rounded,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PeerCoinsScreen(
                                peer: peer,
                                details: details,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Row 2: Membership, Testimonials, Peers Introduced
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Membership',
                        value: peer.status.isNotEmpty ? peer.status : 'Active',
                        icon: Icons.card_membership_rounded,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PeerMembershipScreen(
                                peer: peer,
                                details: details,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Testimonials',
                        value: '${details.testimonials.length}',
                        icon: Icons.format_quote_rounded,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PeerTestimonialsScreen(
                                peer: peer,
                                testimonials: details.testimonials,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Peers Introduced',
                        value: '${details.introducedPeersCount}',
                        icon: Icons.person_add_alt_1_rounded,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PeerIntroducedByScreen(
                                peer: peer,
                                details: details,
                              ),
                            ),
                          );
                        },
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
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SquareRoundedGradientIcon(
              icon: icon,
              boxSize: 28,
              iconSize: 14,
              borderRadius: 8,
              showBorder: true,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
                  fontWeight: FontWeight.w500,
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
