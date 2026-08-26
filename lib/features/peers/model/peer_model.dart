/// Model representing a peer in the circle.
class PeerModel {
  final String id;
  final String initials;
  final String name;
  final String? avatarUrl;
  final String company;
  final String circle;
  final String? circleId;
  final String location;
  final String tags;
  final int impactCount;
  final String dealsFormatted;
  final int coins;
  final String attendance;
  final String status; // "Active", "Needs Attention", "At Risk", "Pending"
  final String? industry;
  final String? level4Category;
  final String? phone;
  final String? email;
  final String? designation;
  final String? joinedDate;
  final bool isVerified;
  final String? introVideoUrl;

  const PeerModel({
    this.id = '',
    required this.initials,
    required this.name,
    this.avatarUrl,
    required this.company,
    required this.circle,
    this.circleId,
    required this.location,
    required this.tags,
    required this.impactCount,
    required this.dealsFormatted,
    required this.coins,
    required this.attendance,
    required this.status,
    this.industry,
    this.level4Category,
    this.phone,
    this.email,
    this.designation,
    this.joinedDate,
    this.isVerified = false,
    this.introVideoUrl,
  });

  factory PeerModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? json['peer_name'] as String? ?? 'Peer';
    final nameParts = name.trim().split(' ');
    final initials = nameParts.length > 1
        ? '${nameParts[0].isNotEmpty ? nameParts[0][0] : ""}${nameParts[1].isNotEmpty ? nameParts[1][0] : ""}'
        : (name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase());

    String companyStr = '';
    final rawCompany = json['company'];
    if (rawCompany is Map) {
      companyStr = rawCompany['name']?.toString() ?? '';
    } else if (rawCompany is String) {
      companyStr = rawCompany;
    }

    String circleStr = '';
    final rawCircle = json['circle'] ?? json['circle_name'];
    if (rawCircle is Map) {
      circleStr = rawCircle['name']?.toString() ?? '';
    } else if (rawCircle is String) {
      circleStr = rawCircle;
    }

    String statusStr = 'Active';
    final rawStatus = json['status'];
    if (rawStatus is Map) {
      statusStr = rawStatus['name']?.toString() ?? rawStatus['status']?.toString() ?? 'Active';
    } else if (rawStatus is String) {
      statusStr = rawStatus;
    }

    String? industryStr;
    final rawInd = json['industry'];
    if (rawInd is Map) {
      industryStr = rawInd['name']?.toString();
    } else if (rawInd is String) {
      industryStr = rawInd;
    }

    String? designationStr;
    final rawDesig = json['designation'];
    if (rawDesig is Map) {
      designationStr = rawDesig['name']?.toString();
    } else if (rawDesig is String) {
      designationStr = rawDesig;
    }

    final avatar = json['avatar_url'] as String? ??
        json['profile_photo_url'] as String? ??
        json['avatar'] as String? ??
        json['profile_image'] as String? ??
        json['profile_picture'] as String? ??
        json['image_url'] as String? ??
        json['image'] as String?;

    final introVid = json['intro_video_url'] as String? ??
        json['intro_video'] as String? ??
        json['video_url'] as String? ??
        json['video'] as String?;

    final level4 = json['level4_category'] as String? ??
        json['level_4_category'] as String? ??
        json['category'] as String? ??
        json['specialization'] as String?;

    final verified = json['is_verified'] == true ||
        json['verified'] == true ||
        json['is_verified'] == 1;

    return PeerModel(
      id: json['id']?.toString() ?? '',
      initials: initials.isNotEmpty ? initials : 'PR',
      name: name,
      avatarUrl: avatar,
      company: companyStr,
      circle: circleStr,
      circleId: json['circle_id']?.toString(),
      location: json['location'] as String? ?? '',
      tags: json['tags'] as String? ?? '',
      impactCount: json['impact_count'] as int? ?? 0,
      dealsFormatted: json['deals_formatted']?.toString() ?? json['deals']?.toString() ?? '₹0.0',
      coins: json['coins'] as int? ?? 0,
      attendance: json['attendance']?.toString() ?? '',
      status: statusStr,
      industry: industryStr,
      level4Category: level4,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      designation: designationStr,
      joinedDate: json['joined_date'] as String?,
      isVerified: verified,
      introVideoUrl: introVid,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar_url': avatarUrl,
        'company': company,
        'circle': circle,
        'circle_id': circleId,
        'location': location,
        'tags': tags,
        'impact_count': impactCount,
        'deals_formatted': dealsFormatted,
        'coins': coins,
        'attendance': attendance,
        'status': status,
        'industry': industry,
        'level4_category': level4Category,
        'phone': phone,
        'email': email,
        'designation': designation,
        'joined_date': joinedDate,
        'is_verified': isVerified,
        'intro_video_url': introVideoUrl,
      };
}

