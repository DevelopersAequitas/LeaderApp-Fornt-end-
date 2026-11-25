import '../models/leader_permissions.dart';

/// Where a notification should take the leader. A closed set, so every case is
/// handled explicitly (no string matching at navigation time).
sealed class NotificationDestination {
  const NotificationDestination();
}

/// A tab of the home shell: 0 Dashboard, 1 Peers, 2 Teams, 3 Finance, 4 Reports.
class HomeTabDestination extends NotificationDestination {
  const HomeTabDestination(this.tab);
  final int tab;
  @override
  bool operator ==(Object other) => other is HomeTabDestination && other.tab == tab;
  @override
  int get hashCode => Object.hash('tab', tab);
}

class NotificationsFeedDestination extends NotificationDestination {
  const NotificationsFeedDestination();
  @override
  bool operator ==(Object other) => other is NotificationsFeedDestination;
  @override
  int get hashCode => 1;
}

class ProfileDestination extends NotificationDestination {
  const ProfileDestination();
  @override
  bool operator ==(Object other) => other is ProfileDestination;
  @override
  int get hashCode => 2;
}

class RoleManagementDestination extends NotificationDestination {
  const RoleManagementDestination({this.roleId});
  final String? roleId;
  @override
  bool operator ==(Object other) =>
      other is RoleManagementDestination && other.roleId == roleId;
  @override
  int get hashCode => Object.hash(3, roleId);
}

/// A specific Peer (opens the Peer Profile by id).
class PeerProfileDestination extends NotificationDestination {
  const PeerProfileDestination(this.peerId);
  final String peerId;
  @override
  bool operator ==(Object other) => other is PeerProfileDestination && other.peerId == peerId;
  @override
  int get hashCode => Object.hash('peer', peerId);
}

/// A specific Circle (the Circle is fetched by id before opening).
class CircleDetailsDestination extends NotificationDestination {
  const CircleDetailsDestination(this.circleId);
  final String circleId;
  @override
  bool operator ==(Object other) => other is CircleDetailsDestination && other.circleId == circleId;
  @override
  int get hashCode => Object.hash('circle', circleId);
}

/// A specific submitted report (fetched by id before opening).
class ReportDetailsDestination extends NotificationDestination {
  const ReportDetailsDestination(this.reportId);
  final String reportId;
  @override
  bool operator ==(Object other) => other is ReportDetailsDestination && other.reportId == reportId;
  @override
  int get hashCode => Object.hash('report', reportId);
}

/// Action Center / pending approvals queue (with optional approval id / category).
class ActionCenterDestination extends NotificationDestination {
  const ActionCenterDestination({
    this.approvalId,
    this.category,
    this.activityType,
    this.circleId,
  });
  final String? approvalId;
  final String? category;
  final String? activityType;
  final String? circleId;
  @override
  bool operator ==(Object other) =>
      other is ActionCenterDestination &&
      other.approvalId == approvalId &&
      other.category == category &&
      other.activityType == activityType &&
      other.circleId == circleId;
  @override
  int get hashCode =>
      Object.hash('action_center', approvalId, category, activityType, circleId);
}

/// Official Circulars feed / detail (with optional circular id).
class CircularsDestination extends NotificationDestination {
  const CircularsDestination({this.circularId});
  final String? circularId;
  @override
  bool operator ==(Object other) =>
      other is CircularsDestination && other.circularId == circularId;
  @override
  int get hashCode => Object.hash('circulars', circularId);
}

/// Circle Events screen (with optional event id / circle id).
class CircleEventsDestination extends NotificationDestination {
  const CircleEventsDestination({this.eventId, this.circleId});
  final String? eventId;
  final String? circleId;
  @override
  bool operator ==(Object other) =>
      other is CircleEventsDestination &&
      other.eventId == eventId &&
      other.circleId == circleId;
  @override
  int get hashCode => Object.hash('circle_events', eventId, circleId);
}

/// Finance tab / transaction or offline payment verification detail.
class FinanceDetailsDestination extends NotificationDestination {
  const FinanceDetailsDestination({
    this.transactionId,
    this.isOfflinePayment = false,
  });
  final String? transactionId;
  final bool isOfflinePayment;
  @override
  bool operator ==(Object other) =>
      other is FinanceDetailsDestination &&
      other.transactionId == transactionId &&
      other.isOfflinePayment == isOfflinePayment;
  @override
  int get hashCode => Object.hash('finance_details', transactionId, isOfflinePayment);
}

/// Industry & cross-circle business deals view.
class BusinessDealsDestination extends NotificationDestination {
  const BusinessDealsDestination({this.dealId});
  final String? dealId;
  @override
  bool operator ==(Object other) =>
      other is BusinessDealsDestination && other.dealId == dealId;
  @override
  int get hashCode => Object.hash('business_deals', dealId);
}

/// Unmatched asks / peer collaboration view.
class PeerCollaborationDestination extends NotificationDestination {
  const PeerCollaborationDestination({this.askId});
  final String? askId;
  @override
  bool operator ==(Object other) =>
      other is PeerCollaborationDestination && other.askId == askId;
  @override
  int get hashCode => Object.hash('peer_collaboration', askId);
}

/// The payload named no screen the app can open; the notification only marks
/// itself read (feed tap) or opens the feed (push tap).
class NoDestination extends NotificationDestination {
  const NoDestination();
  @override
  bool operator ==(Object other) => other is NoDestination;
  @override
  int get hashCode => 4;
}

/// Entity kinds the app can open **by id** or structured workflow.
enum NotificationEntityType {
  peer,
  circle,
  report,
  approval,
  circular,
  event,
  finance,
  offlinePayment,
  industryOp,
  support,
  security,
  roleAssignment,
}

/// A parsed push/feed payload.
class NotificationPayload {
  const NotificationPayload({
    this.target = '',
    this.type = '',
    this.category = '',
    this.entityType,
    this.entityId,
    this.circleId,
    this.destinationFilter,
    this.targetRecordId,
    this.targetStatus,
    this.schemaVersion,
  });

  factory NotificationPayload.fromMap(Map<String, dynamic> data) {
    String s(dynamic v) => v?.toString().trim() ?? '';
    final rawType = s(data['entity_type']).toLowerCase();
    NotificationEntityType? entity;
    switch (rawType) {
      case 'peer':
        entity = NotificationEntityType.peer;
      case 'circle':
        entity = NotificationEntityType.circle;
      case 'report':
        entity = NotificationEntityType.report;
      case 'approval':
        entity = NotificationEntityType.approval;
      case 'circular':
        entity = NotificationEntityType.circular;
      case 'event':
        entity = NotificationEntityType.event;
      case 'finance':
        entity = NotificationEntityType.finance;
      case 'offline_payment':
      case 'offlinepayment':
        entity = NotificationEntityType.offlinePayment;
      case 'industry_op':
      case 'industryop':
      case 'industry':
        entity = NotificationEntityType.industryOp;
      case 'support':
        entity = NotificationEntityType.support;
      case 'security':
        entity = NotificationEntityType.security;
      case 'role_assignment':
      case 'roleassignment':
        entity = NotificationEntityType.roleAssignment;
    }
    final recordId = s(data['target_record_id']);
    final id = recordId.isNotEmpty
        ? recordId
        : (s(data['entity_id']).isNotEmpty
            ? s(data['entity_id'])
            : s(data['reference_id']));
    final cId = s(data['circle_id']);
    final destFilter = s(data['destination_filter']);
    final destStatus = s(data['target_status']);
    final schemaVer = s(data['schema_version']);
    return NotificationPayload(
      target: s(data['destination'] ??
          data['route'] ??
          data['screen'] ??
          data['click_action']),
      type: s(data['notification_type'] ?? data['event_key'] ?? data['type'])
          .toLowerCase(),
      category: s(data['category']).toLowerCase(),
      entityType: entity,
      entityId: id.isEmpty ? null : id,
      circleId: cId.isEmpty ? null : cId,
      destinationFilter: destFilter.isEmpty ? null : destFilter,
      targetRecordId: recordId.isEmpty ? null : recordId,
      targetStatus: destStatus.isEmpty ? null : destStatus,
      schemaVersion: schemaVer.isEmpty ? null : schemaVer,
    );
  }

  final String target;
  final String type;
  final String category;
  final NotificationEntityType? entityType;
  final String? entityId;
  final String? circleId;
  final String? destinationFilter;
  final String? targetRecordId;
  final String? targetStatus;
  final String? schemaVersion;

  String? get resolvedActivityType {
    if (destinationFilter != null && destinationFilter!.isNotEmpty) {
      return destinationFilter;
    }
    if (type.contains('visitor')) return 'visitor-registrations';
    if (type.contains('impact')) return 'impacts';
    if (type.contains('coin_claim')) return 'coin-claims';
    if (type.contains('join_request') || type.contains('circle_join')) {
      return 'circle-join-requests';
    }
    if (type.contains('cert')) return 'certifications';
    if (type.contains('ad_booking') || type.contains('lead')) return 'leads';
    return null;
  }

  NotificationDestination get destination {
    final id = entityId;
    if (entityType != null) {
      switch (entityType!) {
        case NotificationEntityType.peer:
          if (id != null) return PeerProfileDestination(id);
        case NotificationEntityType.circle:
          if (id != null) return CircleDetailsDestination(id);
        case NotificationEntityType.report:
          if (id != null) return ReportDetailsDestination(id);
        case NotificationEntityType.approval:
          return ActionCenterDestination(
            approvalId: id,
            category: category.isEmpty ? null : category,
            activityType: resolvedActivityType,
            circleId: circleId,
          );
        case NotificationEntityType.circular:
          return CircularsDestination(circularId: id);
        case NotificationEntityType.event:
          return CircleEventsDestination(eventId: id, circleId: circleId);
        case NotificationEntityType.finance:
          return FinanceDetailsDestination(transactionId: id, isOfflinePayment: false);
        case NotificationEntityType.offlinePayment:
          return FinanceDetailsDestination(transactionId: id, isOfflinePayment: true);
        case NotificationEntityType.industryOp:
          if (type.contains('ask')) {
            return PeerCollaborationDestination(askId: id);
          }
          if (type.contains('deal')) {
            return BusinessDealsDestination(dealId: id);
          }
          return ActionCenterDestination(approvalId: id, category: 'industry');
        case NotificationEntityType.support:
          return const NotificationsFeedDestination();
        case NotificationEntityType.security:
          if (type.contains('role_matrix')) {
            return RoleManagementDestination(roleId: id);
          }
          return ActionCenterDestination(approvalId: id, category: 'security');
        case NotificationEntityType.roleAssignment:
          return RoleManagementDestination(roleId: id);
      }
    }

    final t = target.toLowerCase();
    bool anyType(List<String> keys) => keys.any(type.contains);

    if (t.contains('leader-activit') ||
        anyType(['approval', 'pending', 'join_request', 'visitor', 'coin_claim', 'impact'])) {
      return ActionCenterDestination(
        approvalId: id,
        category: category.isEmpty ? null : category,
        activityType: resolvedActivityType,
        circleId: circleId,
      );
    }
    if (t.contains('circular') || type.contains('circular')) {
      return CircularsDestination(circularId: id);
    }
    if (t.contains('circle-event') || anyType(['event_join', 'attendance_dip'])) {
      return CircleEventsDestination(eventId: id, circleId: circleId);
    }
    if (t.contains('business-deal') || type.contains('cross_circle_deal')) {
      return BusinessDealsDestination(dealId: id);
    }
    if (t.contains('peer-collaboration') || type.contains('unmatched_industry_ask')) {
      return PeerCollaborationDestination(askId: id);
    }
    if (t.contains('role') || anyType(['role', 'tenure', 'appointed'])) {
      return RoleManagementDestination(roleId: id);
    }
    if (t.contains('team') ||
        t.contains('circle') ||
        type.contains('circle') ||
        category.contains('circle')) {
      return const HomeTabDestination(2);
    }
    if (t.contains('finance') ||
        anyType(['finance', 'withdrawal', 'payout', 'payment', 'bonus']) ||
        category.contains('finance')) {
      final isOffline = type.contains('offline');
      if (id != null || isOffline) {
        return FinanceDetailsDestination(
          transactionId: id,
          isOfflinePayment: isOffline,
        );
      }
      return const HomeTabDestination(3);
    }
    if (t.contains('report') ||
        anyType(['report', 'attendance', 'compliance']) ||
        category.contains('report') ||
        category.contains('compliance')) {
      return const HomeTabDestination(4);
    }
    if (t.contains('peer') ||
        anyType(['peer', 'referral', 'p2p']) ||
        category.contains('peer') ||
        category.contains('membership')) {
      return const HomeTabDestination(1);
    }
    if (t.contains('profile')) return const ProfileDestination();
    if (t.contains('notification')) return const NotificationsFeedDestination();
    if (t == '/dashboard' || t == 'dashboard') return const HomeTabDestination(0);
    return const NoDestination();
  }
}

/// Whether [permissions] allow opening [destination]. Used so a notification
/// can never open a screen the leader is not authorised to see.
bool isDestinationAllowed(
  NotificationDestination destination,
  LeaderPermissions permissions,
) {
  return switch (destination) {
    HomeTabDestination(:final tab) => switch (tab) {
        0 => permissions.canAccessDashboard,
        1 => permissions.canAccessPeersTab,
        2 => permissions.canAccessTeamsTab,
        3 => permissions.canAccessFinanceTab,
        4 => permissions.canAccessReportsTab,
        _ => true,
      },
    PeerProfileDestination() => permissions.canViewPeerProfile,
    CircleDetailsDestination() => permissions.canAccessTeamsTab,
    CircleEventsDestination() => permissions.canAccessTeamsTab,
    ReportDetailsDestination() => permissions.canAccessReportsTab,
    RoleManagementDestination() => permissions.canAccessRoleManagement,
    FinanceDetailsDestination() => permissions.canAccessFinanceTab,
    ActionCenterDestination() =>
      permissions.canReviewPendingPeers || permissions.canAccessDashboard,
    BusinessDealsDestination() ||
    PeerCollaborationDestination() =>
      permissions.canAccessPeersTab || permissions.canAccessDashboard,
    CircularsDestination() ||
    ProfileDestination() ||
    NotificationsFeedDestination() ||
    NoDestination() =>
      true,
  };
}
