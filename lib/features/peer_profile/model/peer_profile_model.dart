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
    this.type = 'Circle Meeting',
  });

  factory PeerMeetingModel.fromJson(Map<String, dynamic> json) {
    return PeerMeetingModel(
      id: json['id']?.toString() ?? '',
      day: json['day'] as String? ?? '',
      month: json['month'] as String? ?? '',
      title: json['title'] as String? ?? 'Circle Meeting',
      timeLocation: json['time_location'] as String? ?? json['location'] as String? ?? '',
      status: json['status'] as String? ?? 'Confirmed',
      type: json['type'] as String? ?? 'Circle Meeting',
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
      iconType: json['icon_type'] as String? ?? 'star',
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

class PeerTestimonialModel {
  final String authorName;
  final String authorInitials;
  final String subtitle;
  final int rating;
  final String content;

  const PeerTestimonialModel({
    required this.authorName,
    required this.authorInitials,
    required this.subtitle,
    required this.rating,
    required this.content,
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

    final nameParts = author.trim().split(' ');
    final initials = nameParts.length > 1
        ? '${nameParts[0].isNotEmpty ? nameParts[0][0] : ""}${nameParts[1].isNotEmpty ? nameParts[1][0] : ""}'
        : (author.length >= 2 ? author.substring(0, 2).toUpperCase() : author.toUpperCase());

    return PeerTestimonialModel(
      authorName: author.isNotEmpty ? author : 'Circle Peer',
      authorInitials: initials.isNotEmpty ? initials : 'P',
      subtitle: subtitle,
      rating: json['rating'] as int? ?? 5,
      content: json['content'] as String? ?? json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'author_name': authorName,
        'author_initials': authorInitials,
        'subtitle': subtitle,
        'rating': rating,
        'content': content,
      };
}

class PeerProfileDetailModel {
  final String dealsClosed;
  final int referralsGiven;
  final int p2pSessions;
  final int coinsEarned;
  final String attendanceRate;
  final String birthday;
  final String anniversary;
  final List<PeerMeetingModel> meetings;
  final List<PeerActivityModel> activities;
  final List<PeerTestimonialModel> testimonials;

  const PeerProfileDetailModel({
    required this.dealsClosed,
    required this.referralsGiven,
    required this.p2pSessions,
    required this.coinsEarned,
    required this.attendanceRate,
    required this.birthday,
    required this.anniversary,
    required this.meetings,
    required this.activities,
    required this.testimonials,
  });

  factory PeerProfileDetailModel.fromJson(Map<String, dynamic> json) {
    final meetingsList = <PeerMeetingModel>[];
    if (json['meetings'] is List) {
      for (final m in json['meetings']) {
        meetingsList.add(PeerMeetingModel.fromJson(m as Map<String, dynamic>));
      }
    }

    final activitiesList = <PeerActivityModel>[];
    if (json['activities'] is List) {
      for (final a in json['activities']) {
        activitiesList.add(PeerActivityModel.fromJson(a as Map<String, dynamic>));
      }
    }

    final testimonialsList = <PeerTestimonialModel>[];
    if (json['testimonials'] is List) {
      for (final t in json['testimonials']) {
        testimonialsList.add(PeerTestimonialModel.fromJson(t as Map<String, dynamic>));
      }
    }

    final metrics = json['metrics'] is Map ? (json['metrics'] as Map) : json;

    return PeerProfileDetailModel(
      dealsClosed: metrics['deals_closed']?.toString() ?? json['deals_closed']?.toString() ?? '₹0',
      referralsGiven: metrics['referrals_given'] as int? ?? json['referrals_given'] as int? ?? 0,
      p2pSessions: metrics['p2p_sessions'] as int? ?? metrics['p2p_meetings'] as int? ?? json['p2p_sessions'] as int? ?? 0,
      coinsEarned: metrics['coins_earned'] as int? ?? metrics['coins'] as int? ?? json['coins_earned'] as int? ?? 0,
      attendanceRate: metrics['attendance_percentage']?.toString() ?? metrics['attendance_rate']?.toString() ?? json['attendance_rate']?.toString() ?? '0%',
      birthday: json['birthday'] as String? ?? '',
      anniversary: json['anniversary'] as String? ?? '',
      meetings: meetingsList,
      activities: activitiesList,
      testimonials: testimonialsList,
    );
  }


  Map<String, dynamic> toJson() => {
        'deals_closed': dealsClosed,
        'referrals_given': referralsGiven,
        'p2p_sessions': p2pSessions,
        'coins_earned': coinsEarned,
        'attendance_rate': attendanceRate,
        'birthday': birthday,
        'anniversary': anniversary,
        'meetings': meetings.map((m) => m.toJson()).toList(),
        'activities': activities.map((a) => a.toJson()).toList(),
        'testimonials': testimonials.map((t) => t.toJson()).toList(),
      };
}
