/// Model representing a peer in the circle with privacy controls and rich profile fields.
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
  final bool hidePhone;
  final bool hideEmail;
  final String? designation;
  final String? joinedDate;
  final bool isVerified;
  final String? introVideoUrl;
  final String? bio;
  final String? birthday;
  final String? anniversary;
  final String? whatsapp;
  final String? linkedin;
  final String? dealsGiven;
  final String? dealsReceived;
  final int? referralsGiven;
  final int? referralsReceived;
  final int? p2pMeetings;

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
    this.hidePhone = false,
    this.hideEmail = false,
    this.designation,
    this.joinedDate,
    this.isVerified = false,
    this.introVideoUrl,
    this.bio,
    this.birthday,
    this.anniversary,
    this.whatsapp,
    this.linkedin,
    this.dealsGiven,
    this.dealsReceived,
    this.referralsGiven,
    this.referralsReceived,
    this.p2pMeetings,
  });

  factory PeerModel.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as String? ?? json['peer_name'] as String? ?? 'Peer').trim();
    final nameParts = name.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    final initials = nameParts.length > 1
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase());

    String companyStr = '';
    final rawCompany = json['company_name'] ?? json['company'];
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
        json['sub_industry'] as String? ??
        json['level_4_category'] as String? ??
        json['category'] as String? ??
        json['specialization'] as String?;

    final verified = json['is_verified'] == true ||
        json['verified'] == true ||
        json['is_verified'] == 1;

    final hideP = json['hide_phone'] == true || json['hide_phone'] == 1;
    final hideE = json['hide_email'] == true || json['hide_email'] == 1;

    final contact = json['contact'] is Map ? json['contact'] as Map : null;
    final metrics = json['metrics'] is Map ? json['metrics'] as Map : null;

    final phoneStr = contact?['phone']?.toString() ?? json['phone']?.toString();
    final emailStr = contact?['email']?.toString() ?? json['email']?.toString();
    final waStr = contact?['whatsapp']?.toString() ?? json['whatsapp']?.toString();
    final liStr = contact?['linkedin']?.toString() ?? json['linkedin']?.toString();

    int parsedImpact = 0;
    final rawImpact = metrics?['impact_count'] ?? metrics?['impact'] ?? json['impact_count'] ?? json['impact'] ?? json['lives'];
    if (rawImpact is int) {
      parsedImpact = rawImpact;
    } else if (rawImpact is num) {
      parsedImpact = rawImpact.toInt();
    } else if (rawImpact != null) {
      parsedImpact = int.tryParse(rawImpact.toString()) ?? 0;
    }

    int parsedCoins = 0;
    final rawCoins = metrics?['coins_earned'] ?? metrics?['coins'] ?? json['coins'] ?? json['coins_count'];
    if (rawCoins is int) {
      parsedCoins = rawCoins;
    } else if (rawCoins is num) {
      parsedCoins = rawCoins.toInt();
    } else if (rawCoins != null) {
      parsedCoins = int.tryParse(rawCoins.toString()) ?? 0;
    }

    String parsedTags = '';
    if (json['tags'] is List) {
      parsedTags = (json['tags'] as List).map((e) => e.toString()).join(' · ');
    } else if (json['tags'] is String) {
      parsedTags = json['tags'] as String;
    } else if (industryStr != null && level4 != null) {
      parsedTags = '$industryStr · $level4';
    } else if (industryStr != null) {
      parsedTags = industryStr;
    } else if (level4 != null) {
      parsedTags = level4;
    }

    return PeerModel(
      id: json['id']?.toString() ?? '',
      initials: initials.isNotEmpty ? initials : 'PR',
      name: name,
      avatarUrl: avatar,
      company: companyStr,
      circle: circleStr,
      circleId: json['circle_id']?.toString(),
      location: json['location'] as String? ?? json['city'] as String? ?? '',
      tags: parsedTags,
      impactCount: parsedImpact,
      dealsFormatted: metrics?['deals_closed']?.toString() ?? json['deals_formatted']?.toString() ?? json['deals']?.toString() ?? '₹0.0',
      coins: parsedCoins,
      attendance: metrics?['attendance_percentage']?.toString() ?? metrics?['attendance_rate']?.toString() ?? json['attendance']?.toString() ?? '',
      status: statusStr,
      industry: industryStr,
      level4Category: level4,
      phone: phoneStr,
      email: emailStr,
      hidePhone: hideP,
      hideEmail: hideE,
      designation: designationStr,
      joinedDate: json['joined_date'] as String?,
      isVerified: verified,
      introVideoUrl: introVid,
      bio: json['bio'] as String?,
      birthday: json['birthday'] as String?,
      anniversary: json['anniversary'] as String?,
      whatsapp: waStr,
      linkedin: liStr,
      dealsGiven: metrics?['deals_given']?.toString(),
      dealsReceived: metrics?['deals_received']?.toString(),
      referralsGiven: metrics?['referrals_given'] is int ? metrics!['referrals_given'] as int : int.tryParse(metrics?['referrals_given']?.toString() ?? ''),
      referralsReceived: metrics?['referrals_received'] is int ? metrics!['referrals_received'] as int : int.tryParse(metrics?['referrals_received']?.toString() ?? ''),
      p2pMeetings: metrics?['p2p_meetings'] is int ? metrics!['p2p_meetings'] as int : (metrics?['p2p_sessions'] is int ? metrics!['p2p_sessions'] as int : int.tryParse(metrics?['p2p_meetings']?.toString() ?? '')),
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
        'hide_phone': hidePhone,
        'hide_email': hideEmail,
        'designation': designation,
        'joined_date': joinedDate,
        'is_verified': isVerified,
        'intro_video_url': introVideoUrl,
        'bio': bio,
        'birthday': birthday,
        'anniversary': anniversary,
        'whatsapp': whatsapp,
        'linkedin': linkedin,
        'deals_given': dealsGiven,
        'deals_received': dealsReceived,
        'referrals_given': referralsGiven,
        'referrals_received': referralsReceived,
        'p2p_meetings': p2pMeetings,
      };

  PeerModel copyWith({
    String? id,
    String? initials,
    String? name,
    String? avatarUrl,
    String? company,
    String? circle,
    String? circleId,
    String? location,
    String? tags,
    int? impactCount,
    String? dealsFormatted,
    int? coins,
    String? attendance,
    String? status,
    String? industry,
    String? level4Category,
    String? phone,
    String? email,
    bool? hidePhone,
    bool? hideEmail,
    String? designation,
    String? joinedDate,
    bool? isVerified,
    String? introVideoUrl,
    String? bio,
    String? birthday,
    String? anniversary,
    String? whatsapp,
    String? linkedin,
    String? dealsGiven,
    String? dealsReceived,
    int? referralsGiven,
    int? referralsReceived,
    int? p2pMeetings,
  }) {
    return PeerModel(
      id: id ?? this.id,
      initials: initials ?? this.initials,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      company: company ?? this.company,
      circle: circle ?? this.circle,
      circleId: circleId ?? this.circleId,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      impactCount: impactCount ?? this.impactCount,
      dealsFormatted: dealsFormatted ?? this.dealsFormatted,
      coins: coins ?? this.coins,
      attendance: attendance ?? this.attendance,
      status: status ?? this.status,
      industry: industry ?? this.industry,
      level4Category: level4Category ?? this.level4Category,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      hidePhone: hidePhone ?? this.hidePhone,
      hideEmail: hideEmail ?? this.hideEmail,
      designation: designation ?? this.designation,
      joinedDate: joinedDate ?? this.joinedDate,
      isVerified: isVerified ?? this.isVerified,
      introVideoUrl: introVideoUrl ?? this.introVideoUrl,
      bio: bio ?? this.bio,
      birthday: birthday ?? this.birthday,
      anniversary: anniversary ?? this.anniversary,
      whatsapp: whatsapp ?? this.whatsapp,
      linkedin: linkedin ?? this.linkedin,
      dealsGiven: dealsGiven ?? this.dealsGiven,
      dealsReceived: dealsReceived ?? this.dealsReceived,
      referralsGiven: referralsGiven ?? this.referralsGiven,
      referralsReceived: referralsReceived ?? this.referralsReceived,
      p2pMeetings: p2pMeetings ?? this.p2pMeetings,
    );
  }
}
