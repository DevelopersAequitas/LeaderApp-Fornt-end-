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
      data: json['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['data'] as Map)
          : const {},
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
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Returns true if this notification belongs in the executive Leader App.
  /// Filters out consumer member-app notifications (social feed posts, member event reminders, etc.)
  bool get isLeaderNotification {
    final t = type.toLowerCase().trim();
    final c = category.toLowerCase().trim();
    final s = screen.toLowerCase().trim();

    // Consumer event / social feed screens that do not exist in Leader App
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

    // Consumer social & feed notification types
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
      'profile_view',
      'profile_viewed',
      'chat_message',
      'chat',
      'direct_message',
      'connection_request',
      'connection_accepted',
    };

    if (consumerTypes.contains(t) || consumerTypes.contains(c)) {
      return false;
    }

    return true;
  }
}

