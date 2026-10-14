/// Model representing coordinates for attendance & performance spline charts.
class ReportsChartPoint {
  final String month;
  final double value;

  const ReportsChartPoint({required this.month, required this.value});

  factory ReportsChartPoint.fromJson(Map<String, dynamic> json) {
    return ReportsChartPoint(
      month: json['month']?.toString() ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'value': value,
      };
}

/// Model representing a peer's status and membership dates within a circle report.
class ReportPeerRosterItem {
  final String peerId;
  final String name;
  final String? avatarUrl;
  final String company;
  final String designation;
  final String status;
  final String platformMembershipStart;
  final String platformMembershipEnd;
  final String circleJoiningDate;
  final String circleRenewalDate;
  final String attendance;
  final String dealsClosed;
  final int p2pCount;
  final int referralsCount;

  const ReportPeerRosterItem({
    required this.peerId,
    required this.name,
    this.avatarUrl,
    required this.company,
    required this.designation,
    required this.status,
    required this.platformMembershipStart,
    required this.platformMembershipEnd,
    required this.circleJoiningDate,
    required this.circleRenewalDate,
    required this.attendance,
    required this.dealsClosed,
    required this.p2pCount,
    required this.referralsCount,
  });

  factory ReportPeerRosterItem.fromJson(Map<String, dynamic> json) {
    return ReportPeerRosterItem(
      peerId: json['peer_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] as String? ?? json['peer_name'] as String? ?? 'Peer',
      avatarUrl: json['avatar_url'] as String? ?? json['profile_photo_url'] as String?,
      company: json['company'] as String? ?? json['company_name'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
      platformMembershipStart: json['platform_membership_start'] as String? ?? json['app_membership_start'] as String? ?? '',
      platformMembershipEnd: json['platform_membership_end'] as String? ?? json['app_membership_end'] as String? ?? '',
      circleJoiningDate: json['circle_joining_date'] as String? ?? json['joined_date'] as String? ?? '',
      circleRenewalDate: json['circle_renewal_date'] as String? ?? json['renewal_date'] as String? ?? '',
      attendance: json['attendance']?.toString() ?? json['attendance_rate']?.toString() ?? '100%',
      dealsClosed: json['deals_closed']?.toString() ?? json['deals']?.toString() ?? '₹0',
      p2pCount: json['p2p_count'] as int? ?? json['p2p_meetings'] as int? ?? 0,
      referralsCount: json['referrals_count'] as int? ?? json['referrals_given'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'peer_id': peerId,
        'name': name,
        'avatar_url': avatarUrl,
        'company': company,
        'designation': designation,
        'status': status,
        'platform_membership_start': platformMembershipStart,
        'platform_membership_end': platformMembershipEnd,
        'circle_joining_date': circleJoiningDate,
        'circle_renewal_date': circleRenewalDate,
        'attendance': attendance,
        'deals_closed': dealsClosed,
        'p2p_count': p2pCount,
        'referrals_count': referralsCount,
      };
}

/// Model representing a leadership report submission with peer breakdown.
class ReportModel {
  final String id;
  final String type; // "Weekly", "Monthly", "Quarterly", "Annual", "District", "Industry"
  final String circleName;
  final String circleId;
  final String? districtId;
  final String? districtName;
  final String? industryName;
  final String status; // "Submitted", "Under Review", "Approved", "Actioned"
  final String date; // E.g., "September 2026" or "Jul 1, 2026"
  final String? period;
  final String? submittedAt;
  final String content;
  final String author;
  final String authorRole;
  final double? attendancePercentage;
  final String? dealsClosedValue;
  final String? totalRevenue;
  final String? highlights;
  final String? challengesFaced;
  final String? actionItems;
  final List<String> includedSections;
  final List<ReportPeerRosterItem> peersRoster;

  const ReportModel({
    this.id = '',
    required this.type,
    this.circleName = '',
    this.circleId = '',
    this.districtId,
    this.districtName,
    this.industryName,
    required this.status,
    required this.date,
    this.period,
    this.submittedAt,
    required this.content,
    required this.author,
    this.authorRole = 'Circle Chair',
    this.attendancePercentage,
    this.dealsClosedValue,
    this.totalRevenue,
    this.highlights,
    this.challengesFaced,
    this.actionItems,
    this.includedSections = const [],
    this.peersRoster = const [],
  });

  String get formattedAttendance {
    if (attendancePercentage == null) return '100%';
    if (attendancePercentage! % 1 == 0) {
      return '${attendancePercentage!.toInt()}%';
    }
    return '${attendancePercentage!.toStringAsFixed(1)}%';
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    final peersList = <ReportPeerRosterItem>[];
    final rawPeers = json['peers_roster'] ?? json['peers'] ?? json['members'];
    if (rawPeers is List) {
      for (final p in rawPeers) {
        if (p is Map<String, dynamic>) {
          peersList.add(ReportPeerRosterItem.fromJson(p));
        }
      }
    }

    final rawSections = json['included_sections'];
    final sections = <String>[];
    if (rawSections is List) {
      for (final s in rawSections) {
        if (s != null) sections.add(s.toString());
      }
    }

    final periodStr = json['period'] as String?;
    final submittedAtStr = json['submitted_at'] as String?;
    final dateStr = periodStr ?? submittedAtStr ?? json['date'] as String? ?? '';

    return ReportModel(
      id: json['id']?.toString() ?? json['report_id']?.toString() ?? '',
      type: json['report_type'] as String? ?? json['type'] as String? ?? 'Monthly',
      circleName: json['circle_name'] as String? ?? json['circle'] as String? ?? '',
      circleId: json['circle_id']?.toString() ?? '',
      districtId: json['district_id']?.toString(),
      districtName: json['district_name'] as String?,
      industryName: json['industry_name'] as String?,
      status: json['status'] as String? ?? 'Approved',
      date: dateStr,
      period: periodStr,
      submittedAt: submittedAtStr,
      content: json['summary_text'] as String? ?? json['content'] as String? ?? '',
      author: json['submitted_by'] as String? ?? json['author'] as String? ?? '',
      authorRole: json['submitter_role'] as String? ?? json['author_role'] as String? ?? 'Circle Leadership',
      attendancePercentage: (json['attendance_percentage'] as num?)?.toDouble(),
      dealsClosedValue: json['deals_closed_value']?.toString() ?? json['deals_closed']?.toString(),
      totalRevenue: json['total_revenue']?.toString(),
      highlights: json['highlights'] as String?,
      challengesFaced: json['challenges_faced'] as String?,
      actionItems: json['action_items'] as String?,
      includedSections: sections,
      peersRoster: peersList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'report_type': type,
        'circle_name': circleName,
        'circle_id': circleId,
        'district_id': districtId,
        'district_name': districtName,
        'industry_name': industryName,
        'status': status,
        'period': period ?? date,
        'submitted_at': submittedAt,
        'summary_text': content,
        'submitted_by': author,
        'submitter_role': authorRole,
        'attendance_percentage': attendancePercentage,
        'deals_closed_value': dealsClosedValue,
        'total_revenue': totalRevenue,
        'highlights': highlights,
        'challenges_faced': challengesFaced,
        'action_items': actionItems,
        'included_sections': includedSections,
        'peers_roster': peersRoster.map((p) => p.toJson()).toList(),
      };

  ReportModel copyWith({
    String? id,
    String? type,
    String? circleName,
    String? circleId,
    String? districtId,
    String? districtName,
    String? industryName,
    String? status,
    String? date,
    String? period,
    String? submittedAt,
    String? content,
    String? author,
    String? authorRole,
    double? attendancePercentage,
    String? dealsClosedValue,
    String? totalRevenue,
    String? highlights,
    String? challengesFaced,
    String? actionItems,
    List<String>? includedSections,
    List<ReportPeerRosterItem>? peersRoster,
  }) {
    return ReportModel(
      id: id ?? this.id,
      type: type ?? this.type,
      circleName: circleName ?? this.circleName,
      circleId: circleId ?? this.circleId,
      districtId: districtId ?? this.districtId,
      districtName: districtName ?? this.districtName,
      industryName: industryName ?? this.industryName,
      status: status ?? this.status,
      date: date ?? this.date,
      period: period ?? this.period,
      submittedAt: submittedAt ?? this.submittedAt,
      content: content ?? this.content,
      author: author ?? this.author,
      authorRole: authorRole ?? this.authorRole,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      dealsClosedValue: dealsClosedValue ?? this.dealsClosedValue,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      highlights: highlights ?? this.highlights,
      challengesFaced: challengesFaced ?? this.challengesFaced,
      actionItems: actionItems ?? this.actionItems,
      includedSections: includedSections ?? this.includedSections,
      peersRoster: peersRoster ?? this.peersRoster,
    );
  }
}

/// Response returned when submitting a performance report for leadership routing.
class ReportSubmitResponse {
  final String reportId;
  final String status;
  final List<String> visibleToRoles;

  const ReportSubmitResponse({
    required this.reportId,
    required this.status,
    this.visibleToRoles = const [],
  });

  factory ReportSubmitResponse.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['visible_to_roles'];
    final roles = <String>[];
    if (rawRoles is List) {
      for (final r in rawRoles) {
        if (r != null) roles.add(r.toString());
      }
    }
    return ReportSubmitResponse(
      reportId: json['report_id']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status'] as String? ?? 'Under Review',
      visibleToRoles: roles,
    );
  }

  Map<String, dynamic> toJson() => {
        'report_id': reportId,
        'status': status,
        'visible_to_roles': visibleToRoles,
      };
}


