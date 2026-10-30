/// Model representing the metrics shown on the Leader App Home Dashboard.
class DashboardMetricsModel {
  /// General impact rating count.
  final int impact;

  /// Monetary value of deals formatted as a string (e.g. ₹1.34Cr).
  final String deals;

  /// Count of business deals recorded.
  final int dealsCount;

  /// Count of Peer-to-Peer meetings completed.
  final int p2pMeetings;

  /// Total number of peers in the circle.
  final int totalPeers;

  /// Monthly growth rate of total peers.
  final int totalPeersGrowth;

  /// Referrals counts.
  final int referrals;

  /// Testimonials count.
  final int testimonials;

  /// Total coins held by peers.
  final int coins;

  /// Overall revenue for the founder dashboard.
  final String? overallRevenue;

  /// Overall deals closed for the founder dashboard.
  final String? overallDealsClosed;

  /// Circle name if provided by API.
  final String? circleName;

  /// Pending requests count (if any).
  final int pendingRequestsCount;

  /// Open peer requirements count.
  final int requirements;

  /// Visitor registrations count.
  final int visitorRegistrations;

  /// Peer recommendations count.
  final int peerRecommendations;

  /// Peers introduced / community builders count.
  final int introducedPeers;

  /// Collaboration asks count.
  final int collaborationAsks;

  /// Referral asks count.
  final int referralAsks;

  /// Help asks count.
  final int helpAsks;

  /// Total asks across all flows.
  final int allAsks;

  /// Open (published) asks count.
  final int openAsks;

  /// In-progress asks count.
  final int inProgressAsks;

  /// Fulfilled asks count.
  final int fulfilledAsks;

  /// Timeline posts count.
  final int posts;

  /// Activity creatives count.
  final int creatives;

  /// Coin claim requests count.
  final int coinClaims;

  /// Business growth stories (Vyapaar Jagat) count.
  final int stories;

  /// Leadership role interest submissions count.
  final int leadershipInterests;

  /// Become a mentor submissions count.
  final int mentorApplications;

  /// Become a speaker submissions count.
  final int speakerApplications;

  /// Partner inquiries count.
  final int partnerInquiries;

  /// Certifications completed count.
  final int certifications;

  /// Entrepreneur certifications count.
  final int entrepreneurCertifications;

  /// Leadership certifications count.
  final int leadershipCertifications;

  /// Official circulars count.
  final int circulars;

  /// Event registrations count.
  final int eventRegistrations;

  /// Event checked-in attendance count.
  final int eventAttendance;

  const DashboardMetricsModel({
    required this.impact,
    required this.deals,
    this.dealsCount = 0,
    required this.p2pMeetings,
    required this.totalPeers,
    required this.totalPeersGrowth,
    required this.referrals,
    required this.testimonials,
    required this.coins,
    this.overallRevenue,
    this.overallDealsClosed,
    this.circleName,
    this.pendingRequestsCount = 0,
    this.requirements = 0,
    this.visitorRegistrations = 0,
    this.peerRecommendations = 0,
    this.introducedPeers = 0,
    this.collaborationAsks = 0,
    this.referralAsks = 0,
    this.helpAsks = 0,
    this.allAsks = 0,
    this.openAsks = 0,
    this.inProgressAsks = 0,
    this.fulfilledAsks = 0,
    this.posts = 0,
    this.creatives = 0,
    this.coinClaims = 0,
    this.stories = 0,
    this.leadershipInterests = 0,
    this.mentorApplications = 0,
    this.speakerApplications = 0,
    this.partnerInquiries = 0,
    this.certifications = 0,
    this.entrepreneurCertifications = 0,
    this.leadershipCertifications = 0,
    this.circulars = 0,
    this.eventRegistrations = 0,
    this.eventAttendance = 0,
  });

  static int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final clean = value.replaceAll(',', '').trim();
      return int.tryParse(clean) ??
          (double.tryParse(clean)?.toInt() ?? defaultValue);
    }
    return defaultValue;
  }

  factory DashboardMetricsModel.fromJson(Map<dynamic, dynamic> json) {
    return DashboardMetricsModel(
      impact: _parseInt(json['impact'] ?? json['impact_count']),
      deals: json['deals']?.toString() ?? '₹0',
      dealsCount: _parseInt(json['deals_count'] ?? json['business_deals_count']),
      p2pMeetings: _parseInt(json['p2p_meetings'] ?? json['p2p_sessions']),
      totalPeers: _parseInt(json['total_peers']),
      totalPeersGrowth: _parseInt(json['total_peers_growth']),
      referrals: _parseInt(json['referrals'] ?? json['referrals_count']),
      testimonials:
          _parseInt(json['testimonials'] ?? json['testimonials_count']),
      coins: _parseInt(json['coins'] ?? json['coins_count']),
      overallRevenue: json['overall_revenue']?.toString(),
      overallDealsClosed: json['overall_deals_closed']?.toString(),
      circleName:
          json['circle_name']?.toString() ?? json['circle']?.toString(),
      pendingRequestsCount: _parseInt(
        json['pending_peers_count'] ??
            json['pending_requests_count'] ??
            json['pending_requests'] ??
            json['pending_peers'],
        0,
      ),
      requirements:
          _parseInt(json['requirements'] ?? json['requirements_count']),
      visitorRegistrations: _parseInt(
          json['visitor_registrations'] ?? json['visitors_count']),
      peerRecommendations: _parseInt(
          json['peer_recommendations'] ?? json['recommendations_count']),
      introducedPeers:
          _parseInt(json['introduced_peers'] ?? json['introduced_count']),
      collaborationAsks: _parseInt(
          json['collaboration_asks'] ?? json['collaborations_count']),
      referralAsks:
          _parseInt(json['referral_asks'] ?? json['referral_asks_count']),
      helpAsks: _parseInt(json['help_asks'] ?? json['help_asks_count']),
      allAsks: _parseInt(json['all_asks'] ?? json['total_asks']),
      openAsks: _parseInt(json['open_asks'] ?? json['published_asks']),
      inProgressAsks: _parseInt(json['in_progress_asks']),
      fulfilledAsks: _parseInt(json['fulfilled_asks']),
      posts: _parseInt(json['posts'] ?? json['posts_count']),
      creatives: _parseInt(json['creatives'] ?? json['creatives_count']),
      coinClaims: _parseInt(json['coin_claims'] ?? json['coin_claims_count']),
      stories: _parseInt(json['stories'] ?? json['stories_count']),
      leadershipInterests: _parseInt(
          json['leadership_interests'] ?? json['leader_interests_count']),
      mentorApplications:
          _parseInt(json['mentor_applications'] ?? json['mentors_count']),
      speakerApplications:
          _parseInt(json['speaker_applications'] ?? json['speakers_count']),
      partnerInquiries:
          _parseInt(json['partner_inquiries'] ?? json['partners_count']),
      certifications:
          _parseInt(json['certifications'] ?? json['certifications_count']),
      entrepreneurCertifications: _parseInt(
          json['entrepreneur_certifications'] ??
              json['entrepreneur_certification']),
      leadershipCertifications: _parseInt(
          json['leadership_certifications'] ??
              json['leadership_certification']),
      circulars: _parseInt(json['circulars'] ?? json['circulars_count']),
      eventRegistrations: _parseInt(
          json['event_registrations'] ?? json['events_registered_count']),
      eventAttendance:
          _parseInt(json['event_attendance'] ?? json['attendance_count']),
    );
  }

  DashboardMetricsModel copyWith({
    int? impact,
    String? deals,
    int? dealsCount,
    int? p2pMeetings,
    int? totalPeers,
    int? totalPeersGrowth,
    int? referrals,
    int? testimonials,
    int? coins,
    String? overallRevenue,
    String? overallDealsClosed,
    String? circleName,
    int? pendingRequestsCount,
    int? requirements,
    int? visitorRegistrations,
    int? peerRecommendations,
    int? introducedPeers,
    int? collaborationAsks,
    int? referralAsks,
    int? helpAsks,
    int? allAsks,
    int? openAsks,
    int? inProgressAsks,
    int? fulfilledAsks,
    int? posts,
    int? creatives,
    int? coinClaims,
    int? stories,
    int? leadershipInterests,
    int? mentorApplications,
    int? speakerApplications,
    int? partnerInquiries,
    int? certifications,
    int? entrepreneurCertifications,
    int? leadershipCertifications,
    int? circulars,
    int? eventRegistrations,
    int? eventAttendance,
  }) {
    return DashboardMetricsModel(
      impact: impact ?? this.impact,
      deals: deals ?? this.deals,
      dealsCount: dealsCount ?? this.dealsCount,
      p2pMeetings: p2pMeetings ?? this.p2pMeetings,
      totalPeers: totalPeers ?? this.totalPeers,
      totalPeersGrowth: totalPeersGrowth ?? this.totalPeersGrowth,
      referrals: referrals ?? this.referrals,
      testimonials: testimonials ?? this.testimonials,
      coins: coins ?? this.coins,
      overallRevenue: overallRevenue ?? this.overallRevenue,
      overallDealsClosed: overallDealsClosed ?? this.overallDealsClosed,
      circleName: circleName ?? this.circleName,
      pendingRequestsCount: pendingRequestsCount ?? this.pendingRequestsCount,
      requirements: requirements ?? this.requirements,
      visitorRegistrations: visitorRegistrations ?? this.visitorRegistrations,
      peerRecommendations: peerRecommendations ?? this.peerRecommendations,
      introducedPeers: introducedPeers ?? this.introducedPeers,
      collaborationAsks: collaborationAsks ?? this.collaborationAsks,
      referralAsks: referralAsks ?? this.referralAsks,
      helpAsks: helpAsks ?? this.helpAsks,
      allAsks: allAsks ?? this.allAsks,
      openAsks: openAsks ?? this.openAsks,
      inProgressAsks: inProgressAsks ?? this.inProgressAsks,
      fulfilledAsks: fulfilledAsks ?? this.fulfilledAsks,
      posts: posts ?? this.posts,
      creatives: creatives ?? this.creatives,
      coinClaims: coinClaims ?? this.coinClaims,
      stories: stories ?? this.stories,
      leadershipInterests: leadershipInterests ?? this.leadershipInterests,
      mentorApplications: mentorApplications ?? this.mentorApplications,
      speakerApplications: speakerApplications ?? this.speakerApplications,
      partnerInquiries: partnerInquiries ?? this.partnerInquiries,
      certifications: certifications ?? this.certifications,
      entrepreneurCertifications:
          entrepreneurCertifications ?? this.entrepreneurCertifications,
      leadershipCertifications:
          leadershipCertifications ?? this.leadershipCertifications,
      circulars: circulars ?? this.circulars,
      eventRegistrations: eventRegistrations ?? this.eventRegistrations,
      eventAttendance: eventAttendance ?? this.eventAttendance,
    );
  }

  Map<String, dynamic> toJson() => {
        'impact': impact,
        'deals': deals,
        'deals_count': dealsCount,
        'p2p_meetings': p2pMeetings,
        'total_peers': totalPeers,
        'total_peers_growth': totalPeersGrowth,
        'referrals': referrals,
        'testimonials': testimonials,
        'coins': coins,
        'overall_revenue': overallRevenue,
        'overall_deals_closed': overallDealsClosed,
        'circle_name': circleName,
        'pending_requests_count': pendingRequestsCount,
        'requirements': requirements,
        'visitor_registrations': visitorRegistrations,
        'peer_recommendations': peerRecommendations,
        'introduced_peers': introducedPeers,
        'collaboration_asks': collaborationAsks,
        'referral_asks': referralAsks,
        'help_asks': helpAsks,
        'all_asks': allAsks,
        'open_asks': openAsks,
        'in_progress_asks': inProgressAsks,
        'fulfilled_asks': fulfilledAsks,
        'posts': posts,
        'creatives': creatives,
        'coin_claims': coinClaims,
        'stories': stories,
        'leadership_interests': leadershipInterests,
        'mentor_applications': mentorApplications,
        'speaker_applications': speakerApplications,
        'partner_inquiries': partnerInquiries,
        'certifications': certifications,
        'entrepreneur_certifications': entrepreneurCertifications,
        'leadership_certifications': leadershipCertifications,
        'circulars': circulars,
        'event_registrations': eventRegistrations,
        'event_attendance': eventAttendance,
      };
}
