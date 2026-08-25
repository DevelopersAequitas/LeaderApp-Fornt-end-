/// Model representing a peer in the circle.
class PeerModel {
  final String id;
  final String initials;
  final String name;
  final String company;
  final String circle;
  final String location;
  final String tags;
  final int impactCount;
  final String dealsFormatted;
  final int coins;
  final String attendance;
  final String status; // "Active", "Needs Attention", "At Risk", "Pending"
  final String? industry;
  final String? phone;
  final String? email;
  final String? designation;
  final String? introVideoUrl;

  const PeerModel({
    this.id = '',
    required this.initials,
    required this.name,
    required this.company,
    required this.circle,
    required this.location,
    required this.tags,
    required this.impactCount,
    required this.dealsFormatted,
    required this.coins,
    required this.attendance,
    required this.status,
    this.industry,
    this.phone,
    this.email,
    this.designation,
    this.introVideoUrl,
  });

  factory PeerModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'Peer';
    final nameParts = name.split(' ');
    final initials = nameParts.length > 1
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();

    return PeerModel(
      id: json['id']?.toString() ?? '',
      initials: initials,
      name: name,
      company: json['company'] as String? ?? '',
      circle: json['circle'] as String? ?? json['circle_name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      tags: json['tags'] as String? ?? '',
      impactCount: json['impact_count'] as int? ?? 0,
      dealsFormatted: json['deals_formatted']?.toString() ?? json['deals']?.toString() ?? '₹0.0',
      coins: json['coins'] as int? ?? 0,
      attendance: json['attendance']?.toString() ?? '',
      status: json['status'] as String? ?? 'Active',
      industry: json['industry'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      designation: json['designation'] as String?,
      introVideoUrl: json['intro_video_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'company': company,
        'circle': circle,
        'location': location,
        'tags': tags,
        'impact_count': impactCount,
        'deals_formatted': dealsFormatted,
        'coins': coins,
        'attendance': attendance,
        'status': status,
        'industry': industry,
        'phone': phone,
        'email': email,
        'designation': designation,
        'intro_video_url': introVideoUrl,
      };
}
