import 'package:flutter/material.dart';

/// Activity categories returned by `GET /leader/members/{member_id}/activities`.
/// Each category maps to one metric tile in the Peer Profile overview.
enum MemberActivityType {
  p2pMeeting(
    apiValue: 'p2p_meeting',
    endpointPath: 'p2p-meetings',
    title: 'P2P Meetings',
    icon: Icons.swap_horiz_rounded,
    emptyMessage: 'No P2P meetings recorded yet',
  ),
  referralGiven(
    apiValue: 'referral_given',
    endpointPath: 'referrals',
    title: 'Referrals Given',
    icon: Icons.campaign_outlined,
    emptyMessage: 'No referrals given yet',
  ),
  referralReceived(
    apiValue: 'referral_received',
    endpointPath: 'referrals',
    title: 'Referrals Received',
    icon: Icons.inbox_outlined,
    emptyMessage: 'No referrals received yet',
  ),
  businessReferral(
    apiValue: 'business_referral',
    endpointPath: 'referrals',
    title: 'Business Referrals',
    icon: Icons.campaign_outlined,
    emptyMessage: 'No referrals yet',
  ),
  dealGiven(
    apiValue: 'deal_given',
    endpointPath: 'business-deals',
    title: 'Deals Given',
    icon: Icons.outbox_outlined,
    emptyMessage: 'No deals given yet',
  ),
  dealReceived(
    apiValue: 'deal_received',
    endpointPath: 'business-deals',
    title: 'Deals Received',
    icon: Icons.handshake_outlined,
    emptyMessage: 'No deals received yet',
  ),
  businessDeal(
    apiValue: 'business_deal',
    endpointPath: 'business-deals',
    title: 'Business Deals',
    icon: Icons.monetization_on_outlined,
    emptyMessage: 'No business deals yet',
  ),
  attendance(
    apiValue: 'attendance',
    endpointPath: 'attendance',
    title: 'Attendance',
    icon: Icons.calendar_today_outlined,
    emptyMessage: 'No attendance records yet',
  ),
  coins(
    apiValue: 'coins',
    endpointPath: 'coins',
    title: 'Coins Earned',
    icon: Icons.stars_rounded,
    emptyMessage: 'No coin activity yet',
  ),
  other(
    apiValue: 'other',
    endpointPath: 'activities',
    title: 'Activities',
    icon: Icons.bolt_rounded,
    emptyMessage: 'No activities yet',
  );

  final String apiValue;
  final String endpointPath;
  final String title;
  final IconData icon;
  final String emptyMessage;

  const MemberActivityType({
    required this.apiValue,
    required this.endpointPath,
    required this.title,
    required this.icon,
    required this.emptyMessage,
  });

  /// Resolves a loosely-formatted backend type (e.g. `P2P Meeting`,
  /// `referrals_given`, `business_deal` + direction) into a known category.
  static MemberActivityType fromRaw(String? rawType, {String? direction}) {
    final type = (rawType ?? '').toLowerCase().replaceAll(
      RegExp(r'[\s\-]'),
      '_',
    );
    final dir = (direction ?? '').toLowerCase();

    if (type.contains('p2p') || type.contains('meeting')) return p2pMeeting;
    if (type.contains('referral')) {
      if (type.contains('given') || dir.contains('given') || dir == 'out') {
        return referralGiven;
      }
      if (type.contains('receiv') || dir.contains('receiv') || dir == 'in') {
        return referralReceived;
      }
      return businessReferral;
    }
    if (type.contains('deal') ||
        type.contains('business') ||
        type.contains('tyfcb')) {
      if (type.contains('given') || dir.contains('given') || dir == 'out') {
        return dealGiven;
      }
      if (type.contains('receiv') || dir.contains('receiv') || dir == 'in') {
        return dealReceived;
      }
      return businessDeal;
    }
    if (type.contains('attend')) return attendance;
    if (type.contains('coin')) return coins;
    return other;
  }
}

/// Single activity entry for a member (P2P meeting, referral, deal, etc.).
class MemberActivityModel {
  final String id;
  final MemberActivityType type;
  final String title;
  final String description;
  final String counterpartName;
  final String amount;
  final String status;
  final String date;
  final Map<String, dynamic> metadata;

  const MemberActivityModel({
    this.id = '',
    required this.type,
    this.title = '',
    this.description = '',
    this.counterpartName = '',
    this.amount = '',
    this.status = '',
    this.date = '',
    this.metadata = const {},
  });

  /// Parses a single activity item. [fallbackType] is used when the backend
  /// groups activities by key (e.g. `{ "p2p_meetings": [...] }`).
  factory MemberActivityModel.fromJson(
    Map<String, dynamic> json, {
    String? fallbackType,
  }) {
    final rawType =
        json['type'] ??
        json['activity_type'] ??
        json['category'] ??
        json['icon_type'] ??
        fallbackType;
    final direction = json['direction'] ?? json['flow'];
    final type = MemberActivityType.fromRaw(
      rawType?.toString(),
      direction: direction?.toString(),
    );

    return MemberActivityModel(
      id: json['id']?.toString() ?? '',
      type: type,
      title:
          _readString(json, const ['title', 'name', 'subject']) ?? type.title,
      description:
          _readString(json, const [
            'description',
            'subtitle',
            'notes',
            'remarks',
            'message',
          ]) ??
          '',
      counterpartName:
          _readName(json, const [
            'counterpart_name',
            'peer',
            'peer_name',
            'member',
            'with',
            'to',
            'from',
            'counterpart',
          ]) ??
          '',
      amount:
          _readString(json, const ['amount', 'value', 'coins', 'points']) ?? '',
      status: _readString(json, const ['status']) ?? '',
      date:
          _readString(json, const [
            'date',
            'scheduled_at',
            'meeting_date',
            'created_at',
            'time',
          ]) ??
          '',
      metadata: _extractMetadata(json),
    );
  }

  static Map<String, dynamic> _extractMetadata(Map<String, dynamic> json) {
    final meta = <String, dynamic>{};

    // Extract direct fields
    if (json['phone'] != null && json['phone'].toString().isNotEmpty) {
      meta['phone'] = json['phone'];
    }
    if (json['email'] != null && json['email'].toString().isNotEmpty) {
      meta['email'] = json['email'];
    }
    if (json['hot_value'] != null) {
      meta['hot_value'] = json['hot_value'];
    }
    if (json['referral_type'] != null &&
        json['referral_type'].toString().isNotEmpty) {
      meta['referral_type'] = json['referral_type'];
    }

    // Extract counterpart nested fields
    final counterpart = json['counterpart'] ?? json['to_user'];
    if (counterpart is Map) {
      if (counterpart['company_name'] != null &&
          counterpart['company_name'].toString().isNotEmpty) {
        meta['company_name'] = counterpart['company_name'];
      }
      if (counterpart['designation'] != null &&
          counterpart['designation'].toString().isNotEmpty) {
        meta['designation'] = counterpart['designation'];
      }
      if (counterpart['city'] != null &&
          counterpart['city'].toString().isNotEmpty) {
        meta['city'] = counterpart['city'];
      }
    }

    return meta;
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null || value is Map || value is List) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  static String? _readName(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is Map) {
        final name = value['name'] ?? value['full_name'];
        if (name != null && name.toString().trim().isNotEmpty) {
          return name.toString().trim();
        }
      } else if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  /// Parses the `data` payload, which may be a flat list, a wrapped list
  /// (`{ "activities": [...] }`) or a map grouped by activity type.
  static List<MemberActivityModel> parseList(dynamic data) {
    final result = <MemberActivityModel>[];

    void addItems(List items, {String? fallbackType}) {
      for (final item in items) {
        if (item is Map) {
          result.add(
            MemberActivityModel.fromJson(
              Map<String, dynamic>.from(item),
              fallbackType: fallbackType,
            ),
          );
        }
      }
    }

    if (data is List) {
      addItems(data);
    } else if (data is Map) {
      final wrapped = data['activities'] ?? data['items'] ?? data['data'];
      if (wrapped is List) {
        addItems(wrapped);
      } else {
        data.forEach((key, value) {
          if (value is List) addItems(value, fallbackType: key.toString());
        });
      }
    }
    return result;
  }
}
