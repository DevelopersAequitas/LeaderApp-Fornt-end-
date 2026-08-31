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

    final nameParts = author.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    final initials = nameParts.length > 1
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (author.length >= 2 ? author.substring(0, 2).toUpperCase() : author.toUpperCase());

    return PeerTestimonialModel(
      id: json['id']?.toString() ?? '',
      authorName: author.isNotEmpty ? author : 'Circle Peer',
      authorInitials: initials.isNotEmpty ? initials : 'P',
      subtitle: subtitle,
      rating: json['rating'] as int? ?? 5,
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
  final List<String> tags;
  final String? phone;
  final String? email;
  final String? whatsapp;
  final String? linkedin;
  final List<PeerMeetingModel> meetings;
  final List<PeerActivityModel> activities;
  final List<PeerTestimonialModel> testimonials;

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
    this.tags = const [],
    this.phone,
    this.email,
    this.whatsapp,
    this.linkedin,
    this.meetings = const [],
    this.activities = const [],
    this.testimonials = const [],
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

    final contact = json['contact'] is Map ? (json['contact'] as Map) : null;
    final metrics = json['metrics'] is Map ? (json['metrics'] as Map) : json;

    return PeerProfileDetailModel(
      bio: json['bio'] as String? ?? '',
      birthday: json['birthday'] as String? ?? '',
      anniversary: json['anniversary'] as String? ?? '',
      joinedDate: json['joined_date'] as String? ?? '',
      dealsClosed: metrics['deals_closed']?.toString() ?? json['deals_closed']?.toString() ?? '₹0.0',
      dealsGiven: metrics['deals_given']?.toString() ?? '₹0.0',
      dealsReceived: metrics['deals_received']?.toString() ?? '₹0.0',
      referralsGiven: metrics['referrals_given'] as int? ?? json['referrals_given'] as int? ?? 0,
      referralsReceived: metrics['referrals_received'] as int? ?? json['referrals_received'] as int? ?? 0,
      p2pSessions: metrics['p2p_sessions'] as int? ?? metrics['p2p_meetings'] as int? ?? json['p2p_sessions'] as int? ?? 0,
      coinsEarned: metrics['coins_earned'] as int? ?? metrics['coins'] as int? ?? json['coins_earned'] as int? ?? 0,
      attendanceRate: metrics['attendance_percentage']?.toString() ?? metrics['attendance_rate']?.toString() ?? json['attendance_rate']?.toString() ?? '0%',
      impactCount: metrics['impact_count'] as int? ?? metrics['impact'] as int? ?? json['impact_count'] as int? ?? 0,
      tags: tagsList,
      phone: contact?['phone']?.toString() ?? json['phone']?.toString(),
      email: contact?['email']?.toString() ?? json['email']?.toString(),
      whatsapp: contact?['whatsapp']?.toString(),
      linkedin: contact?['linkedin']?.toString(),
      meetings: meetingsList,
      activities: activitiesList,
      testimonials: testimonialsList,
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
