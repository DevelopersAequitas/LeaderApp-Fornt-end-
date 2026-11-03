import 'package:flutter/foundation.dart';

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
    DateTime parsedDate;
    try {
      final rawDate = json['created_at']?.toString();
      parsedDate = rawDate != null && rawDate.isNotEmpty
          ? DateTime.parse(rawDate)
          : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final isUnreadVal = json['is_unread'] == true ||
        json['is_read'] == false ||
        json['read_at'] == null && (json['status'] != 'read');

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

