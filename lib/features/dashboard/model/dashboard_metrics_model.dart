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
  });
}
