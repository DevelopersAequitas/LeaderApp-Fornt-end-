/// Model representing a peer coin balance profile.
class CoinBalanceModel {
  final String id;
  final int rank;
  final String name;
  final String initials;
  final String company;
  final int coins;
  final String category;
  final String status; // 'Active' or 'At Risk'
  final String source; // 'Direct' or 'App'
  final String attendanceRate; // e.g. "96%"
  final int p2pCount; // e.g. 14
  final int referralsCount; // e.g. 8
  final String dealsCount; // e.g. "₹32k"
  final int coinsCount; // e.g. 420

  const CoinBalanceModel({
    this.id = '',
    required this.rank,
    required this.name,
    required this.initials,
    required this.company,
    required this.coins,
    required this.category,
    required this.status,
    required this.source,
    required this.attendanceRate,
    required this.p2pCount,
    required this.referralsCount,
    required this.dealsCount,
    required this.coinsCount,
  });

  factory CoinBalanceModel.fromJson(Map<String, dynamic> json) {
    final name = json['peer_name'] as String? ?? json['name'] as String? ?? 'Peer';
    final nameParts = name.split(' ');
    final initials = nameParts.length > 1
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();

    final coins = json['coins'] as int? ?? 0;

    return CoinBalanceModel(
      id: json['id']?.toString() ?? '',
      rank: json['rank'] as int? ?? 1,
      name: name,
      initials: initials,
      company: json['company'] as String? ?? json['circle_name'] as String? ?? '',
      coins: coins,
      category: json['category'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
      source: json['source'] as String? ?? 'Direct',
      attendanceRate: json['attendance_rate']?.toString() ?? '0%',
      p2pCount: json['p2p_count'] as int? ?? 0,
      referralsCount: json['referrals_count'] as int? ?? 0,
      dealsCount: json['deals_count']?.toString() ?? '₹0',
      coinsCount: coins,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rank': rank,
        'peer_name': name,
        'company': company,
        'coins': coins,
        'category': category,
        'status': status,
        'source': source,
        'attendance_rate': attendanceRate,
        'p2p_count': p2pCount,
        'referrals_count': referralsCount,
        'deals_count': dealsCount,
        'coins_count': coinsCount,
      };
}
