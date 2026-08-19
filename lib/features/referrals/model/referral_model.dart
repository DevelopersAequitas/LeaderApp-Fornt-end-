/// Model representing a peer referral performance profile.
class ReferralModel {
  final int rank;
  final String name;
  final String initials;
  final String company;
  final int referralCount;
  final String category;
  final String status; // 'Active' or 'At Risk'
  final String source; // 'Direct' or 'App'
  final String attendanceRate; // e.g. "96%"
  final int p2pCount; // e.g. 14
  final int referralsCount; // e.g. 8
  final String dealsCount; // e.g. "₹32k"
  final int coinsCount; // e.g. 420

  const ReferralModel({
    required this.rank,
    required this.name,
    required this.initials,
    required this.company,
    required this.referralCount,
    required this.category,
    required this.status,
    required this.source,
    required this.attendanceRate,
    required this.p2pCount,
    required this.referralsCount,
    required this.dealsCount,
    required this.coinsCount,
  });
}
