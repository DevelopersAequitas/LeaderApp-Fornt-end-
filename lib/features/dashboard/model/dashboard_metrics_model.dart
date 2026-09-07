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

  static int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final clean = value.replaceAll(',', '').trim();
      return int.tryParse(clean) ?? (double.tryParse(clean)?.toInt() ?? defaultValue);
    }
    return defaultValue;
  }

  factory DashboardMetricsModel.fromJson(Map<dynamic, dynamic> json) {
    return DashboardMetricsModel(
      impact: _parseInt(json['impact'] ?? json['impact_count']),
      deals: json['deals']?.toString() ?? '₹0.0L',
      p2pMeetings: _parseInt(json['p2p_meetings'] ?? json['p2p_sessions']),
      totalPeers: _parseInt(json['total_peers']),
      totalPeersGrowth: _parseInt(json['total_peers_growth']),
      referrals: _parseInt(json['referrals'] ?? json['referrals_count']),
      testimonials: _parseInt(json['testimonials'] ?? json['testimonials_count']),
      coins: _parseInt(json['coins'] ?? json['coins_count']),
      overallRevenue: json['overall_revenue']?.toString(),
      overallDealsClosed: json['overall_deals_closed']?.toString(),
      circleName: json['circle_name']?.toString() ?? json['circle']?.toString(),
      pendingRequestsCount: _parseInt(
        json['pending_peers_count'] ??
            json['pending_requests_count'] ??
            json['pending_requests'] ??
            json['pending_peers'],
        0,
      ),
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
