/// Model representing the metrics shown on the Circle Chair dashboard.
class DashboardMetricsModel {
  /// General impact rating count.
  final int impact;

  /// Monetary value of deals formatted as a string (e.g. ₹1.34Cr).
  final String deals;

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

  const DashboardMetricsModel({
    required this.impact,
    required this.deals,
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
  });

  factory DashboardMetricsModel.fromJson(Map<String, dynamic> json) {
    return DashboardMetricsModel(
      impact: json['impact'] as int? ?? 0,
      deals: json['deals']?.toString() ?? '₹0.0L',
      p2pMeetings: json['p2p_meetings'] as int? ?? 0,
      totalPeers: json['total_peers'] as int? ?? 0,
      totalPeersGrowth: json['total_peers_growth'] as int? ?? 0,
      referrals: json['referrals'] as int? ?? 0,
      testimonials: json['testimonials'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      overallRevenue: json['overall_revenue']?.toString(),
      overallDealsClosed: json['overall_deals_closed']?.toString(),
      circleName: json['circle_name']?.toString() ?? json['circle']?.toString(),
      pendingRequestsCount: json['pending_requests_count'] as int? ??
          json['pending_requests'] as int? ??
          json['pending_peers'] as int? ??
          0,
    );
  }

  Map<String, dynamic> toJson() => {
        'impact': impact,
        'deals': deals,
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
      };
}
