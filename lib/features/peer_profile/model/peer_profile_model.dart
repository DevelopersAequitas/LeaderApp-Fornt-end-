class PeerMeetingModel {
  final String day;
  final String month;
  final String title;
  final String timeLocation;
  final String status; // "Confirmed", "Open", "Planned"

  const PeerMeetingModel({
    required this.day,
    required this.month,
    required this.title,
    required this.timeLocation,
    required this.status,
  });
}

class PeerActivityModel {
  final String iconType; // "arrows", "speaker", "star", "trophy", "target"
  final String title;
  final String subtitle;
  final String time;

  const PeerActivityModel({
    required this.iconType,
    required this.title,
    required this.subtitle,
    required this.time,
  });
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
}
