/// Model representing a circle assembly or summit event.
class CircleEventModel {
  final String id;
  final String circleId;
  final String title;
  final String date;
  final String time;
  final String location;
  final String mode; // "In-Person", "Online", "Hybrid"
  final String status; // "Upcoming", "Completed"
  final int attendeesCount;

  const CircleEventModel({
    required this.id,
    this.circleId = '',
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.mode,
    required this.status,
    required this.attendeesCount,
  });

  factory CircleEventModel.fromJson(Map<String, dynamic> json) {
    return CircleEventModel(
      id: json['id']?.toString() ?? '',
      circleId: json['circle_id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Event',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      location: json['location'] as String? ?? '',
      mode: json['mode'] as String? ?? 'In-Person',
      status: json['status'] as String? ?? 'Upcoming',
      attendeesCount: json['attendees_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'circle_id': circleId,
        'title': title,
        'date': date,
        'time': time,
        'location': location,
        'mode': mode,
        'status': status,
        'attendees_count': attendeesCount,
      };
}
