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
  final String type; // "Weekly", "Monthly", "District", "Industry"
  final String circleName;
  final String circleId;
  final String status; // "Submitted", "Under Review", "Approved", "Actioned"
  final String date; // E.g., "Jul 1, 2026"
  final String content;
  final String author;
  final String authorRole;
  final int? attendancePercentage;
  final String? dealsClosedValue;
  final String? totalRevenue;
  final String? actionItems;
  final List<ReportPeerRosterItem> peersRoster;

  const ReportModel({
    this.id = '',
    required this.type,
    this.circleName = '',
    this.circleId = '',
    required this.status,
    required this.date,
    required this.content,
    required this.author,
    this.authorRole = 'Circle Chair',
    this.attendancePercentage,
    this.dealsClosedValue,
    this.totalRevenue,
    this.actionItems,
    this.peersRoster = const [],
  });

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

    return ReportModel(
      id: json['id']?.toString() ?? '',
      type: json['report_type'] as String? ?? json['type'] as String? ?? 'Monthly',
      circleName: json['circle_name'] as String? ?? json['circle'] as String? ?? '',
      circleId: json['circle_id']?.toString() ?? '',
      status: json['status'] as String? ?? 'Approved',
      date: json['period'] as String? ?? json['submitted_at'] as String? ?? json['date'] as String? ?? '',
      content: json['summary_text'] as String? ?? json['content'] as String? ?? '',
      author: json['submitted_by'] as String? ?? json['author'] as String? ?? '',
      authorRole: json['submitter_role'] as String? ?? json['author_role'] as String? ?? 'Circle Leadership',
      attendancePercentage: (json['attendance_percentage'] as num?)?.round(),
      dealsClosedValue: json['deals_closed_value']?.toString() ?? json['deals_closed']?.toString(),
      totalRevenue: json['total_revenue']?.toString(),
      actionItems: json['action_items'] as String?,
      peersRoster: peersList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'report_type': type,
        'circle_name': circleName,
        'circle_id': circleId,
        'status': status,
        'period': date,
        'summary_text': content,
        'submitted_by': author,
        'submitter_role': authorRole,
        'attendance_percentage': attendancePercentage,
        'deals_closed_value': dealsClosedValue,
        'total_revenue': totalRevenue,
        'action_items': actionItems,
        'peers_roster': peersRoster.map((p) => p.toJson()).toList(),
      };
}

