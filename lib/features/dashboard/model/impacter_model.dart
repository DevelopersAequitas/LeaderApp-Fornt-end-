/// Model representing a top impacter peer in the active circle.
class ImpacterModel {
  /// Unique identifier of the peer.
  final String id;

  /// Rank position (1 to 5).
  final int rank;

  /// Full name of the impacter.
  final String name;

  /// Display initials for avatar.
  final String initials;

  /// Associated company name.
  final String company;

  /// Circle location name.
  final String location;

  /// Circle name.
  final String circle;

  /// Industry / tags.
  final String tags;

  /// Deals value formatted.
  final String dealsFormatted;

  /// Attendance rate string.
  final String attendance;

  /// Active status.
  final String status;

  /// Count of lives impacted.
  final int lives;

  /// Total coin score.
  final int coins;

  const ImpacterModel({
    this.id = '',
    required this.rank,
    required this.name,
    required this.initials,
    required this.company,
    required this.location,
    this.circle = '',
    this.tags = '',
    this.dealsFormatted = '',
    this.attendance = '',
    this.status = 'Active',
    required this.lives,
    required this.coins,
  });

  factory ImpacterModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'Peer';
    final nameParts = name.split(' ');
    final initials = nameParts.length > 1
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();

    return ImpacterModel(
      id: json['id']?.toString() ?? json['peer_id']?.toString() ?? '',
      rank: json['rank'] as int? ?? 1,
      name: name,
      initials: initials,
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      circle: json['circle'] as String? ?? json['circle_name'] as String? ?? '',
      tags: json['tags'] as String? ?? json['category'] as String? ?? '',
      dealsFormatted: json['deals_formatted'] as String? ?? json['deals'] as String? ?? '',
      attendance: json['attendance'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
      lives: json['lives'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rank': rank,
        'name': name,
        'initials': initials,
        'company': company,
        'location': location,
        'circle': circle,
        'tags': tags,
        'deals_formatted': dealsFormatted,
        'attendance': attendance,
        'status': status,
        'lives': lives,
        'coins': coins,
      };
}
