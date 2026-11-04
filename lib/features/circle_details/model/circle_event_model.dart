import '../../../../core/utils/date_time_utils.dart';
import '../../peers/model/peer_model.dart';

/// Model representing a circle assembly, summit, or recurring conclave event.
class CircleEventModel {
  final String id;
  final String circleId;
  final String title;
  final String date;
  final String time;
  final String startTime;
  final String endTime;
  final String timeRange;
  final String location;
  final String mode; // "In-Person", "Online", "Hybrid"
  final String status; // "Upcoming", "Completed"
  final int attendeesCount;
  final List<PeerModel> attendees;
  final String cadenceSummary; // e.g. "1st Tuesday"
  final String cadenceText; // e.g. "Week 1 • Tuesdays From 02:00 AM To 03:00 AM (Monthly • Offline)"
  final String frequency; // e.g. "Monthly"
  final String ordinal; // e.g. "1st"
  final String dayOfWeek; // e.g. "Tuesday"

  const CircleEventModel({
    required this.id,
    this.circleId = '',
    required this.title,
    required this.date,
    required this.time,
    this.startTime = '',
    this.endTime = '',
    this.timeRange = '',
    required this.location,
    required this.mode,
    required this.status,
    required this.attendeesCount,
    this.attendees = const [],
    this.cadenceSummary = '',
    this.cadenceText = '',
    this.frequency = 'Monthly',
    this.ordinal = '',
    this.dayOfWeek = '',
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
    String parsedStartTime = json['start_time_formatted']?.toString() ??
        json['start_time']?.toString() ??
        '';
    String parsedEndTime = json['end_time_formatted']?.toString() ??
        json['end_time']?.toString() ??
        '';
    String parsedTimeRange = json['time_range']?.toString() ?? '';

    // Date & Time conversion
    final rawStart = json['start_at'] ?? json['start_time'] ?? json['event_date'] ?? json['date'];
    DateTime? dt;
    if (rawStart != null && rawStart.toString().trim().isNotEmpty) {
      dt = DateTimeUtils.parseUtc(rawStart);
      if (dt != null) {
        if (parsedDate.isEmpty) {
          parsedDate = DateTimeUtils.formatDate(dt);
        }
        if (parsedStartTime.isEmpty && (rawStart.toString().contains('T') || rawStart.toString().contains(':'))) {
          parsedStartTime = DateTimeUtils.formatTime(dt);
        }
      }
    }

    final rawEnd = json['end_at'] ?? json['end_time'];
    if (rawEnd != null && rawEnd.toString().trim().isNotEmpty) {
      final endDt = DateTimeUtils.parseUtc(rawEnd);
      if (endDt != null && parsedEndTime.isEmpty) {
        parsedEndTime = DateTimeUtils.formatTime(endDt);
      }
    }

    if (parsedTimeRange.isEmpty) {
      if (parsedStartTime.isNotEmpty && parsedEndTime.isNotEmpty) {
        parsedTimeRange = '$parsedStartTime - $parsedEndTime';
      } else if (parsedTime.isNotEmpty) {
        parsedTimeRange = parsedTime;
      } else if (parsedStartTime.isNotEmpty) {
        parsedTimeRange = parsedStartTime;
      }
    }

    if (parsedTime.isEmpty && parsedTimeRange.isNotEmpty) {
      parsedTime = parsedTimeRange;
    }

    // Ordinal & Day calculation (e.g. 1st Tuesday, 2nd Monday)
    String parsedOrdinal = json['ordinal']?.toString() ?? '';
    String parsedDayOfWeek = json['day']?.toString() ?? json['day_of_week']?.toString() ?? '';
    String parsedCadenceSummary = json['cadence_summary']?.toString() ?? '';
    String parsedCadenceText = json['cadence_text']?.toString() ?? '';
    String parsedFrequency = json['frequency']?.toString() ?? 'Monthly';

    if (dt != null) {
      const weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      final dayName = weekdays[dt.weekday - 1];
      if (parsedDayOfWeek.isEmpty) {
        parsedDayOfWeek = dayName;
      }

      final weekNum = ((dt.day - 1) ~/ 7) + 1;
      const ords = {1: '1st', 2: '2nd', 3: '3rd', 4: '4th', 5: '5th'};
      final ordText = ords[weekNum] ?? '1st';
      if (parsedOrdinal.isEmpty) {
        parsedOrdinal = ordText;
      }

      if (parsedCadenceSummary.isEmpty) {
        parsedCadenceSummary = '$parsedOrdinal $parsedDayOfWeek';
      }
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
      startTime: parsedStartTime,
      endTime: parsedEndTime,
      timeRange: parsedTimeRange,
      location: parsedLocation,
      mode: json['mode'] as String? ?? 'In-Person',
      status: json['status'] as String? ?? 'Upcoming',
      attendeesCount: parsedAttendees,
      attendees: attendeesList,
      cadenceSummary: parsedCadenceSummary,
      cadenceText: parsedCadenceText,
      frequency: parsedFrequency,
      ordinal: parsedOrdinal,
      dayOfWeek: parsedDayOfWeek,
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

  /// Formatted timing string with start and end times, e.g. "02:00 AM - 03:00 AM"
  String get effectiveTimeRange {
    if (timeRange.isNotEmpty) return timeRange;
    if (startTime.isNotEmpty && endTime.isNotEmpty) {
      return '$startTime - $endTime';
    }
    if (time.isNotEmpty) return time;
    return startTime;
  }

  /// Formatted cadence with frequency, e.g. "1st Tuesday · Monthly"
  String get effectiveCadence {
    if (cadenceSummary.isNotEmpty) {
      if (frequency.isNotEmpty && !cadenceSummary.toLowerCase().contains(frequency.toLowerCase())) {
        return '$cadenceSummary · $frequency';
      }
      return cadenceSummary;
    }
    if (ordinal.isNotEmpty && dayOfWeek.isNotEmpty) {
      return '$ordinal $dayOfWeek · $frequency';
    }
    return '';
  }

  /// Formatted date with ordinal day, e.g. "1 Dec 2026 (1st Tuesday)"
  String get effectiveDateWithCadence {
    if (date.isEmpty) return 'Date TBD';
    if (cadenceSummary.isNotEmpty) {
      return '$date ($cadenceSummary)';
    }
    return date;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'circle_id': circleId,
        'title': title,
        'date': date,
        'time': time,
        'start_time': startTime,
        'end_time': endTime,
        'time_range': timeRange,
        'location': location,
        'mode': mode,
        'status': status,
        'attendees_count': attendeesCount,
        'cadence_summary': cadenceSummary,
        'cadence_text': cadenceText,
        'frequency': frequency,
        'ordinal': ordinal,
        'day': dayOfWeek,
      };
}
