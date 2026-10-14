import '../../peers/model/peer_model.dart';

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
  final List<PeerModel> attendees;

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
    this.attendees = const [],
  });

  factory CircleEventModel.fromJson(Map<String, dynamic> json) {
    int parsedAttendees = 0;
    if (json['attendees_count'] != null) {
      if (json['attendees_count'] is num) {
        parsedAttendees = (json['attendees_count'] as num).toInt();
      } else {
        parsedAttendees = int.tryParse(json['attendees_count'].toString()) ?? 0;
      }
    } else if (json['attendees'] is List) {
      parsedAttendees = (json['attendees'] as List).length;
    }

    String parsedLocation = json['location'] as String? ??
        json['location_text'] as String? ??
        json['venue'] as String? ??
        '';

    String parsedDate = json['date'] as String? ?? '';
    String parsedTime = json['time'] as String? ?? '';

    if (parsedDate.isEmpty && json['start_at'] != null) {
      try {
        final dt = DateTime.parse(json['start_at'].toString()).toLocal();
        parsedDate = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        parsedTime = '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';
      } catch (_) {}
    }

    final attendeesList = <PeerModel>[];
    if (json['attendees'] is List) {
      for (final a in json['attendees']) {
        if (a is Map<String, dynamic>) {
          attendeesList.add(PeerModel.fromJson(a));
        } else if (a is Map) {
          attendeesList.add(PeerModel.fromJson(Map<String, dynamic>.from(a)));
        }
      }
    }

    return CircleEventModel(
      id: json['id']?.toString() ?? '',
      circleId: json['circle_id']?.toString() ?? '',
      title: json['title'] as String? ?? json['name'] as String? ?? 'Circle Event',
      date: parsedDate,
      time: parsedTime,
      location: parsedLocation,
      mode: json['mode'] as String? ?? 'In-Person',
      status: json['status'] as String? ?? 'Upcoming',
      attendeesCount: parsedAttendees,
      attendees: attendeesList,
    );
  }

  bool get isUpcoming {
    final s = status.toLowerCase();
    return s == 'upcoming' || s == 'scheduled';
  }

  bool get isCompleted {
    final s = status.toLowerCase();
    return s == 'completed' || s == 'concluded';
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
