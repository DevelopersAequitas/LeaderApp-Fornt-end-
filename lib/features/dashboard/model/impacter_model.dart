/// Model representing a top impacter peer in the active circle or organization.
class ImpacterModel {
  /// Unique identifier of the peer.
  final String id;

  /// Rank position (1 to 5).
  final int rank;

  /// Full name of the impacter.
  final String name;

  /// Display initials for avatar.
  final String initials;

  /// Profile image URL from storage.
  final String? avatarUrl;

  /// Associated company name.
  final String company;

  /// Circle location name.
  final String location;

  /// Circle name.
  final String circle;

  /// Circle ID.
  final String? circleId;

  /// Industry / tags.
  final String tags;

  /// Deals value formatted.
  final String dealsFormatted;

  /// Attendance rate string.
  final String attendance;

  /// Active status.
  final String status;

  /// Count of lives impacted (mapped from impact_count or lives).
  final int lives;

  /// Total coin score.
  final int coins;

  /// Contact phone number.
  final String? phone;

  /// Contact email address.
  final String? email;

  /// Role / designation.
  final String? designation;

  /// Industry classification.
  final String? industry;

  /// Sub-category.
  final String? level4Category;

  /// Peer verified badge.
  final bool isVerified;

  /// Intro video URL.
  final String? introVideoUrl;

  const ImpacterModel({
    this.id = '',
    required this.rank,
    required this.name,
    required this.initials,
    this.avatarUrl,
    required this.company,
    required this.location,
    this.circle = '',
    this.circleId,
    this.tags = '',
    this.dealsFormatted = '',
    this.attendance = '',
    this.status = 'Active',
    required this.lives,
    required this.coins,
    this.phone,
    this.email,
    this.designation,
    this.industry,
    this.level4Category,
    this.isVerified = false,
    this.introVideoUrl,
  });

  factory ImpacterModel.fromJson(
    Map<String, dynamic> json, {
    int defaultRank = 1,
  }) {
    final rawName = (json['name'] as String? ?? json['peer_name'] as String? ?? 'Peer').trim();
    final name = rawName.isNotEmpty ? rawName : 'Peer';

    // Safe initials generation
    String initials = 'P';
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    // Rank parsing
    int rank = defaultRank;
    if (json['rank'] != null) {
      if (json['rank'] is int) {
        rank = json['rank'] as int;
      } else if (json['rank'] is num) {
        rank = (json['rank'] as num).toInt();
      } else {
        rank = int.tryParse(json['rank'].toString()) ?? defaultRank;
      }
    }

    // Impact count / lives parsing
    int lives = 0;
    final rawLives = json['impact_count'] ?? json['lives'] ?? json['impact'] ?? json['impact_score'];
    if (rawLives is int) {
      lives = rawLives;
    } else if (rawLives is num) {
      lives = rawLives.toInt();
    } else if (rawLives != null) {
      lives = int.tryParse(rawLives.toString()) ?? 0;
    }

    // Coins parsing
    int coins = 0;
    final rawCoins = json['coins'] ?? json['coins_count'] ?? json['points'];
    if (rawCoins is int) {
      coins = rawCoins;
    } else if (rawCoins is num) {
      coins = rawCoins.toInt();
    } else if (rawCoins != null) {
      coins = int.tryParse(rawCoins.toString()) ?? 0;
    }

    return ImpacterModel(
      id: json['id']?.toString() ?? json['peer_id']?.toString() ?? '',
      rank: rank,
      name: name,
      initials: initials,
      avatarUrl: json['avatar_url'] as String? ?? json['avatar'] as String?,
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      circle: json['circle'] as String? ?? json['circle_name'] as String? ?? '',
      circleId: json['circle_id'] as String?,
      tags: json['tags'] as String? ?? json['category'] as String? ?? json['industry'] as String? ?? '',
      dealsFormatted: json['deals_formatted'] as String? ?? json['deals'] as String? ?? '',
      attendance: json['attendance'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
      lives: lives,
      coins: coins,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      designation: json['designation'] as String?,
      industry: json['industry'] as String?,
      level4Category: json['level4_category'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      introVideoUrl: json['intro_video_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rank': rank,
        'name': name,
        'initials': initials,
        'avatar_url': avatarUrl,
        'company': company,
        'location': location,
        'circle': circle,
        'circle_id': circleId,
        'tags': tags,
        'deals_formatted': dealsFormatted,
        'attendance': attendance,
        'status': status,
        'lives': lives,
        'coins': coins,
        'phone': phone,
        'email': email,
        'designation': designation,
        'industry': industry,
        'level4_category': level4Category,
        'is_verified': isVerified,
        'intro_video_url': introVideoUrl,
      };
}
