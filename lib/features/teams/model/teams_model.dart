/// Model representing user permissions status and credentials for Teams.
class TeamsPermissionModel {
  final String role;
  final bool isRestricted;
  final List<String> requiredCapabilities;

  const TeamsPermissionModel({
    required this.role,
    required this.isRestricted,
    required this.requiredCapabilities,
  });
}

/// Model representing summary metrics across all managed circles.
class TeamsSummaryModel {
  final int totalCircles;
  final int avgHealth;
  final int totalPeers;
  final String totalRevenue;

  const TeamsSummaryModel({
    required this.totalCircles,
    required this.avgHealth,
    required this.totalPeers,
    required this.totalRevenue,
  });

  factory TeamsSummaryModel.fromJson(Map<String, dynamic> json) {
    return TeamsSummaryModel(
      totalCircles: json['total_circles'] as int? ?? 0,
      avgHealth: json['avg_health'] as int? ?? 0,
      totalPeers: json['total_peers'] as int? ?? 0,
      totalRevenue: json['total_revenue']?.toString() ?? '₹0.0',
    );
  }

  Map<String, dynamic> toJson() => {
        'total_circles': totalCircles,
        'avg_health': avgHealth,
        'total_peers': totalPeers,
        'total_revenue': totalRevenue,
      };
}

/// Model representing an industry category in Teams directory.
class IndustryModel {
  final String id;
  final String name;
  final String slug;
  final String iconUrl;
  final int circlesCount;
  final int peersCount;
  final String status;

  const IndustryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.iconUrl,
    this.circlesCount = 0,
    this.peersCount = 0,
    this.status = 'Active',
  });

  factory IndustryModel.fromJson(Map<String, dynamic> json) {
    return IndustryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      iconUrl: json['icon_url'] as String? ?? json['icon'] as String? ?? '',
      circlesCount: json['circles_count'] as int? ?? 0,
      peersCount: json['peers_count'] as int? ?? 0,
      status: json['status'] as String? ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'icon_url': iconUrl,
        'circles_count': circlesCount,
        'peers_count': peersCount,
        'status': status,
      };
}

/// Model representing an individual Circle Leader (Chair, Founder, Director).
class CircleLeaderModel {
  final String id;
  final String name;
  final String role; // "Circle Chair", "Circle Founder", "Circle Director", etc.
  final String? avatarUrl;
  final String? company;
  final String? designation;
  final String? phone;
  final String? email;
  final String? city;
  final String? category;
  final int impactCount;
  final bool isVerified;

  const CircleLeaderModel({
    this.id = '',
    required this.name,
    required this.role,
    this.avatarUrl,
    this.company,
    this.designation,
    this.phone,
    this.email,
    this.city,
    this.category,
    this.impactCount = 0,
    this.isVerified = false,
  });

  factory CircleLeaderModel.fromJson(
    Map<String, dynamic> json, {
    String defaultRole = 'Leader',
  }) {
    final rawImpacts = json['life_impacted_count'] ?? json['impact_count'] ?? 0;
    final parsedImpacts = rawImpacts is int
        ? rawImpacts
        : (rawImpacts is num
            ? rawImpacts.toInt()
            : (int.tryParse(rawImpacts.toString()) ?? 0));

    return CircleLeaderModel(
      id: json['id']?.toString() ??
          json['peer_id']?.toString() ??
          json['user_id']?.toString() ??
          '',
      name: json['name'] as String? ?? json['full_name'] as String? ?? '',
      role: json['role'] as String? ?? json['title'] as String? ?? defaultRole,
      avatarUrl: json['avatar_url'] as String? ??
          json['profile_photo_url'] as String? ??
          json['profile_image'] as String? ??
          json['avatar'] as String?,
      company: json['company'] as String? ??
          json['company_name'] as String? ??
          json['business_name'] as String?,
      designation: json['designation'] as String?,
      phone: json['phone'] as String? ?? json['mobile'] as String?,
      email: json['email'] as String?,
      city: json['city'] as String? ?? json['location'] as String?,
      category: json['category_level4'] as String? ??
          json['level_4_category'] as String? ??
          json['category'] as String?,
      impactCount: parsedImpacts,
      isVerified: json['is_verified'] == true || json['is_pro'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'avatar_url': avatarUrl,
        'company': company,
        'designation': designation,
        'phone': phone,
        'email': email,
        'city': city,
        'category': category,
        'life_impacted_count': impactCount,
        'is_verified': isVerified,
      };
}

/// Model representing circle statistics and management details.
class CircleTeamModel {
  final String id;
  final String name;
  final String category;
  final String location;
  final int peersCount;
  final int healthPercentage;
  final String revenue;
  final List<String> tags;
  final String founderName;
  final String directorName;
  final String chairName;
  final List<CircleLeaderModel> chairs;
  final List<CircleLeaderModel> founders;
  final List<CircleLeaderModel> directors;
  final String status;
  final String? launchDate;
  final String? circleImageUrl;
  final String? coverImageUrl;
  final String? description;
  final String? stage;
  final String meetingFrequency;
  final String meetingMode;

  const CircleTeamModel({
    this.id = '',
    required this.name,
    required this.category,
    required this.location,
    required this.peersCount,
    required this.healthPercentage,
    required this.revenue,
    required this.tags,
    required this.founderName,
    required this.directorName,
    required this.chairName,
    this.chairs = const [],
    this.founders = const [],
    this.directors = const [],
    required this.status,
    this.launchDate,
    this.circleImageUrl,
    this.coverImageUrl,
    this.description,
    this.stage,
    this.meetingFrequency = 'Monthly',
    this.meetingMode = 'Offline',
  });

  /// Returns the effective cover banner image URL if available.
  String? get effectiveCoverUrl {
    final c = coverImageUrl?.trim();
    if (c != null && c.isNotEmpty) {
      return c;
    }
    return null;
  }

  /// Returns the effective circle logo URL if available.
  String? get effectiveLogoUrl {
    final l = circleImageUrl?.trim();
    if (l != null && l.isNotEmpty) {
      return l;
    }
    return null;
  }

  factory CircleTeamModel.fromJson(Map<String, dynamic> json) {
    final tagsList = <String>[];
    if (json['tags'] is List) {
      for (final t in json['tags']) {
        tagsList.add(t.toString());
      }
    } else {
      final cat = json['category']?.toString();
      final loc = json['location']?.toString();
      if (cat != null && cat.isNotEmpty) tagsList.add(cat);
      if (loc != null && loc.isNotEmpty) tagsList.add(loc);
    }

    final leadership =
        json['leadership'] is Map ? (json['leadership'] as Map<String, dynamic>) : null;

    // Parse Chairs (Supports up to 3 Chairs)
    final chairsList = <CircleLeaderModel>[];
    final dynamic rawChairs = json['chairs'] ?? leadership?['chairs'];
    if (rawChairs is List) {
      for (final c in rawChairs) {
        if (c is Map<String, dynamic>) {
          chairsList.add(
            CircleLeaderModel.fromJson(c, defaultRole: 'Circle Chair'),
          );
        } else if (c is String && c.trim().isNotEmpty) {
          chairsList.add(
            CircleLeaderModel(name: c.trim(), role: 'Circle Chair'),
          );
        }
      }
    } else if (json['chair_name'] != null &&
        json['chair_name'].toString().trim().isNotEmpty) {
      chairsList.add(
        CircleLeaderModel(
          name: json['chair_name'].toString().trim(),
          role: 'Circle Chair',
        ),
      );
    }

    // Parse Founders
    final foundersList = <CircleLeaderModel>[];
    final dynamic rawFounders = json['founders'] ?? leadership?['founders'];
    if (rawFounders is List) {
      for (final f in rawFounders) {
        if (f is Map<String, dynamic>) {
          foundersList.add(
            CircleLeaderModel.fromJson(f, defaultRole: 'Circle Founder'),
          );
        } else if (f is String && f.trim().isNotEmpty) {
          foundersList.add(
            CircleLeaderModel(name: f.trim(), role: 'Circle Founder'),
          );
        }
      }
    } else if (json['founder_name'] != null &&
        json['founder_name'].toString().trim().isNotEmpty) {
      foundersList.add(
        CircleLeaderModel(
          name: json['founder_name'].toString().trim(),
          role: 'Circle Founder',
        ),
      );
    }

    // Parse Directors
    final directorsList = <CircleLeaderModel>[];
    final dynamic rawDirectors = json['directors'] ?? leadership?['directors'];
    if (rawDirectors is List) {
      for (final d in rawDirectors) {
        if (d is Map<String, dynamic>) {
          directorsList.add(
            CircleLeaderModel.fromJson(d, defaultRole: 'Circle Director'),
          );
        } else if (d is String && d.trim().isNotEmpty) {
          directorsList.add(
            CircleLeaderModel(name: d.trim(), role: 'Circle Director'),
          );
        }
      }
    } else if (json['director_name'] != null &&
        json['director_name'].toString().trim().isNotEmpty) {
      directorsList.add(
        CircleLeaderModel(
          name: json['director_name'].toString().trim(),
          role: 'Circle Director',
        ),
      );
    }

    final rawChair = chairsList.isNotEmpty
        ? chairsList.map((c) => c.name).join(', ')
        : (json['chair_name'] as String? ?? '');
    final rawFounder = foundersList.isNotEmpty
        ? foundersList.map((f) => f.name).join(', ')
        : (json['founders_count'] != null
            ? '${json['founders_count']} Founders'
            : (json['founder_name'] as String? ?? ''));
    final rawDirector = directorsList.isNotEmpty
        ? directorsList.map((d) => d.name).join(', ')
        : (json['director_name'] as String? ?? '');

    // Parse Cover Image
    final dynamic rawCover = json['cover_image'];
    String? coverImg;
    if (rawCover is Map) {
      coverImg = rawCover['url']?.toString();
    } else if (rawCover is String && rawCover.trim().isNotEmpty) {
      coverImg = rawCover.trim();
    } else {
      coverImg = json['cover_image_url']?.toString();
    }

    // Parse Circle Image (Logo)
    final dynamic rawImage = json['circle_logo'] ?? json['circle_image'];
    String? circleImg;
    if (rawImage is Map) {
      circleImg = rawImage['url']?.toString();
    } else if (rawImage is String && rawImage.trim().isNotEmpty) {
      circleImg = rawImage.trim();
    } else {
      circleImg = json['circle_image_url']?.toString() ??
          json['logo_url']?.toString() ??
          json['image_url']?.toString();
    }

    return CircleTeamModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      location: json['location'] as String? ?? '',
      peersCount: json['peers_count'] as int? ?? 0,
      healthPercentage: json['health_percentage'] as int? ?? 0,
      revenue: json['revenue']?.toString() ?? '₹0.0',
      tags: tagsList,
      founderName: rawFounder,
      directorName: rawDirector,
      chairName: rawChair,
      chairs: chairsList,
      founders: foundersList,
      directors: directorsList,
      status: json['status'] as String? ?? 'Active',
      launchDate: json['launch_date'] as String?,
      circleImageUrl: circleImg,
      coverImageUrl: coverImg,
      description: json['description'] as String?,
      stage: json['stage'] as String? ?? 'Active Circle',
      meetingFrequency: json['meeting_frequency'] as String? ?? 'Monthly',
      meetingMode: json['meeting_mode'] as String? ?? 'Offline',
    );
  }

  CircleTeamModel copyWith({
    String? id,
    String? name,
    String? category,
    String? location,
    int? peersCount,
    int? healthPercentage,
    String? revenue,
    List<String>? tags,
    String? founderName,
    String? directorName,
    String? chairName,
    List<CircleLeaderModel>? chairs,
    List<CircleLeaderModel>? founders,
    List<CircleLeaderModel>? directors,
    String? status,
    String? launchDate,
    String? circleImageUrl,
    String? coverImageUrl,
    String? description,
    String? stage,
    String? meetingFrequency,
    String? meetingMode,
  }) {
    return CircleTeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      location: location ?? this.location,
      peersCount: peersCount ?? this.peersCount,
      healthPercentage: healthPercentage ?? this.healthPercentage,
      revenue: revenue ?? this.revenue,
      tags: tags ?? this.tags,
      founderName: founderName ?? this.founderName,
      directorName: directorName ?? this.directorName,
      chairName: chairName ?? this.chairName,
      chairs: chairs ?? this.chairs,
      founders: founders ?? this.founders,
      directors: directors ?? this.directors,
      status: status ?? this.status,
      launchDate: launchDate ?? this.launchDate,
      circleImageUrl: circleImageUrl ?? this.circleImageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      description: description ?? this.description,
      stage: stage ?? this.stage,
      meetingFrequency: meetingFrequency ?? this.meetingFrequency,
      meetingMode: meetingMode ?? this.meetingMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'location': location,
        'peers_count': peersCount,
        'health_percentage': healthPercentage,
        'revenue': revenue,
        'tags': tags,
        'founder_name': founderName,
        'director_name': directorName,
        'chair_name': chairName,
        'chairs': chairs.map((c) => c.toJson()).toList(),
        'founders': founders.map((f) => f.toJson()).toList(),
        'directors': directors.map((d) => d.toJson()).toList(),
        'status': status,
        'launch_date': launchDate,
        'circle_image': circleImageUrl != null ? {'url': circleImageUrl} : null,
        'circle_image_url': circleImageUrl,
        'cover_image': coverImageUrl != null ? {'url': coverImageUrl} : null,
        'cover_image_url': coverImageUrl,
        'description': description,
        'stage': stage,
        'meeting_frequency': meetingFrequency,
        'meeting_mode': meetingMode,
      };
}
