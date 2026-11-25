import 'package:flutter/foundation.dart';
import '../../../../core/utils/date_time_utils.dart';

/// Represents a single event-driven notification for a Leader.
@immutable
class LeaderNotificationModel {
  final String id;
  final String title;
  final String message;
  final String category;
  final String type;
  final bool isUnread;
  final String screen;
  final String priority;
  final String deliveryTier;
  final bool requiresAction;
  final String audience;
  final String eventKey;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  const LeaderNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.type,
    required this.isUnread,
    required this.screen,
    this.priority = 'medium',
    this.deliveryTier = 'important',
    this.requiresAction = false,
    this.audience = '',
    this.eventKey = '',
    this.data = const {},
    required this.createdAt,
  });

  factory LeaderNotificationModel.fromJson(Map<String, dynamic> json) {
    final parsedDate = DateTimeUtils.parseUtc(json['created_at']) ?? DateTime.now();

    final bool isUnreadVal;
    if (json['is_unread'] != null) {
      isUnreadVal = json['is_unread'] == true;
    } else if (json['is_read'] != null) {
      isUnreadVal = json['is_read'] == false;
    } else if (json['read_at'] != null) {
      isUnreadVal = false;
    } else if (json['status'] != null) {
      isUnreadVal = json['status'].toString().toLowerCase() != 'read';
    } else {
      isUnreadVal = false;
    }

    final dataMap = json['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['data'] as Map)
        : const <String, dynamic>{};

    return LeaderNotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Leader Notification',
      message: json['message']?.toString() ??
          json['body']?.toString() ??
          'You have a new update.',
      category: json['category']?.toString() ?? 'system',
      type: json['type']?.toString() ?? 'general',
      isUnread: isUnreadVal,
      screen: json['screen']?.toString() ?? '/dashboard',
      priority: (json['priority'] ?? dataMap['priority'] ?? 'medium').toString().toLowerCase(),
      deliveryTier: (json['delivery_tier'] ?? dataMap['delivery_tier'] ?? 'important').toString().toLowerCase(),
      requiresAction: json['requires_action'] == true || dataMap['requires_action'] == true,
      audience: (json['audience'] ?? dataMap['audience'] ?? '').toString().toLowerCase(),
      eventKey: (json['event_key'] ?? dataMap['event_key'] ?? '').toString().toLowerCase(),
      data: dataMap,
      createdAt: parsedDate,
    );
  }

  LeaderNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? category,
    String? type,
    bool? isUnread,
    String? screen,
    String? priority,
    String? deliveryTier,
    bool? requiresAction,
    String? audience,
    String? eventKey,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return LeaderNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      type: type ?? this.type,
      isUnread: isUnread ?? this.isUnread,
      screen: screen ?? this.screen,
      priority: priority ?? this.priority,
      deliveryTier: deliveryTier ?? this.deliveryTier,
      requiresAction: requiresAction ?? this.requiresAction,
      audience: audience ?? this.audience,
      eventKey: eventKey ?? this.eventKey,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isCritical =>
      deliveryTier == 'critical' || priority == 'urgent' || priority == 'critical';

  /// Returns true if this notification belongs in the executive Leader App.
  /// Checks explicit `audience` metadata first, then rejects consumer social types/screens.
  bool get isLeaderNotification {
    if (audience == 'member' || audience == 'consumer') {
      return false;
    }

    final t = type.toLowerCase().trim();
    final c = category.toLowerCase().trim();
    final s = screen.toLowerCase().trim();
    final innerType = (data['notification_type'] ?? data['activity_type'] ?? '')
        .toString()
        .toLowerCase()
        .trim();

    const consumerTypes = {
      'new_post',
      'post_created',
      'post_like',
      'post_liked',
      'post_comment',
      'post_commented',
      'comment_like',
      'comment_liked',
      'post_tagged',
      'post_shared',
      'feed_post',
      'peer_post',
      'social_post',
      'event',
      'new_event',
      'event_created',
      'upcoming_event_reminder',
      'event_starting_now',
      'event_reminder',
      'live_meeting',
      'activity_update',
      'feed_update',
      'speed_networking',
      'daily_reminder',
      'daily_engagement_reminder',
      'engagement_reminder',
      'engagement',
      'engagement_founder',
      'streak_reminder',
      'streak',
      'badge_earned',
      'badge_unlocked',
      'profile_view',
      'profile_viewed',
      'chat_message',
      'chat',
      'direct_message',
      'connection_request',
      'connection_accepted',
      'birthday_anniversary',
      'peer_wish',
      'wish_received',
      'p2p_meeting_request',
      'p2p_meeting_confirmed',
      'p2p_meeting_declined',
      'p2p_post_meeting_outcome',
      'coin_milestone',
      'unclaimed_coins',
      'non_pro_upsell',
      'pro_expiry',
      'leaderboard_rank_change',
      'weekly_digest',
    };

    if (consumerTypes.contains(t) || consumerTypes.contains(c)) {
      return false;
    }

    if (audience == 'leadership' ||
        data['app'] == 'leader' ||
        data['app_name'] == 'leader_app') {
      return true;
    }

    const leaderKeywords = [
      'requirement',
      'lead',
      'referral',
      'deal',
      'ask',
      'circle',
      'leader',
      'report',
      'finance',
      'payment',
      'commission',
      'payout',
      'approval',
      'pending',
      'role',
      'circular',
      'milestone',
      'governance',
      'compliance',
      'security',
      'membership',
      'performance',
      'industry',
    ];
    final combinedType = '$t $c $innerType $eventKey';
    if (leaderKeywords.any(combinedType.contains)) {
      return true;
    }

    if (s == 'event_detail' ||
        s == 'event_details' ||
        s == 'live_meeting' ||
        s.contains('post_detail') ||
        s.contains('/post-detail') ||
        s == 'feed' ||
        s == '/feed' ||
        s.contains('chat_conversation') ||
        s == 'connections' ||
        s == 'member_feed') {
      return false;
    }

    return true;
  }
}
