/// Model representing an event associated with a member (as creator, organizer, or attendee).
class MemberEventItemModel {
  final String id;
  final String title;
  final String eventType;
  final String mode;
  final String locationText;
  final String startAt;
  final String endAt;
  final String status;
  final List<String> memberRoles;
  final String registrationStatus;
  final String checkinStatus;
  final String bannerUrl;
  final bool isPaid;
  final double ticketPrice;
  final String createdAt;

  const MemberEventItemModel({
    required this.id,
    required this.title,
    this.eventType = '',
    this.mode = 'In-Person',
    this.locationText = '',
    this.startAt = '',
    this.endAt = '',
    this.status = 'upcoming',
    this.memberRoles = const [],
    this.registrationStatus = 'registered',
    this.checkinStatus = 'not_checked_in',
    this.bannerUrl = '',
    this.isPaid = false,
    this.ticketPrice = 0.0,
    this.createdAt = '',
  });

  factory MemberEventItemModel.fromJson(Map<String, dynamic> json) {
    final roles = <String>[];
    if (json['member_roles'] is List) {
      for (final r in json['member_roles']) {
        if (r != null) roles.add(r.toString());
      }
    }

    double price = 0.0;
    if (json['ticket_price'] != null) {
      if (json['ticket_price'] is num) {
        price = (json['ticket_price'] as num).toDouble();
      } else {
        price = double.tryParse(json['ticket_price'].toString()) ?? 0.0;
      }
    }

    return MemberEventItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Event',
      eventType: json['event_type'] as String? ?? '',
      mode: json['mode'] as String? ?? 'In-Person',
      locationText: json['location_text'] as String? ?? json['location'] as String? ?? '',
      startAt: json['start_at'] as String? ?? json['date'] as String? ?? '',
      endAt: json['end_at'] as String? ?? '',
      status: json['status'] as String? ?? 'upcoming',
      memberRoles: roles,
      registrationStatus: json['registration_status'] as String? ?? 'registered',
      checkinStatus: json['checkin_status'] as String? ?? 'not_checked_in',
      bannerUrl: json['banner_url'] as String? ?? '',
      isPaid: json['is_paid'] as bool? ?? false,
      ticketPrice: price,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  String get formattedMode {
    final m = mode.trim().toLowerCase();
    if (m.isEmpty) return 'In-Person';
    if (m.contains('online') || m.contains('virtual')) return 'Online';
    if (m.contains('in_person') || m.contains('in-person') || m.contains('offline') || m.contains('physical')) {
      return 'In-Person';
    }
    return mode;
  }

  bool get isUpcoming {
    final s = status.trim().toLowerCase();
    return s == 'upcoming' || s == 'scheduled';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'event_type': eventType,
        'mode': mode,
        'location_text': locationText,
        'start_at': startAt,
        'end_at': endAt,
        'status': status,
        'member_roles': memberRoles,
        'registration_status': registrationStatus,
        'checkin_status': checkinStatus,
        'banner_url': bannerUrl,
        'is_paid': isPaid,
        'ticket_price': ticketPrice,
        'created_at': createdAt,
      };
}

/// Model representing a member event registration, pass & QR status.
class MemberEventRegistrationModel {
  final String id;
  final String eventId;
  final String eventName;
  final String eventDate;
  final String eventType;
  final String eventStatus;
  final String occurrenceDate;
  final String registrationStatus;
  final String checkinStatus;
  final String registeredAt;
  final String? checkedInAt;
  final bool paymentRequired;
  final String paymentStatus;
  final double paymentAmount;
  final String paymentCurrency;
  final String paymentGateway;
  final String registrationType;
  final String source;
  final String qrToken;
  final String qrCodeUrl;
  final String qrStatus;
  final String createdAt;

  const MemberEventRegistrationModel({
    required this.id,
    this.eventId = '',
    required this.eventName,
    this.eventDate = '',
    this.eventType = '',
    this.eventStatus = 'upcoming',
    this.occurrenceDate = '',
    this.registrationStatus = 'registered',
    this.checkinStatus = 'not_checked_in',
    this.registeredAt = '',
    this.checkedInAt,
    this.paymentRequired = false,
    this.paymentStatus = 'unpaid',
    this.paymentAmount = 0.0,
    this.paymentCurrency = 'INR',
    this.paymentGateway = '',
    this.registrationType = 'member',
    this.source = 'app',
    this.qrToken = '',
    this.qrCodeUrl = '',
    this.qrStatus = 'active',
    this.createdAt = '',
  });

  factory MemberEventRegistrationModel.fromJson(Map<String, dynamic> json) {
    double amount = 0.0;
    if (json['payment_amount'] != null) {
      if (json['payment_amount'] is num) {
        amount = (json['payment_amount'] as num).toDouble();
      } else {
        amount = double.tryParse(json['payment_amount'].toString()) ?? 0.0;
      }
    }

    return MemberEventRegistrationModel(
      id: json['id']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      eventName: json['event_name'] as String? ?? 'Event Registration',
      eventDate: json['event_date'] as String? ?? json['date'] as String? ?? '',
      eventType: json['event_type'] as String? ?? '',
      eventStatus: json['event_status'] as String? ?? 'upcoming',
      occurrenceDate: json['occurrence_date'] as String? ?? '',
      registrationStatus: json['registration_status'] as String? ?? 'registered',
      checkinStatus: json['checkin_status'] as String? ?? 'not_checked_in',
      registeredAt: json['registered_at'] as String? ?? '',
      checkedInAt: json['checked_in_at'] as String?,
      paymentRequired: json['payment_required'] as bool? ?? false,
      paymentStatus: json['payment_status'] as String? ?? 'paid',
      paymentAmount: amount,
      paymentCurrency: json['payment_currency'] as String? ?? 'INR',
      paymentGateway: json['payment_gateway'] as String? ?? '',
      registrationType: json['registration_type'] as String? ?? 'member',
      qrToken: json['qr_token'] as String? ?? json['token'] as String? ?? '',
      qrCodeUrl: json['qr_code_url'] as String? ?? json['qr_url'] as String? ?? '',
      qrStatus: json['qr_status'] as String? ?? json['status'] as String? ?? 'active',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  String get effectiveQrUrl {
    if (qrCodeUrl.isNotEmpty && qrCodeUrl.startsWith('http')) {
      return qrCodeUrl;
    }
    final token = qrToken.isNotEmpty ? qrToken : id;
    if (token.isNotEmpty) {
      return 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${Uri.encodeComponent(token)}';
    }
    return '';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'event_id': eventId,
        'event_name': eventName,
        'event_date': eventDate,
        'event_type': eventType,
        'event_status': eventStatus,
        'occurrence_date': occurrenceDate,
        'registration_status': registrationStatus,
        'checkin_status': checkinStatus,
        'registered_at': registeredAt,
        'checked_in_at': checkedInAt,
        'payment_required': paymentRequired,
        'payment_status': paymentStatus,
        'payment_amount': paymentAmount,
        'payment_currency': paymentCurrency,
        'payment_gateway': paymentGateway,
        'registration_type': registrationType,
        'source': source,
        'qr_token': qrToken,
        'qr_code_url': qrCodeUrl,
        'qr_status': qrStatus,
        'created_at': createdAt,
      };
}

/// Model representing a member attendance record for Circle meetings and assemblies.
class MemberAttendanceRecordModel {
  final String id;
  final String activityType;
  final String attendanceType;
  final String title;
  final String description;
  final String status;
  final String date;
  final String meetingDate;
  final String venue;
  final String mode;
  final String circleId;
  final String circleName;
  final String notes;
  final String createdAt;

  const MemberAttendanceRecordModel({
    required this.id,
    this.activityType = 'attendance',
    this.attendanceType = 'circle_meeting',
    required this.title,
    this.description = '',
    this.status = 'Present',
    this.date = '',
    this.meetingDate = '',
    this.venue = '',
    this.mode = 'offline',
    this.circleId = '',
    this.circleName = '',
    this.notes = '',
    this.createdAt = '',
  });

  factory MemberAttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return MemberAttendanceRecordModel(
      id: json['id']?.toString() ?? '',
      activityType: json['activity_type'] as String? ?? 'attendance',
      attendanceType: json['attendance_type'] as String? ?? 'circle_meeting',
      title: json['title'] as String? ?? 'Circle Meeting',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'Present',
      date: json['date'] as String? ?? '',
      meetingDate: json['meeting_date'] as String? ?? '',
      venue: json['venue'] as String? ?? '',
      mode: json['mode'] as String? ?? 'offline',
      circleId: json['circle_id']?.toString() ?? '',
      circleName: json['circle_name'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  bool get isPresent => status.trim().toLowerCase() == 'present';

  String get formattedMode {
    final m = mode.trim().toLowerCase();
    if (m.isEmpty) return 'In-Person';
    if (m.contains('online') || m.contains('virtual')) return 'Online';
    if (m.contains('in_person') || m.contains('in-person') || m.contains('offline') || m.contains('physical')) {
      return 'In-Person';
    }
    return mode;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'activity_type': activityType,
        'attendance_type': attendanceType,
        'title': title,
        'description': description,
        'status': status,
        'date': date,
        'meeting_date': meetingDate,
        'venue': venue,
        'mode': mode,
        'circle_id': circleId,
        'circle_name': circleName,
        'notes': notes,
        'created_at': createdAt,
      };
}
