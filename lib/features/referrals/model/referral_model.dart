/// Model representing a peer referral performance profile.
class ReferralModel {
  final String id;
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
    this.id = '',
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

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    final name = json['peer_name'] as String? ?? json['name'] as String? ?? 'Peer';
    final nameParts = name.split(' ');
    final initials = nameParts.length > 1
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();

    final referralsCount = json['referrals_count'] as int? ?? json['referral_count'] as int? ?? 0;

    return ReferralModel(
      id: json['id']?.toString() ?? '',
      rank: json['rank'] as int? ?? 1,
      name: name,
      initials: initials,
      company: json['company'] as String? ?? '',
      referralCount: referralsCount,
      category: json['category'] as String? ?? 'Technology',
      status: json['status'] as String? ?? 'Active',
      source: json['source'] as String? ?? 'Direct',
      attendanceRate: json['attendance_rate']?.toString() ?? '92%',
      p2pCount: json['p2p_count'] as int? ?? 12,
      referralsCount: referralsCount,
      dealsCount: json['value_formatted']?.toString() ?? json['deals_count']?.toString() ?? '₹0',
      coinsCount: json['coins_count'] as int? ?? 420,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rank': rank,
        'peer_name': name,
        'company': company,
        'referrals_count': referralsCount,
        'category': category,
        'status': status,
        'source': source,
        'attendance_rate': attendanceRate,
        'p2p_count': p2pCount,
        'value_formatted': dealsCount,
        'coins_count': coinsCount,
      };
}
