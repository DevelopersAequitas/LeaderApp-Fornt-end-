/// Model representing a P2P or circle meeting item in peer profile.
class PeerMeetingModel {
  final String id;
  final String day;
  final String month;
  final String title;
  final String timeLocation;
  final String status;
  final String type;

  const PeerMeetingModel({
    this.id = '',
    required this.day,
    required this.month,
    required this.title,
    required this.timeLocation,
    required this.status,
    this.type = 'P2P Meeting',
  });

  factory PeerMeetingModel.fromJson(Map<String, dynamic> json) {
    return PeerMeetingModel(
      id: json['id']?.toString() ?? '',
      day: json['day'] as String? ?? '',
      month: json['month'] as String? ?? '',
      title: json['title'] as String? ?? 'P2P Meeting',
      timeLocation: json['time_location'] as String? ?? json['location'] as String? ?? '',
      status: json['status'] as String? ?? 'Confirmed',
      type: json['type'] as String? ?? 'P2P Meeting',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'day': day,
        'month': month,
        'title': title,
        'time_location': timeLocation,
        'status': status,
        'type': type,
      };
}

/// Model representing a peer's recent activity item.
class PeerActivityModel {
  final String id;
  final String iconType;
  final String title;
  final String subtitle;
  final String time;

  const PeerActivityModel({
    this.id = '',
    required this.iconType,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  factory PeerActivityModel.fromJson(Map<String, dynamic> json) {
    return PeerActivityModel(
      id: json['id']?.toString() ?? '',
      iconType: json['icon_type'] as String? ?? 'speaker',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      time: json['created_at'] as String? ?? json['time'] as String? ?? 'Just now',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'icon_type': iconType,
        'title': title,
        'subtitle': subtitle,
        'created_at': time,
      };
}

/// Model representing a testimonial written for or received by the peer.
class PeerTestimonialModel {
  final String id;
  final String authorName;
  final String authorInitials;
  final String subtitle;
  final int rating;
  final String content;
  final String date;

  const PeerTestimonialModel({
    this.id = '',
    required this.authorName,
    required this.authorInitials,
    required this.subtitle,
    required this.rating,
    required this.content,
    this.date = '',
  });

  factory PeerTestimonialModel.fromJson(Map<String, dynamic> json) {
    String author = '';
    final rawAuthor = json['author_name'] ?? json['author'] ?? json['from_name'];
    if (rawAuthor is Map) {
      author = rawAuthor['name']?.toString() ?? rawAuthor['author_name']?.toString() ?? '';
    } else if (rawAuthor is String) {
      author = rawAuthor;
    }

    String subtitle = '';
    final rawSub = json['subtitle'] ?? json['author_role'] ?? json['from_company'] ?? json['circle_name'];
    if (rawSub is Map) {
      subtitle = rawSub['name']?.toString() ?? rawSub['role']?.toString() ?? rawSub['company']?.toString() ?? '';
    } else if (rawSub is String) {
      subtitle = rawSub;
    }

    String initials = json['author_initials']?.toString() ?? '';
    if (initials.isEmpty && author.isNotEmpty) {
      final nameParts = author.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
      initials = nameParts.length > 1
          ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
          : (author.length >= 2 ? author.substring(0, 2).toUpperCase() : author.toUpperCase());
    }

    int ratingVal = 5;
    if (json['rating'] != null) {
      if (json['rating'] is num) {
        ratingVal = (json['rating'] as num).toInt();
      } else {
        ratingVal = int.tryParse(json['rating'].toString()) ?? 5;
      }
    }

    return PeerTestimonialModel(
      id: json['id']?.toString() ?? '',
      authorName: author.isNotEmpty ? author : 'Circle Peer',
      authorInitials: initials.isNotEmpty ? initials : 'P',
      subtitle: subtitle,
      rating: ratingVal,
      content: json['content'] as String? ?? json['message'] as String? ?? '',
      date: json['date'] as String? ?? json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'author_name': authorName,
        'author_initials': authorInitials,
        'subtitle': subtitle,
        'rating': rating,
        'content': content,
        'date': date,
      };
}

/// Comprehensive model encompassing all details, metrics, milestones, and lists for a peer profile.
class PeerProfileDetailModel {
  final String bio;
  final String birthday;
  final String anniversary;
  final String joinedDate;
  final String dealsClosed;
  final String dealsGiven;
  final String dealsReceived;
  final int referralsGiven;
  final int referralsReceived;
  final int p2pSessions;
  final int coinsEarned;
  final String attendanceRate;
  final int impactCount;
  final int introducedPeersCount;
  final List<String> tags;
  final String? phone;
  final String? email;
  final String? whatsapp;
  final String? linkedin;
  final List<PeerMeetingModel> meetings;
  final List<PeerActivityModel> activities;
  final List<PeerTestimonialModel> testimonials;
  final PeerSubscriptionModel? appSubscription;
  final PeerCircleSubscriptionModel? circleSubscription;

  const PeerProfileDetailModel({
    this.bio = '',
    this.birthday = '',
    this.anniversary = '',
    this.joinedDate = '',
    this.dealsClosed = '₹0.0',
    this.dealsGiven = '₹0.0',
    this.dealsReceived = '₹0.0',
    this.referralsGiven = 0,
    this.referralsReceived = 0,
    this.p2pSessions = 0,
    this.coinsEarned = 0,
    this.attendanceRate = '0%',
    this.impactCount = 0,
    this.introducedPeersCount = 0,
    this.tags = const [],
    this.phone,
    this.email,
    this.whatsapp,
    this.linkedin,
    this.meetings = const [],
    this.activities = const [],
    this.testimonials = const [],
    this.appSubscription,
    this.circleSubscription,
  });

  factory PeerProfileDetailModel.fromJson(Map<String, dynamic> json) {
    final meetingsList = <PeerMeetingModel>[];
    if (json['meetings'] is List) {
      for (final m in json['meetings']) {
        if (m is Map<String, dynamic>) {
          meetingsList.add(PeerMeetingModel.fromJson(m));
        } else if (m is Map) {
          meetingsList.add(PeerMeetingModel.fromJson(Map<String, dynamic>.from(m)));
        }
      }
    }

    final activitiesList = <PeerActivityModel>[];
    if (json['activities'] is List) {
      for (final a in json['activities']) {
        if (a is Map<String, dynamic>) {
          activitiesList.add(PeerActivityModel.fromJson(a));
        } else if (a is Map) {
          activitiesList.add(PeerActivityModel.fromJson(Map<String, dynamic>.from(a)));
        }
      }
    }

    final testimonialsList = <PeerTestimonialModel>[];
    if (json['testimonials'] is List) {
      for (final t in json['testimonials']) {
        if (t is Map<String, dynamic>) {
          testimonialsList.add(PeerTestimonialModel.fromJson(t));
        } else if (t is Map) {
          testimonialsList.add(PeerTestimonialModel.fromJson(Map<String, dynamic>.from(t)));
        }
      }
    }

    final tagsList = <String>[];
    if (json['tags'] is List) {
      for (final t in json['tags']) {
        if (t != null && t.toString().isNotEmpty) {
          tagsList.add(t.toString());
        }
      }
    }

    final contact = json['contact'] is Map
        ? (json['contact'] as Map)
        : ((json['data'] is Map && (json['data'] as Map)['contact'] is Map)
            ? ((json['data'] as Map)['contact'] as Map)
            : null);

    final dataMap = json['data'] is Map ? (json['data'] as Map) : null;
    final metrics = json['metrics'] is Map
        ? (json['metrics'] as Map)
        : (dataMap?['metrics'] is Map
            ? (dataMap!['metrics'] as Map)
            : null);

    int parseInt(List<String> keys) {
      for (final key in keys) {
        final val = (metrics != null ? metrics[key] : null) ??
            (dataMap != null ? dataMap[key] : null) ??
            json[key];
        if (val == null) continue;
        if (val is int) return val;
        if (val is num) return val.toInt();
        if (val is String) {
          final parsed = int.tryParse(val.replaceAll(',', '').trim());
          if (parsed != null) return parsed;
        }
        if (val is List) return val.length;
      }
      return 0;
    }

    String parseString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final val = (metrics != null ? metrics[key] : null) ??
            (dataMap != null ? dataMap[key] : null) ??
            json[key];
        if (val == null) continue;
        final str = val.toString().trim();
        if (str.isNotEmpty && str != 'null') return str;
      }
      return fallback;
    }

    return PeerProfileDetailModel(
      bio: parseString(['bio', 'about']),
      birthday: parseString(['birthday', 'birth_date', 'date_of_birth']),
      anniversary: parseString(['anniversary', 'anniversary_date']),
      joinedDate: parseString(['joined_date', 'created_at', 'joined_at']),
      dealsClosed: parseString(['deals_closed', 'closed_deals', 'total_deals_value'], fallback: '₹0.0'),
      dealsGiven: parseString(['deals_given', 'given_deals'], fallback: '₹0.0'),
      dealsReceived: parseString(['deals_received', 'received_deals'], fallback: '₹0.0'),
      referralsGiven: parseInt(['referrals_given', 'given_referrals', 'referral_given_count']),
      referralsReceived: parseInt(['referrals_received', 'received_referrals', 'referral_received_count']),
      p2pSessions: parseInt(['p2p_sessions', 'p2p_meetings', 'p2p_count', 'p2p_meeting_count', 'p2p']),
      coinsEarned: parseInt(['coins_earned', 'coins', 'total_coins', 'coins_count']),
      attendanceRate: parseString(['attendance_percentage', 'attendance_rate', 'attendance'], fallback: '0%'),
      impactCount: parseInt(['impact_count', 'impact', 'impacts']),
      introducedPeersCount: parseInt([
        'introduced_peers_count',
        'members_introduced_count',
        'peers_introduced_count',
        'introduced_peers',
        'members_introduced',
        'peers_introduced',
        'introduced_peers_list',
      ]),
      tags: tagsList,
      phone: contact?['phone']?.toString() ?? parseString(['phone', 'mobile']),
      email: contact?['email']?.toString() ?? parseString(['email']),
      whatsapp: contact?['whatsapp']?.toString() ?? parseString(['whatsapp']),
      linkedin: contact?['linkedin']?.toString() ?? parseString(['linkedin']),
      meetings: meetingsList,
      activities: activitiesList,
      testimonials: testimonialsList,
    );
  }

  PeerProfileDetailModel copyWith({
    String? bio,
    String? birthday,
    String? anniversary,
    String? joinedDate,
    String? dealsClosed,
    String? dealsGiven,
    String? dealsReceived,
    int? referralsGiven,
    int? referralsReceived,
    int? p2pSessions,
    int? coinsEarned,
    String? attendanceRate,
    int? impactCount,
    int? introducedPeersCount,
    List<String>? tags,
    String? phone,
    String? email,
    String? whatsapp,
    String? linkedin,
    List<PeerMeetingModel>? meetings,
    List<PeerActivityModel>? activities,
    List<PeerTestimonialModel>? testimonials,
    PeerSubscriptionModel? appSubscription,
    PeerCircleSubscriptionModel? circleSubscription,
  }) {
    return PeerProfileDetailModel(
      bio: bio ?? this.bio,
      birthday: birthday ?? this.birthday,
      anniversary: anniversary ?? this.anniversary,
      joinedDate: joinedDate ?? this.joinedDate,
      dealsClosed: dealsClosed ?? this.dealsClosed,
      dealsGiven: dealsGiven ?? this.dealsGiven,
      dealsReceived: dealsReceived ?? this.dealsReceived,
      referralsGiven: referralsGiven ?? this.referralsGiven,
      referralsReceived: referralsReceived ?? this.referralsReceived,
      p2pSessions: p2pSessions ?? this.p2pSessions,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      impactCount: impactCount ?? this.impactCount,
      introducedPeersCount: introducedPeersCount ?? this.introducedPeersCount,
      tags: tags ?? this.tags,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
      linkedin: linkedin ?? this.linkedin,
      meetings: meetings ?? this.meetings,
      activities: activities ?? this.activities,
      testimonials: testimonials ?? this.testimonials,
      appSubscription: appSubscription ?? this.appSubscription,
      circleSubscription: circleSubscription ?? this.circleSubscription,
    );
  }

  Map<String, dynamic> toJson() => {
        'bio': bio,
        'birthday': birthday,
        'anniversary': anniversary,
        'joined_date': joinedDate,
        'deals_closed': dealsClosed,
        'deals_given': dealsGiven,
        'deals_received': dealsReceived,
        'referrals_given': referralsGiven,
        'referrals_received': referralsReceived,
        'p2p_sessions': p2pSessions,
        'coins_earned': coinsEarned,
        'attendance_rate': attendanceRate,
        'impact_count': impactCount,
        'introduced_peers_count': introducedPeersCount,
        'tags': tags,
        'phone': phone,
        'email': email,
        'whatsapp': whatsapp,
        'linkedin': linkedin,
        'meetings': meetings.map((m) => m.toJson()).toList(),
        'activities': activities.map((a) => a.toJson()).toList(),
        'testimonials': testimonials.map((t) => t.toJson()).toList(),
      };
}

/// Model representing a member badge.
class PeerBadgeModel {
  final String id;
  final String badgeId;
  final String badgeName;
  final String badgeDescription;
  final String badgeImage;
  final String badgeType;
  final String milestoneType;
  final int requiredCount;
  final int achievedCount;
  final String? earnedAt;

  const PeerBadgeModel({
    this.id = '',
    this.badgeId = '',
    this.badgeName = '',
    this.badgeDescription = '',
    this.badgeImage = '',
    this.badgeType = '',
    this.milestoneType = '',
    this.requiredCount = 0,
    this.achievedCount = 0,
    this.earnedAt,
  });

  factory PeerBadgeModel.fromJson(Map<String, dynamic> json) {
    return PeerBadgeModel(
      id: json['id']?.toString() ?? '',
      badgeId: json['badge_id']?.toString() ?? json['id']?.toString() ?? '',
      badgeName: json['badge_name']?.toString() ?? json['name']?.toString() ?? '',
      badgeDescription: json['badge_description']?.toString() ?? json['description']?.toString() ?? '',
      badgeImage: json['badge_image']?.toString() ?? json['image']?.toString() ?? '',
      badgeType: json['badge_type']?.toString() ?? json['type']?.toString() ?? '',
      milestoneType: json['milestone_type']?.toString() ?? '',
      requiredCount: json['required_count'] as int? ?? (int.tryParse(json['required_count']?.toString() ?? '0') ?? 0),
      achievedCount: json['achieved_count'] as int? ?? (int.tryParse(json['achieved_count']?.toString() ?? '0') ?? 0),
      earnedAt: json['earned_at']?.toString(),
    );
  }
}

class PeerSubscriptionModel {
  final String planName;
  final String price;
  final String status;
  final String startDate;
  final String endDate;
  final int daysLeft;

  const PeerSubscriptionModel({
    this.planName = 'App Pro Plan',
    this.price = '₹0',
    this.status = 'active',
    this.startDate = '',
    this.endDate = '',
    this.daysLeft = 0,
  });

  factory PeerSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return PeerSubscriptionModel(
      planName: json['plan_name']?.toString() ?? json['plan']?.toString() ?? 'App Pro Plan',
      price: json['price']?.toString() ?? json['amount']?.toString() ?? '₹0',
      status: json['status']?.toString() ?? 'active',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      daysLeft: json['days_left'] as int? ?? (int.tryParse(json['days_left']?.toString() ?? '0') ?? 0),
    );
  }
}

class PeerCircleSubscriptionModel {
  final String circleName;
  final String amount;
  final String status;
  final String startDate;
  final String endDate;
  final int daysLeft;

  const PeerCircleSubscriptionModel({
    this.circleName = 'Primary Circle',
    this.amount = '₹0',
    this.status = 'active',
    this.startDate = '',
    this.endDate = '',
    this.daysLeft = 0,
  });

  factory PeerCircleSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return PeerCircleSubscriptionModel(
      circleName: json['circle_name']?.toString() ?? json['circle']?.toString() ?? 'Primary Circle',
      amount: json['amount']?.toString() ?? json['price']?.toString() ?? '₹0',
      status: json['status']?.toString() ?? 'active',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      daysLeft: json['days_left'] as int? ?? (int.tryParse(json['days_left']?.toString() ?? '0') ?? 0),
    );
  }
}
