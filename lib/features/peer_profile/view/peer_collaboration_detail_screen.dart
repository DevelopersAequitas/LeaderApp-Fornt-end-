import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../peers/model/peer_model.dart';
import '../model/peer_profile_model.dart';

/// Dedicated standalone screen displaying comprehensive details for a Peer Collaboration Ask,
/// including all published metadata, objectives, and all Responded Peers.
class PeerCollaborationDetailScreen extends StatelessWidget {
  final PeerCollaborationItemModel ask;
  final PeerModel? peer;

  const PeerCollaborationDetailScreen({
    super.key,
    required this.ask,
    this.peer,
  });

  static void open(
    BuildContext context, {
    required PeerCollaborationItemModel ask,
    PeerModel? peer,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PeerCollaborationDetailScreen(
          ask: ask,
          peer: peer,
        ),
      ),
    );
  }

  // --- Helper Date Formatting ---
  static String _formatDateTime(String rawDate) {
    if (rawDate.isEmpty) return '';
    try {
      final dt = DateTime.tryParse(rawDate);
      if (dt != null) {
        final local = dt.toLocal();
        const monthNames = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
        final minuteStr = local.minute.toString().padLeft(2, '0');
        final period = local.hour >= 12 ? 'PM' : 'AM';
        return '${local.day} ${monthNames[local.month - 1]} ${local.year}, $hour12:$minuteStr $period';
      }
      return rawDate.split('T').first;
    } catch (_) {
      return rawDate;
    }
  }

  // --- Status Color Resolvers ---
  static Color _getStatusBg(String status) {
    final s = status.toLowerCase();
    if (s.contains('open') || s.contains('active')) {
      return const Color(0xFFDCFCE7);
    }
    if (s.contains('progress') || s.contains('discussion') || s.contains('pending')) {
      return const Color(0xFFFEF3C7);
    }
    if (s.contains('fulfill') || s.contains('completed') || s.contains('accept')) {
      return const Color(0xFFF3E8FF);
    }
    if (s.contains('closed') || s.contains('clos') || s.contains('reject') || s.contains('declin')) {
      return const Color(0xFFF1F5F9);
    }
    return const Color(0xFFEFF6FF);
  }

  static Color _getStatusTextColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('open') || s.contains('active')) {
      return const Color(0xFF15803D);
    }
    if (s.contains('progress') || s.contains('discussion') || s.contains('pending')) {
      return const Color(0xFFB45309);
    }
    if (s.contains('fulfill') || s.contains('completed') || s.contains('accept')) {
      return const Color(0xFF7E22CE);
    }
    if (s.contains('closed') || s.contains('clos') || s.contains('reject') || s.contains('declin')) {
      return const Color(0xFF64748B);
    }
    return AppColors.primary;
  }

  void _navigateToPeerProfile(
    BuildContext context, {
    required String peerId,
    required String name,
    String company = '',
    String designation = '',
    String avatarUrl = '',
  }) {
    if (peerId.isEmpty) return;

    final targetPeer = PeerModel(
      id: peerId,
      name: name,
      initials: name.isNotEmpty ? name[0].toUpperCase() : 'P',
      company: company,
      designation: designation.isNotEmpty ? designation : null,
      avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
      circle: '',
      location: '',
      tags: '',
      impactCount: 0,
      dealsFormatted: '₹0',
      coins: 0,
      attendance: '',
      status: 'Active',
    );

    Navigator.of(context).pushNamed(
      AppRoutes.peerProfile,
      arguments: targetPeer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Collaboration Details',
        subtitle: ask.categoryName.isNotEmpty ? ask.categoryName : 'Executive Ask',
        showBackButton: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(),
            const SizedBox(height: 16),
            _buildPublisherCard(context),
            const SizedBox(height: 16),
            _buildDescriptionCard(),
            if (ask.acceptedPeer != null) ...[
              const SizedBox(height: 16),
              _buildAcceptedPeerCard(context),
            ],
            const SizedBox(height: 24),
            _buildResponsesSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- Section 1: Overview & Metrics Card ---
  Widget _buildOverviewCard() {
    final formattedDate = _formatDateTime(ask.createdAt);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Flow Tag & Status Pill
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.handshake_outlined,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ask.flowName.isNotEmpty ? ask.flowName : 'Collaboration',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusBg(ask.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ask.statusLabel,
                  style: TextStyle(
                    color: _getStatusTextColor(ask.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Ask Title / Objective
          Text(
            ask.title.isNotEmpty ? ask.title : 'Collaboration Initiative',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppColors.text,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          // Category Badge
          if (ask.categoryName.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ask.categoryName,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          if (formattedDate.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Published on $formattedDate',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],

          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Metrics Row
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Responses',
                  value: '${ask.responsesCount}',
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: AppColors.primary,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AppColors.border,
              ),
              Expanded(
                child: _buildMetricTile(
                  label: 'Peer Matches',
                  value: '${ask.matchesCount}',
                  icon: Icons.groups_outlined,
                  iconColor: const Color(0xFF0284C7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Section 2: Publisher Card ---
  Widget _buildPublisherCard(BuildContext context) {
    final authorName = ask.authorDisplayName.isNotEmpty
        ? ask.authorDisplayName
        : (ask.authorName.isNotEmpty
            ? ask.authorName
            : (peer?.name.isNotEmpty == true ? peer!.name : 'Peer Author'));

    final authorCompany = ask.authorCompany.isNotEmpty
        ? ask.authorCompany
        : (peer?.company.isNotEmpty == true ? peer!.company : '');

    final authorAvatar = ask.authorAvatarUrl.isNotEmpty
        ? ask.authorAvatarUrl
        : (peer?.avatarUrl ?? '');

    final hasProfile = ask.authorId.isNotEmpty || peer != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PUBLISHED BY',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: hasProfile
                ? () {
                    _navigateToPeerProfile(
                      context,
                      peerId: ask.authorId.isNotEmpty ? ask.authorId : (peer?.id ?? ''),
                      name: authorName,
                      company: authorCompany,
                      avatarUrl: authorAvatar,
                    );
                  }
                : null,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                InitialsAvatar(
                  name: authorName,
                  imageUrl: authorAvatar.isNotEmpty ? authorAvatar : null,
                  radius: 22,
                  fontSize: 14,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (authorCompany.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          authorCompany,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasProfile)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Section 3: Description & Requirements Card ---
  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Description & Requirements',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              ask.description.isNotEmpty
                  ? ask.description
                  : 'No detailed description provided for this collaboration ask.',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: AppColors.text,
                height: 1.5,
              ),
            ),
          ),

          // What I Bring & What I Need (if present)
          if (ask.bring.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildRequirementRow(
              title: 'What I Bring',
              value: ask.bring,
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xFF10B981),
            ),
          ],
          if (ask.need.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildRequirementRow(
              title: 'What I Need',
              value: ask.need,
              icon: Icons.search_rounded,
              color: const Color(0xFF6366F1),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequirementRow({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Section 4: Accepted Peer Card (if any) ---
  Widget _buildAcceptedPeerCard(BuildContext context) {
    final accepted = ask.acceptedPeer;
    if (accepted == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 15,
                color: Color(0xFF16A34A),
              ),
              const SizedBox(width: 6),
              const Text(
                'ACCEPTED COLLABORATOR',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF16A34A),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Accepted',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: accepted.id.isNotEmpty
                ? () {
                    _navigateToPeerProfile(
                      context,
                      peerId: accepted.id,
                      name: accepted.effectiveName,
                      company: accepted.companyName,
                      designation: accepted.designation,
                      avatarUrl: accepted.avatarUrl,
                    );
                  }
                : null,
            child: Row(
              children: [
                InitialsAvatar(
                  name: accepted.effectiveName,
                  imageUrl: accepted.avatarUrl.isNotEmpty ? accepted.avatarUrl : null,
                  radius: 20,
                  fontSize: 13,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        accepted.effectiveName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),
                      if (accepted.companyName.isNotEmpty || accepted.designation.isNotEmpty)
                        Text(
                          [
                            if (accepted.companyName.isNotEmpty) accepted.companyName,
                            if (accepted.designation.isNotEmpty) accepted.designation,
                          ].join(' · '),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Section 5: Responded Peers Section ---
  Widget _buildResponsesSection(BuildContext context) {
    final responses = ask.responses ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          children: [
            const Icon(
              Icons.question_answer_outlined,
              size: 18,
              color: AppColors.text,
            ),
            const SizedBox(width: 8),
            const Text(
              'Responded Peers',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${responses.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (responses.isEmpty)
          _buildEmptyResponsesCard()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: responses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (ctx, index) {
              return _buildResponseCard(context, responses[index]);
            },
          ),
      ],
    );
  }

  // --- Empty State for Responses ---
  Widget _buildEmptyResponsesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 22,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No Responses Yet',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'No peers have responded to this collaboration ask yet.',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- Card for Individual Responded Peer ---
  Widget _buildResponseCard(BuildContext context, PeerCollaborationResponseModel response) {
    final responder = response.responder;
    final responderName = responder?.effectiveName.isNotEmpty == true
        ? responder!.effectiveName
        : 'Peer Responder';

    final responderCompany = responder?.companyName ?? '';
    final responderDesignation = responder?.designation ?? '';
    final responderAvatar = responder?.avatarUrl ?? '';
    final hasPeerProfile = responder != null && responder.id.isNotEmpty;

    final respondedTimeStr = response.respondedAt.isNotEmpty
        ? _formatDateTime(response.respondedAt)
        : (response.createdAt.isNotEmpty ? _formatDateTime(response.createdAt) : '');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Responder Avatar + Name + Company + Status Pill
          InkWell(
            onTap: hasPeerProfile
                ? () {
                    _navigateToPeerProfile(
                      context,
                      peerId: responder.id,
                      name: responderName,
                      company: responderCompany,
                      designation: responderDesignation,
                      avatarUrl: responderAvatar,
                    );
                  }
                : null,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                InitialsAvatar(
                  name: responderName,
                  imageUrl: responderAvatar.isNotEmpty ? responderAvatar : null,
                  radius: 20,
                  fontSize: 13,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              responderName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.text,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasPeerProfile) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_outward_rounded,
                              size: 13,
                              color: AppColors.primary,
                            ),
                          ],
                        ],
                      ),
                      if (responderCompany.isNotEmpty || responderDesignation.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (responderCompany.isNotEmpty) responderCompany,
                            if (responderDesignation.isNotEmpty) responderDesignation,
                          ].join(' · '),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getStatusBg(response.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    response.statusLabel,
                    style: TextStyle(
                      color: _getStatusTextColor(response.status),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Response Type & Timestamp
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.volunteer_activism_outlined,
                      size: 11,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      response.displayResponseType,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (respondedTimeStr.isNotEmpty)
                Text(
                  respondedTimeStr,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),

          // Message bubble if message provided
          if (response.message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    size: 15,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      response.message,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.text,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Introduced Peer (if any)
          if (response.introducedPeer != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_add_alt_outlined,
                    size: 14,
                    color: Color(0xFF1D4ED8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Introduced: ${response.introducedPeer!.effectiveName}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                  if (response.introducedPeer!.companyName.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(${response.introducedPeer!.companyName})',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
