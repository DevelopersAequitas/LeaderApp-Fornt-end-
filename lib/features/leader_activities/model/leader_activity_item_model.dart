import 'package:flutter/material.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../peers/model/peer_model.dart';

/// Configuration metadata for each user-input activity section on the Leader App.
class LeaderActivityCategoryConfig {
  final String type;
  final String title;
  final String subtitle;
  final String unitLabel;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData icon;

  const LeaderActivityCategoryConfig({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.unitLabel,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.icon,
  });

  static LeaderActivityCategoryConfig fromType(String rawType) {
    final normalized = rawType.toLowerCase().trim();
    switch (normalized) {
      case 'impacts':
      case 'impact':
      case 'life-impacts':
      case 'top-impacters':
        return const LeaderActivityCategoryConfig(
          type: 'impacts',
          title: 'Life Impacts',
          subtitle: 'All peers ranked top to bottom by lives impacted',
          unitLabel: 'Impacts',
          emptyTitle: 'No life impacts recorded yet',
          emptySubtitle:
              'Recorded mentorship and life impact stories from peers will appear here.',
          icon: Icons.volunteer_activism_rounded,
        );
      case 'business-deals':
      case 'deals':
        return const LeaderActivityCategoryConfig(
          type: 'business-deals',
          title: 'Business Deals',
          subtitle: 'All peers ranked top to bottom by closed business deals',
          unitLabel: 'Deals',
          emptyTitle: 'No business deals recorded yet',
          emptySubtitle:
              'Closed business deals and transactions between peers will appear here.',
          icon: Icons.handshake_rounded,
        );
      case 'p2p-meetings':
      case 'peer-meetings':
      case 'p2p':
        return const LeaderActivityCategoryConfig(
          type: 'p2p-meetings',
          title: 'P2P Meetings',
          subtitle: 'All peers ranked top to bottom by 1-on-1 P2P meetings',
          unitLabel: 'Meetings',
          emptyTitle: 'No P2P meetings recorded yet',
          emptySubtitle:
              '1-on-1 collaborative P2P meetings between peers will appear here.',
          icon: Icons.groups_2_rounded,
        );
      case 'referrals':
      case 'referral':
        return const LeaderActivityCategoryConfig(
          type: 'referrals',
          title: 'Referrals',
          subtitle: 'All peers ranked top to bottom by referrals shared',
          unitLabel: 'Referrals',
          emptyTitle: 'No referrals recorded yet',
          emptySubtitle:
              'Business referrals exchanged between peers will appear here.',
          icon: Icons.swap_horiz_rounded,
        );
      case 'testimonials':
      case 'endorsements':
        return const LeaderActivityCategoryConfig(
          type: 'testimonials',
          title: 'Endorsements & Testimonials',
          subtitle: 'All peers ranked top to bottom by endorsements',
          unitLabel: 'Endorsements',
          emptyTitle: 'No endorsements recorded yet',
          emptySubtitle:
              'Peer endorsements and testimonials will appear here.',
          icon: Icons.star_rounded,
        );
      case 'requirements':
      case 'requirement':
        return const LeaderActivityCategoryConfig(
          type: 'requirements',
          title: 'Peer Requirements',
          subtitle: 'All peers ranked top to bottom by posted requirements',
          unitLabel: 'Requirements',
          emptyTitle: 'No peer requirements posted yet',
          emptySubtitle:
              'Business opportunities and requirements posted by peers will appear here.',
          icon: Icons.lightbulb_outline_rounded,
        );
      case 'coins':
      case 'peers-by-coins':
        return const LeaderActivityCategoryConfig(
          type: 'coins',
          title: 'Peers by Coins',
          subtitle: 'All peers ranked top to bottom by total coins balance',
          unitLabel: 'Coins',
          emptyTitle: 'No coin balances found',
          emptySubtitle:
              'Peer coin balances and leaderboard rankings will appear here.',
          icon: Icons.monetization_on_rounded,
        );
      case 'peers':
      case 'all-peers':
        return const LeaderActivityCategoryConfig(
          type: 'peers',
          title: 'All Peers Directory',
          subtitle: 'All peers ranked top to bottom across your scope',
          unitLabel: 'Impacts',
          emptyTitle: 'No peers found',
          emptySubtitle: 'Registered peers in your scope will appear here.',
          icon: Icons.people_alt_rounded,
        );
      case 'visitor-registrations':
      case 'visitors':
        return const LeaderActivityCategoryConfig(
          type: 'visitor-registrations',
          title: 'Visitor Registrations',
          subtitle: 'All peers ranked top to bottom by visitors invited',
          unitLabel: 'Visitors',
          emptyTitle: 'No visitor registrations yet',
          emptySubtitle:
              'When peers register visitors for circle events, they will appear here.',
          icon: Icons.person_add_alt_1_rounded,
        );
      case 'peer-recommendations':
      case 'recommendations':
        return const LeaderActivityCategoryConfig(
          type: 'peer-recommendations',
          title: 'Recommended Peers',
          subtitle: 'All peers ranked top to bottom by recommendations',
          unitLabel: 'Recommended',
          emptyTitle: 'No peer recommendations yet',
          emptySubtitle:
              'Entrepreneurs recommended by peers to join the community will appear here.',
          icon: Icons.recommend_rounded,
        );
      case 'introduced-peers':
      case 'community-builders':
        return const LeaderActivityCategoryConfig(
          type: 'introduced-peers',
          title: 'Peers Introduced',
          subtitle: 'All peers ranked top to bottom by members onboarded',
          unitLabel: 'Introduced',
          emptyTitle: 'No introduced peers yet',
          emptySubtitle:
              'Members introduced and onboarded into the community will appear here.',
          icon: Icons.group_add_rounded,
        );
      case 'collaboration-asks':
      case 'collaborations':
        return const LeaderActivityCategoryConfig(
          type: 'collaboration-asks',
          title: 'Collaboration Asks',
          subtitle: 'All peers ranked top to bottom by collaboration asks',
          unitLabel: 'Collab Asks',
          emptyTitle: 'No collaboration asks posted yet',
          emptySubtitle:
              'Strategic collaboration requests from peers will appear here.',
          icon: Icons.diversity_3_rounded,
        );
      case 'referral-asks':
        return const LeaderActivityCategoryConfig(
          type: 'referral-asks',
          title: 'Referral Asks',
          subtitle: 'All peers ranked top to bottom by referral asks',
          unitLabel: 'Referral Asks',
          emptyTitle: 'No referral asks posted yet',
          emptySubtitle:
              'Client and business introduction requests from peers will appear here.',
          icon: Icons.campaign_rounded,
        );
      case 'help-asks':
      case 'need-help':
        return const LeaderActivityCategoryConfig(
          type: 'help-asks',
          title: 'Help Asks',
          subtitle: 'All peers ranked top to bottom by help requests',
          unitLabel: 'Help Asks',
          emptyTitle: 'No help asks posted yet',
          emptySubtitle:
              'Requests for advice, mentorship, or quick help from peers will appear here.',
          icon: Icons.support_agent_rounded,
        );
      case 'all-asks':
        return const LeaderActivityCategoryConfig(
          type: 'all-asks',
          title: 'All Asks',
          subtitle: 'Collaboration, referral and help asks from all peers',
          unitLabel: 'Asks',
          emptyTitle: 'No asks posted yet',
          emptySubtitle: 'Asks posted by peers across all flows will appear here.',
          icon: Icons.forum_rounded,
        );
      case 'open-asks':
        return const LeaderActivityCategoryConfig(
          type: 'open-asks',
          title: 'Open Asks',
          subtitle: 'Published asks waiting for peer responses',
          unitLabel: 'Open Asks',
          emptyTitle: 'No open asks right now',
          emptySubtitle: 'Newly published asks will appear here.',
          icon: Icons.mark_chat_unread_rounded,
        );
      case 'in-progress-asks':
        return const LeaderActivityCategoryConfig(
          type: 'in-progress-asks',
          title: 'In Progress Asks',
          subtitle: 'Asks currently being worked on with peers',
          unitLabel: 'In Progress',
          emptyTitle: 'No asks in progress',
          emptySubtitle: 'Asks that peers are actively responding to will appear here.',
          icon: Icons.pending_actions_rounded,
        );
      case 'fulfilled-asks':
        return const LeaderActivityCategoryConfig(
          type: 'fulfilled-asks',
          title: 'Fulfilled Asks',
          subtitle: 'Asks successfully completed by peers',
          unitLabel: 'Fulfilled',
          emptyTitle: 'No fulfilled asks yet',
          emptySubtitle: 'Asks marked as fulfilled will appear here.',
          icon: Icons.task_alt_rounded,
        );
      case 'posts':
      case 'timeline-posts':
        return const LeaderActivityCategoryConfig(
          type: 'posts',
          title: 'Community Posts',
          subtitle: 'All peers ranked top to bottom by timeline posts',
          unitLabel: 'Posts',
          emptyTitle: 'No community posts yet',
          emptySubtitle:
              'Updates, wins, and insights shared by peers on the timeline will appear here.',
          icon: Icons.article_rounded,
        );
      case 'creatives':
      case 'activity-creatives':
        return const LeaderActivityCategoryConfig(
          type: 'creatives',
          title: 'Activity Creatives',
          subtitle: 'All peers ranked top to bottom by activity creatives',
          unitLabel: 'Creatives',
          emptyTitle: 'No activity creatives yet',
          emptySubtitle:
              'Generated activity posters and celebration creatives will appear here.',
          icon: Icons.auto_awesome_mosaic_rounded,
        );
      case 'coin-claims':
      case 'claim-coins':
        return const LeaderActivityCategoryConfig(
          type: 'coin-claims',
          title: 'Coin Claims',
          subtitle: 'All peers ranked top to bottom by coin claims',
          unitLabel: 'Claims',
          emptyTitle: 'No coin claims submitted yet',
          emptySubtitle:
              'Requests submitted by peers to claim activity coins will appear here.',
          icon: Icons.toll_rounded,
        );
      case 'stories':
      case 'business-stories':
      case 'vyapaar-jagat':
        return const LeaderActivityCategoryConfig(
          type: 'stories',
          title: 'Business Stories',
          subtitle: 'All peers ranked top to bottom by business stories',
          unitLabel: 'Stories',
          emptyTitle: 'No business stories submitted yet',
          emptySubtitle:
              'Entrepreneurial journeys and Vyapaar Jagat story submissions will appear here.',
          icon: Icons.auto_stories_rounded,
        );
      case 'leadership-interests':
      case 'leader-interests':
        return const LeaderActivityCategoryConfig(
          type: 'leadership-interests',
          title: 'Leadership Role Interest',
          subtitle: 'All peers ranked top to bottom by leadership applications',
          unitLabel: 'Applications',
          emptyTitle: 'No leadership interest submissions yet',
          emptySubtitle:
              'Applications from peers interested in leadership roles will appear here.',
          icon: Icons.workspace_premium_rounded,
        );
      case 'mentor-applications':
      case 'mentors':
        return const LeaderActivityCategoryConfig(
          type: 'mentor-applications',
          title: 'Mentor Applications',
          subtitle: 'All peers ranked top to bottom by mentor applications',
          unitLabel: 'Applications',
          emptyTitle: 'No mentor applications yet',
          emptySubtitle:
              'Applications to become a mentor in the community will appear here.',
          icon: Icons.school_rounded,
        );
      case 'speaker-applications':
      case 'speakers':
        return const LeaderActivityCategoryConfig(
          type: 'speaker-applications',
          title: 'Speaker Applications',
          subtitle: 'All peers ranked top to bottom by speaker submissions',
          unitLabel: 'Applications',
          emptyTitle: 'No speaker applications yet',
          emptySubtitle:
              'Applications from peers to speak at circle events will appear here.',
          icon: Icons.record_voice_over_rounded,
        );
      case 'partner-inquiries':
      case 'partners':
        return const LeaderActivityCategoryConfig(
          type: 'partner-inquiries',
          title: 'Partner Inquiries',
          subtitle: 'All peers ranked top to bottom by partnership inquiries',
          unitLabel: 'Inquiries',
          emptyTitle: 'No partner inquiries yet',
          emptySubtitle:
              'Brand and corporate partnership inquiries will appear here.',
          icon: Icons.hub_rounded,
        );
      case 'certifications':
      case 'certificates':
        return const LeaderActivityCategoryConfig(
          type: 'certifications',
          title: 'Certifications',
          subtitle: 'All peers ranked top to bottom by certifications',
          unitLabel: 'Certificates',
          emptyTitle: 'No certifications completed yet',
          emptySubtitle:
              'Entrepreneur and leadership certification submissions will appear here.',
          icon: Icons.verified_user_rounded,
        );
      case 'entrepreneur-certifications':
      case 'entrepreneur-certificate':
        return const LeaderActivityCategoryConfig(
          type: 'entrepreneur-certifications',
          title: 'Entrepreneur Certifications',
          subtitle:
              'All peers ranked top to bottom by entrepreneur certifications',
          unitLabel: 'Certificates',
          emptyTitle: 'No entrepreneur certifications yet',
          emptySubtitle:
              'Entrepreneur certification submissions will appear here.',
          icon: Icons.military_tech_rounded,
        );
      case 'leadership-certifications':
      case 'leadership-certificate':
        return const LeaderActivityCategoryConfig(
          type: 'leadership-certifications',
          title: 'Leadership Certifications',
          subtitle:
              'All peers ranked top to bottom by leadership certifications',
          unitLabel: 'Certificates',
          emptyTitle: 'No leadership certifications yet',
          emptySubtitle:
              'Leadership certification submissions will appear here.',
          icon: Icons.verified_rounded,
        );
      case 'pending-requests':
      case 'pending-approvals':
        return const LeaderActivityCategoryConfig(
          type: 'pending-requests',
          title: 'Pending Approvals',
          subtitle: 'All pending member and activity approval requests',
          unitLabel: 'Requests',
          emptyTitle: 'No pending approvals right now',
          emptySubtitle:
              'Pending circle join and activity requests will appear here.',
          icon: Icons.rule_folder_rounded,
        );
      case 'circulars':
      case 'official-circulars':
        return const LeaderActivityCategoryConfig(
          type: 'circulars',
          title: 'Official Circulars',
          subtitle: 'Official leadership announcements and circulars',
          unitLabel: 'Circulars',
          emptyTitle: 'No official circulars published yet',
          emptySubtitle:
              'Published circle and regional circulars will appear here.',
          icon: Icons.campaign_rounded,
        );
      case 'top-contributors':
      case 'contributors':
        return const LeaderActivityCategoryConfig(
          type: 'top-contributors',
          title: 'Top Contributors',
          subtitle: 'All peers ranked top to bottom by overall contributions',
          unitLabel: 'Points',
          emptyTitle: 'No contributor rankings yet',
          emptySubtitle:
              'Peers ranked by overall community contributions will appear here.',
          icon: Icons.workspace_premium_rounded,
        );
      case 'highest-givers':
      case 'givers':
        return const LeaderActivityCategoryConfig(
          type: 'highest-givers',
          title: 'Highest Givers',
          subtitle: 'All peers ranked top to bottom by referrals & giving',
          unitLabel: 'Referrals',
          emptyTitle: 'No givers ranked yet',
          emptySubtitle:
              'Peers ranked by referrals and business shared will appear here.',
          icon: Icons.card_giftcard_rounded,
        );
      case 'event-registrations':
      case 'events':
        return const LeaderActivityCategoryConfig(
          type: 'event-registrations',
          title: 'Event Registrations',
          subtitle: 'All peers ranked top to bottom by event registrations',
          unitLabel: 'Events',
          emptyTitle: 'No event registrations yet',
          emptySubtitle:
              'Peer registrations for upcoming and past events will appear here.',
          icon: Icons.event_available_rounded,
        );
      case 'event-attendance':
      case 'attendance':
        return const LeaderActivityCategoryConfig(
          type: 'event-attendance',
          title: 'Event Attendance',
          subtitle: 'All peers ranked top to bottom by event check-ins',
          unitLabel: 'Attended',
          emptyTitle: 'No event check-ins recorded yet',
          emptySubtitle:
              'Verified event check-ins by peers will appear here.',
          icon: Icons.fact_check_rounded,
        );
      default:
        final label = normalized
            .split('-')
            .map((w) =>
                w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
        return LeaderActivityCategoryConfig(
          type: normalized,
          title: label.isEmpty ? 'Community Activities' : label,
          subtitle: 'All peers ranked top to bottom',
          unitLabel: 'Activities',
          emptyTitle: 'No activities recorded yet',
          emptySubtitle: 'Peer submissions for this category will appear here.',
          icon: Icons.insights_rounded,
        );
    }
  }
}

/// Represents a peer in the top-to-bottom ranked peers list for any activity section.
class LeaderRankedPeerModel {
  final int rank;
  final PeerModel peer;
  final int metricCount;
  final double metricAmount;
  final String metricLabel;
  final String metricDisplay;

  const LeaderRankedPeerModel({
    required this.rank,
    required this.peer,
    required this.metricCount,
    this.metricAmount = 0.0,
    required this.metricLabel,
    required this.metricDisplay,
  });

  factory LeaderRankedPeerModel.fromJson(
    Map<String, dynamic> json, {
    int fallbackRank = 1,
    String defaultLabel = 'Activities',
  }) {
    final peer = PeerModel.fromJson(json);
    final rawCount = json['metric_count'] ??
        json['count'] ??
        json['coins'] ??
        json['referrals_count'] ??
        json['life_impacted_count'] ??
        0;
    final int count = rawCount is int
        ? rawCount
        : (rawCount is num
            ? rawCount.toInt()
            : (int.tryParse(rawCount.toString()) ?? 0));
    final rawAmt = json['metric_amount'] ?? json['deal_value'] ?? 0.0;
    final double amt = rawAmt is num
        ? rawAmt.toDouble()
        : (double.tryParse(rawAmt.toString()) ?? 0.0);
    final label = (json['metric_label'] ?? defaultLabel).toString();
    final display = (json['metric_display'] ?? '$count').toString();
    final rankVal = json['rank'] is int
        ? json['rank'] as int
        : (int.tryParse(json['rank']?.toString() ?? '') ?? fallbackRank);

    return LeaderRankedPeerModel(
      rank: rankVal,
      peer: peer,
      metricCount: count,
      metricAmount: amt,
      metricLabel: label,
      metricDisplay: display,
    );
  }

  LeaderRankedPeerModel copyWith({
    int? rank,
    PeerModel? peer,
    int? metricCount,
    double? metricAmount,
    String? metricLabel,
    String? metricDisplay,
  }) {
    return LeaderRankedPeerModel(
      rank: rank ?? this.rank,
      peer: peer ?? this.peer,
      metricCount: metricCount ?? this.metricCount,
      metricAmount: metricAmount ?? this.metricAmount,
      metricLabel: metricLabel ?? this.metricLabel,
      metricDisplay: metricDisplay ?? this.metricDisplay,
    );
  }
}

/// Combined payload returned when opening a section from the Home tab.
class LeaderActivitiesPayload {
  final List<LeaderRankedPeerModel> peers;
  final List<LeaderActivityItemModel> items;
  final int totalActivities;
  final int totalPeers;
  final int total;
  final int page;
  final int perPage;
  final bool hasMore;
  final String unitLabel;

  const LeaderActivitiesPayload({
    required this.peers,
    required this.items,
    this.totalActivities = 0,
    this.totalPeers = 0,
    this.total = 0,
    this.page = 1,
    this.perPage = 50,
    this.hasMore = false,
    this.unitLabel = 'Activities',
  });
}

/// Standardized model representing a single user-input activity item.
class LeaderActivityItemModel {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final String description;
  final String status;
  final String date;
  final String? badgeLabel;
  final String? amount;
  final String peerId;
  final String peerName;
  final String? avatarUrl;
  final String city;
  final String designation;
  final String company;
  final String category;
  final String circleName;
  final bool isVerified;
  final String? targetPeerName;
  final String? targetPeerCompany;
  final String? requestCategory;

  const LeaderActivityItemModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.status,
    required this.date,
    this.badgeLabel,
    this.amount,
    required this.peerId,
    required this.peerName,
    this.avatarUrl,
    required this.city,
    required this.designation,
    required this.company,
    required this.category,
    required this.circleName,
    this.isVerified = false,
    this.targetPeerName,
    this.targetPeerCompany,
    this.requestCategory,
  });

  /// Formatted local date string (e.g. "25 Sep 2026" or "25 Sep 2026, 02:19 PM").
  String get formattedDate {
    if (date.isEmpty) return '';
    return DateTimeUtils.formatDate(date);
  }

  /// Relative time (e.g. "2h ago", "Just now", "25 Sep 2026").
  String get timeAgo {
    if (date.isEmpty) return '';
    return DateTimeUtils.formatTimeAgo(date);
  }

  bool get isActionablePending {
    if (id.trim().isEmpty) return false;
    final s = status.trim().toLowerCase();
    if (s.contains('approved') ||
        s.contains('rejected') ||
        s.contains('declined') ||
        s.contains('completed') ||
        s.contains('closed') ||
        s.contains('fulfilled') ||
        s.contains('checked in') ||
        s.contains('joined')) {
      return false;
    }
    if (type == 'pending-requests') return true;
    if (requestCategory != null && requestCategory!.trim().isNotEmpty) {
      return s.contains('pending') ||
          s.contains('awaiting') ||
          s.contains('submitted') ||
          s.contains('review');
    }
    const reviewableTypes = <String>{
      'coin-claims',
      'visitor-registrations',
      'event-registrations',
      'certifications',
      'entrepreneur-certifications',
      'leadership-certifications',
      'peer-recommendations',
      'introduced-peers',
      'leadership-interests',
      'mentor-applications',
      'speaker-applications',
      'partner-inquiries',
      'stories',
    };
    return reviewableTypes.contains(type) &&
        (s.contains('pending') ||
            s.contains('awaiting') ||
            s.contains('submitted') ||
            s.contains('review'));
  }

  LeaderActivityItemModel copyWith({
    String? status,
    String? peerId,
    String? avatarUrl,
    String? city,
    String? designation,
    String? company,
    String? category,
    String? circleName,
    bool? isVerified,
  }) {
    return LeaderActivityItemModel(
      id: id,
      type: type,
      title: title,
      subtitle: subtitle,
      description: description,
      status: status ?? this.status,
      date: date,
      badgeLabel: badgeLabel,
      amount: amount,
      peerId: peerId ?? this.peerId,
      peerName: peerName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      designation: designation ?? this.designation,
      company: company ?? this.company,
      category: category ?? this.category,
      circleName: circleName ?? this.circleName,
      isVerified: isVerified ?? this.isVerified,
      targetPeerName: targetPeerName,
      targetPeerCompany: targetPeerCompany,
      requestCategory: requestCategory,
    );
  }

  factory LeaderActivityItemModel.fromJson(Map<String, dynamic> json) {
    final fromPeer = json['from_peer'] is Map
        ? Map<String, dynamic>.from(json['from_peer'] as Map)
        : (json['peer'] is Map
            ? Map<String, dynamic>.from(json['peer'] as Map)
            : (json['giver_peer'] is Map
                ? Map<String, dynamic>.from(json['giver_peer'] as Map)
                : (json['author_peer'] is Map
                    ? Map<String, dynamic>.from(json['author_peer'] as Map)
                    : <String, dynamic>{})));
    final toPeer = json['to_peer'] is Map
        ? Map<String, dynamic>.from(json['to_peer'] as Map)
        : (json['receiver_peer'] is Map
            ? Map<String, dynamic>.from(json['receiver_peer'] as Map)
            : (json['target_peer'] is Map
                ? Map<String, dynamic>.from(json['target_peer'] as Map)
                : (json['impacted_peer'] is Map
                    ? Map<String, dynamic>.from(json['impacted_peer'] as Map)
                    : <String, dynamic>{})));

    final peerId = (fromPeer['id'] ??
            json['peer_user_id'] ??
            json['user_id'] ??
            json['peer_id'] ??
            '')
        .toString();

    final peerName = (fromPeer['name'] ??
            json['peer_name'] ??
            json['author_name'] ??
            json['name'] ??
            'Peer Member')
        .toString();

    final avatarUrl = (fromPeer['profile_image'] ??
            fromPeer['avatar_url'] ??
            json['profile_image'] ??
            json['avatar_url'])
        ?.toString();

    final city =
        (fromPeer['city'] ?? json['city'] ?? json['location'] ?? 'Ahmedabad')
            .toString();

    final designation = (fromPeer['designation'] ??
            json['designation'] ??
            json['author_role'] ??
            'Member')
        .toString();

    final company = (fromPeer['company_name'] ??
            fromPeer['business_name'] ??
            json['company_name'] ??
            json['business_name'] ??
            json['company'] ??
            'Enterprise')
        .toString();

    final category = (fromPeer['category_level4'] ??
            json['category_level4'] ??
            json['category'] ??
            'Business Services')
        .toString();

    final circleName =
        (fromPeer['circle_name'] ?? json['circle_name'] ?? '').toString();

    final isVerified = fromPeer['is_pro'] == true ||
        fromPeer['is_verified'] == true ||
        json['is_verified'] == true;

    final rawTitle = json['title'] ??
        json['subject'] ??
        json['action'] ??
        json['meeting_place'] ??
        json['prospect_name'] ??
        json['business_type'] ??
        'Activity Record';

    final rawDesc = json['description'] ??
        json['story'] ??
        json['story_to_share'] ??
        json['content'] ??
        json['comment'] ??
        json['notes'] ??
        json['remarks'] ??
        '';

    final rawAmount = json['amount'] ??
        json['deal_amount_formatted'] ??
        json['value_formatted'] ??
        (json['coins'] != null ? '${json['coins']} Coins' : null);

    return LeaderActivityItemModel(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      title: rawTitle.toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      description: rawDesc.toString(),
      status: (json['status'] ?? 'Active').toString(),
      date: (json['date'] ??
              json['impact_date'] ??
              json['deal_date'] ??
              json['meeting_date'] ??
              json['referral_date'] ??
              json['created_at'] ??
              '')
          .toString(),
      badgeLabel: json['badge_label']?.toString(),
      amount: rawAmount?.toString(),
      peerId: peerId,
      peerName: peerName,
      avatarUrl: avatarUrl != null && avatarUrl.isNotEmpty ? avatarUrl : null,
      city: city,
      designation: designation,
      company: company,
      category: category,
      circleName: circleName,
      isVerified: isVerified,
      targetPeerName:
          (toPeer['name'] ?? json['target_peer_name'])?.toString(),
      targetPeerCompany:
          (toPeer['company_name'] ?? toPeer['business_name'])?.toString(),
      requestCategory:
          (json['request_category'] ?? json['category_slug'])?.toString(),
    );
  }

  PeerModel toPeerModel() {
    final parts = peerName.trim().split(RegExp(r'\s+'));
    String initials = 'PR';
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials =
          parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    return PeerModel(
      id: peerId,
      initials: initials,
      name: peerName,
      avatarUrl: avatarUrl,
      company: company,
      circle: circleName,
      location: city,
      tags: category,
      level4Category: category,
      designation: designation,
      impactCount: 0,
      dealsFormatted: '₹0',
      coins: 0,
      attendance: '90%',
      status: 'Active',
      isVerified: isVerified,
    );
  }
}
