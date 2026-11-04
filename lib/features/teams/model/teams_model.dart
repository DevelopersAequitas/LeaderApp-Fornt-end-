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

/// Detailed model representing circle meeting cadence & schedule settings.
class CircleCadenceModel {
  final String frequency; // "Monthly", "Weekly", "Bi-Weekly", "Quarterly"
  final String mode; // "Offline" / "In-Person", "Online", "Hybrid"
  final String day; // "Monday", "Tuesday", etc.
  final String ordinal; // "1st", "2nd", "3rd", "4th", "Last"
  final String weekOfMonth; // "week_1", "week_2", etc.
  final String startTime; // "02:00"
  final String endTime; // "03:00"
  final String startTimeFormatted; // "02:00 AM"
  final String endTimeFormatted; // "03:00 AM"
  final String timeRange; // "02:00 AM - 03:00 AM" or "02:00 to 03:00"
  final String venue;
  final String link;
  final String cadenceText; // e.g. "1st Tuesday from 02:00 to 03:00 (Monthly • Offline)"
  final String cadenceSummary; // e.g. "1st Tuesday · Monthly"
  final String? upcomingDate; // "2026-11-03"
  final String? upcomingDisplay; // "1st Tue, 3 Nov • 02:00 AM"

  const CircleCadenceModel({
    this.frequency = 'Monthly',
    this.mode = 'Offline',
    this.day = '',
    this.ordinal = '',
    this.weekOfMonth = '',
    this.startTime = '',
    this.endTime = '',
    this.startTimeFormatted = '',
    this.endTimeFormatted = '',
    this.timeRange = '',
    this.venue = '',
    this.link = '',
    this.cadenceText = '',
    this.cadenceSummary = '',
    this.upcomingDate,
    this.upcomingDisplay,
  });

  /// True if a concrete recurring schedule (day + ordinal or weekly day) is defined.
  bool get hasSchedule => day.isNotEmpty || startTime.isNotEmpty;

  /// Returns user-friendly schedule string like "1st Tuesday of the month" or "Every Tuesday"
  String get scheduleDescription {
    if (day.isEmpty) {
      return frequency;
    }
    final isWeekly = frequency.toLowerCase().contains('week');
    if (isWeekly) {
      return 'Every $day';
    }
    if (ordinal.isNotEmpty) {
      return '$ordinal $day of the month';
    }
    return '$day ($frequency)';
  }

  /// Compact schedule badge text like "1st Tue • 02:00 - 03:00"
  String get compactBadgeText {
    final parts = <String>[];
    if (ordinal.isNotEmpty && day.isNotEmpty) {
      final shortDay = day.length > 3 ? day.substring(0, 3) : day;
      parts.add('$ordinal $shortDay');
    } else if (day.isNotEmpty) {
      parts.add(day);
    } else {
      parts.add(frequency);
    }

    if (timeRange.isNotEmpty) {
      parts.add(timeRange);
    } else if (startTimeFormatted.isNotEmpty) {
      parts.add(startTimeFormatted);
    } else if (startTime.isNotEmpty) {
      parts.add(startTime);
    }
    return parts.join(' • ');
  }

  factory CircleCadenceModel.fromJson(Map<String, dynamic> json) {
    // 1. Direct cadence object if nested
    final Map<String, dynamic> data = json['cadence'] is Map<String, dynamic>
        ? json['cadence'] as Map<String, dynamic>
        : (json['cadence'] is Map ? Map<String, dynamic>.from(json['cadence'] as Map) : json);

    // 2. meeting_repeat fallback
    final repeat = data['meeting_repeat'] is Map
        ? Map<String, dynamic>.from(data['meeting_repeat'] as Map)
        : (json['meeting_repeat'] is Map
            ? Map<String, dynamic>.from(json['meeting_repeat'] as Map)
            : null);

    // 3. calendar settings fallback
    final calendar = json['calendar'] is Map ? json['calendar'] as Map : null;
    final calSettings = calendar?['settings'] is Map ? calendar!['settings'] as Map : null;

    final freqRaw = data['frequency']?.toString() ??
        data['meeting_frequency']?.toString() ??
        repeat?['frequency']?.toString() ??
        calSettings?['meeting_frequency']?.toString() ??
        'Monthly';
    final freq = freqRaw.isNotEmpty
        ? (freqRaw[0].toUpperCase() + freqRaw.substring(1).toLowerCase())
        : 'Monthly';

    final modeRaw = data['mode']?.toString() ??
        data['meeting_mode']?.toString() ??
        calSettings?['meeting_mode']?.toString() ??
        'Offline';
    final mode = modeRaw.toLowerCase().contains('online')
        ? 'Online'
        : (modeRaw.toLowerCase().contains('hybrid') ? 'Hybrid' : 'Offline');

    String normDay(String raw) {
      final s = raw.trim().toLowerCase();
      if (s.startsWith('mon')) return 'Monday';
      if (s.startsWith('tue')) return 'Tuesday';
      if (s.startsWith('wed')) return 'Wednesday';
      if (s.startsWith('thu')) return 'Thursday';
      if (s.startsWith('fri')) return 'Friday';
      if (s.startsWith('sat')) return 'Saturday';
      if (s.startsWith('sun')) return 'Sunday';
      return raw.trim().isNotEmpty
          ? (raw.trim()[0].toUpperCase() + raw.trim().substring(1).toLowerCase())
          : '';
    }

    final rawDay = data['day']?.toString() ??
        data['meeting_day']?.toString() ??
        repeat?['weekday']?.toString() ??
        repeat?['day_of_week']?.toString() ??
        calendar?['default_meet_day']?.toString() ??
        '';
    final day = normDay(rawDay);

    String normOrdinal(String raw) {
      final s = raw.trim().toLowerCase();
      if (s == 'first' || s == '1' || s == 'week_1') return '1st';
      if (s == 'second' || s == '2' || s == 'week_2') return '2nd';
      if (s == 'third' || s == '3' || s == 'week_3') return '3rd';
      if (s == 'fourth' || s == '4' || s == 'week_4') return '4th';
      if (s == 'fifth' || s == '5' || s == 'last') return '5th';
      if (s.endsWith('st') || s.endsWith('nd') || s.endsWith('rd') || s.endsWith('th')) {
        return raw.trim();
      }
      return raw.trim();
    }

    final rawOrd = data['ordinal']?.toString() ??
        data['meeting_ordinal']?.toString() ??
        repeat?['ordinal_text']?.toString() ??
        calendar?['monthly_rule']?.toString() ??
        '';
    final ordinal = normOrdinal(rawOrd);

    String normWeekLabel(String raw) {
      final s = raw.trim().toLowerCase();
      if (s == 'week_1' || s == '1') return 'Week 1';
      if (s == 'week_2' || s == '2') return 'Week 2';
      if (s == 'week_3' || s == '3') return 'Week 3';
      if (s == 'week_4' || s == '4') return 'Week 4';
      if (s == 'week_4_provisional') return 'Week 4 (provisional)';
      if (s == 'every_week') return 'Every Week';
      return raw.trim();
    }

    final rawWeek = data['week_of_month']?.toString() ??
        data['meeting_week_of_month']?.toString() ??
        repeat?['week_of_month']?.toString() ??
        calendar?['week_of_month']?.toString() ??
        '';
    final weekOfMonth = rawWeek.isNotEmpty ? rawWeek : (ordinal.isNotEmpty ? ordinal : 'week_1');
    final weekLabel = normWeekLabel(weekOfMonth);

    String startTime = data['start_time']?.toString() ??
        data['meeting_time']?.toString() ??
        data['meeting_start_time']?.toString() ??
        repeat?['start_time_local']?.toString() ??
        repeat?['time_local']?.toString() ??
        repeat?['start_time']?.toString() ??
        calendar?['start_time_local']?.toString() ??
        '';

    String endTime = data['end_time']?.toString() ??
        data['meeting_end_time']?.toString() ??
        repeat?['end_time_local']?.toString() ??
        repeat?['end_time']?.toString() ??
        calendar?['end_time_local']?.toString() ??
        '';

    // Format 12-hour strings if needed
    String formatTime12(String raw) {
      final t = raw.trim();
      if (t.isEmpty) return '';
      final parts = t.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]);
        final m = parts[1].padLeft(2, '0');
        if (h != null) {
          final ampm = h >= 12 ? 'PM' : 'AM';
          final h12 = h % 12 == 0 ? 12 : h % 12;
          final hStr = h12.toString().padLeft(2, '0');
          return '$hStr:$m $ampm';
        }
      }
      return t;
    }

    String startFmt = data['start_time_formatted']?.toString() ??
        data['meeting_time_formatted']?.toString() ??
        '';
    if (startFmt.isEmpty && startTime.isNotEmpty) {
      startFmt = formatTime12(startTime);
    }

    String endFmt = data['end_time_formatted']?.toString() ??
        data['meeting_end_time_formatted']?.toString() ??
        '';
    if (endFmt.isEmpty && endTime.isNotEmpty) {
      endFmt = formatTime12(endTime);
    }

    String timeRange = data['time_range']?.toString() ??
        data['meeting_time_range']?.toString() ??
        '';
    if (timeRange.isEmpty) {
      if (startFmt.isNotEmpty && endFmt.isNotEmpty) {
        timeRange = '$startFmt - $endFmt';
      } else if (startTime.isNotEmpty && endTime.isNotEmpty) {
        timeRange = '$startTime to $endTime';
      } else if (startFmt.isNotEmpty) {
        timeRange = startFmt;
      }
    }

    final venue = data['venue']?.toString() ??
        data['meeting_venue']?.toString() ??
        calSettings?['meeting_venue']?.toString() ??
        calSettings?['meeting_address']?.toString() ??
        '';

    final link = data['link']?.toString() ??
        data['meeting_link']?.toString() ??
        calSettings?['meeting_link']?.toString() ??
        '';

    // Build cadence text matching Web Admin Step 4:
    // e.g. "Week 1 • Tuesdays From 02:00 AM To 03:00 AM (Monthly • Offline)"
    String cadenceText = data['cadence_text']?.toString() ?? '';
    final pluralDay = day.isNotEmpty ? '${day}s' : 'Meetings';
    final timeStr = (startFmt.isNotEmpty && endFmt.isNotEmpty)
        ? 'From $startFmt To $endFmt'
        : (startTime.isNotEmpty && endTime.isNotEmpty ? 'From $startTime To $endTime' : startFmt);
    if (cadenceText.isEmpty || !cadenceText.contains('•')) {
      final lead = weekLabel.isNotEmpty ? weekLabel : (ordinal.isNotEmpty ? '$ordinal Week' : 'Monthly');
      cadenceText = '$lead • $pluralDay $timeStr ($freq • $mode)';
    }

    // e.g. "1st Tuesday · Monthly"
    String cadenceSummary = data['cadence_summary']?.toString() ?? '';
    if (cadenceSummary.isEmpty || !cadenceSummary.contains('·')) {
      final ordPart = ordinal.isNotEmpty ? '$ordinal ' : '';
      cadenceSummary = '$ordPart$day · $freq';
    }

    final upcoming = data['upcoming_meeting'] is Map ? data['upcoming_meeting'] as Map : null;
    final upDate = upcoming?['date']?.toString();
    final upDisp = upcoming?['display']?.toString();

    return CircleCadenceModel(
      frequency: freq,
      mode: mode,
      day: day,
      ordinal: ordinal,
      weekOfMonth: weekOfMonth,
      startTime: startTime,
      endTime: endTime,
      startTimeFormatted: startFmt,
      endTimeFormatted: endFmt,
      timeRange: timeRange,
      venue: venue,
      link: link,
      cadenceText: cadenceText,
      cadenceSummary: cadenceSummary,
      upcomingDate: upDate,
      upcomingDisplay: upDisp,
    );
  }

  Map<String, dynamic> toJson() => {
        'frequency': frequency,
        'mode': mode,
        'day': day,
        'ordinal': ordinal,
        'week_of_month': weekOfMonth,
        'start_time': startTime,
        'end_time': endTime,
        'start_time_formatted': startTimeFormatted,
        'end_time_formatted': endTimeFormatted,
        'time_range': timeRange,
        'venue': venue,
        'link': link,
        'cadence_text': cadenceText,
        'cadence_summary': cadenceSummary,
        'upcoming_date': upcomingDate,
        'upcoming_display': upcomingDisplay,
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
  final CircleCadenceModel? cadence;

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
    this.cadence,
  });

  /// Effective cadence summary, e.g. "1st Tuesday · Monthly"
  String get effectiveCadenceSummary =>
      cadence?.cadenceSummary.isNotEmpty == true
          ? cadence!.cadenceSummary
          : (cadence?.hasSchedule == true
              ? cadence!.scheduleDescription
              : meetingFrequency);

  /// Effective schedule cadence text e.g. "1st Tuesday from 02:00 to 03:00 (Monthly • Offline)"
  String get effectiveCadenceText =>
      cadence?.cadenceText.isNotEmpty == true
          ? cadence!.cadenceText
          : '$effectiveCadenceSummary ($meetingMode)';

  /// Effective conclave time range e.g. "02:00 AM - 03:00 AM" or "02:00 - 03:00"
  String get effectiveMeetingTimeRange =>
      cadence?.timeRange.isNotEmpty == true
          ? cadence!.timeRange
          : (cadence?.startTime.isNotEmpty == true ? cadence!.startTime : '');

  /// Returns the effective cover banner image URL if available and distinct from circle logo.
  String? get effectiveCoverUrl {
    final c = coverImageUrl?.trim();
    if (c != null && c.isNotEmpty) {
      return c;
    }
    final l = circleImageUrl?.trim();
    if (l != null && l.isNotEmpty) {
      return l;
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
    final dynamic rawCover = json['cover_image'] ?? json['cover'] ?? json['banner'];
    String? coverImg;
    if (rawCover is Map) {
      coverImg = rawCover['url']?.toString();
    } else if (rawCover is String && rawCover.trim().isNotEmpty) {
      coverImg = rawCover.trim();
    } else {
      coverImg = json['cover_image_url']?.toString() ??
          json['cover_url']?.toString() ??
          json['banner_url']?.toString();
    }
    if ((coverImg == null || coverImg.isEmpty) && json['cover_file_id'] != null) {
      final fid = json['cover_file_id'].toString().trim();
      if (fid.isNotEmpty) {
        coverImg = 'https://dev.peersunity.com/api/v1/files/$fid';
      }
    }

    // Parse Circle Image (Logo)
    final dynamic rawImage = json['circle_logo'] ?? json['logo'] ?? json['circle_image'];
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
    if ((circleImg == null || circleImg.isEmpty) && (json['circle_image_file_id'] != null || json['logo_file_id'] != null)) {
      final fid = (json['circle_image_file_id'] ?? json['logo_file_id']).toString().trim();
      if (fid.isNotEmpty) {
        circleImg = 'https://dev.peersunity.com/api/v1/files/$fid';
      }
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
      cadence: CircleCadenceModel.fromJson(json),
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
    CircleCadenceModel? cadence,
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
      cadence: cadence ?? this.cadence,
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
