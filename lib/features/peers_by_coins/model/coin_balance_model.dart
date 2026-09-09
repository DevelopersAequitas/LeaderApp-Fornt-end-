import '../../peers/model/peer_model.dart';

/// Model representing a peer coin balance profile.
class CoinBalanceModel {
  final String id;
  final String peerUserId;
  final int rank;
  final String name;
  final String initials;
  final String company;
  final String profileImage;
  final String city;
  final String categoryLevel4;
  final String circle;
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
    this.peerUserId = '',
    required this.rank,
    required this.name,
    required this.initials,
    required this.company,
    this.profileImage = '',
    this.city = '',
    this.categoryLevel4 = '',
    this.circle = '',
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
    final peerMap = json['peer'] is Map<String, dynamic>
        ? json['peer'] as Map<String, dynamic>
        : (json['peer'] is Map ? Map<String, dynamic>.from(json['peer'] as Map) : null);

    final peerUserId = json['peer_user_id']?.toString() ??
        json['user_id']?.toString() ??
        peerMap?['peer_user_id']?.toString() ??
        peerMap?['id']?.toString() ??
        json['id']?.toString() ??
        '';

    final name = (json['peer_name'] as String? ??
            json['name'] as String? ??
            peerMap?['peer_name'] as String? ??
            peerMap?['name'] as String? ??
            'Peer')
        .trim();

    final nameParts = name.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    final initials = nameParts.length > 1
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase());

    final companyStr = json['business_name']?.toString() ??
        json['company_name']?.toString() ??
        json['company']?.toString() ??
        peerMap?['business_name']?.toString() ??
        peerMap?['company_name']?.toString() ??
        '';

    final profileImg = json['profile_image']?.toString() ??
        json['profile_photo_url']?.toString() ??
        json['avatar_url']?.toString() ??
        peerMap?['profile_image']?.toString() ??
        '';

    final cityStr = json['city']?.toString() ??
        json['location']?.toString() ??
        peerMap?['city']?.toString() ??
        '';

    final catLevel4 = json['category_level4']?.toString() ??
        json['level4_category']?.toString() ??
        json['sub_industry']?.toString() ??
        peerMap?['category_level4']?.toString() ??
        '';

    final rawCoins = json['coins_earned'] ?? json['coins'] ?? json['coins_count'];
    final coins = (rawCoins is num)
        ? rawCoins.toInt()
        : (int.tryParse(rawCoins?.toString() ?? '0') ?? 0);

    String statusStr = 'Active';
    final rawStatus = json['status'];
    if (rawStatus is Map) {
      statusStr = rawStatus['name']?.toString() ?? rawStatus['status']?.toString() ?? 'Active';
    } else if (rawStatus is String) {
      statusStr = rawStatus;
    }

    String categoryStr = catLevel4.isNotEmpty ? catLevel4 : 'General';
    final rawCat = json['category'];
    if (rawCat is Map) {
      categoryStr = rawCat['name']?.toString() ?? rawCat['category']?.toString() ?? categoryStr;
    } else if (rawCat is String && rawCat.isNotEmpty) {
      categoryStr = rawCat;
    }

    String sourceStr = 'Direct';
    final rawSource = json['source'];
    if (rawSource is Map) {
      sourceStr = rawSource['name']?.toString() ?? rawSource['source']?.toString() ?? 'Direct';
    } else if (rawSource is String) {
      sourceStr = rawSource;
    }

    String circleStr = '';
    final rawCircle = json['circle'] ?? json['circle_name'];
    if (rawCircle is Map) {
      circleStr = rawCircle['name']?.toString() ?? '';
    } else if (rawCircle is String) {
      circleStr = rawCircle;
    }

    return CoinBalanceModel(
      id: json['id']?.toString() ?? peerUserId,
      peerUserId: peerUserId,
      rank: json['rank'] as int? ?? 1,
      name: name,
      initials: initials.isNotEmpty ? initials : 'PR',
      company: companyStr,
      profileImage: profileImg,
      city: cityStr,
      categoryLevel4: catLevel4,
      circle: circleStr,
      coins: coins,
      category: categoryStr,
      status: statusStr,
      source: sourceStr,
      attendanceRate: json['attendance_rate']?.toString() ?? '0%',
      p2pCount: json['p2p_count'] as int? ?? 0,
      referralsCount: json['referrals_count'] as int? ?? 0,
      dealsCount: json['deals_count']?.toString() ?? '₹0',
      coinsCount: coins,
    );
  }

  PeerModel toPeerModel() {
    return PeerModel(
      id: peerUserId.isNotEmpty ? peerUserId : id,
      initials: initials,
      name: name,
      avatarUrl: profileImage.isNotEmpty ? profileImage : null,
      company: company,
      circle: circle,
      location: city,
      tags: categoryLevel4.isNotEmpty ? categoryLevel4 : category,
      impactCount: referralsCount,
      dealsFormatted: dealsCount,
      coins: coins,
      attendance: attendanceRate,
      status: status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'peer_user_id': peerUserId,
        'rank': rank,
        'peer_name': name,
        'company': company,
        'profile_image': profileImage,
        'city': city,
        'category_level4': categoryLevel4,
        'circle': circle,
        'coins': coins,
        'coins_earned': coins,
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
