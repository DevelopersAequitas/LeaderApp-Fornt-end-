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
}

