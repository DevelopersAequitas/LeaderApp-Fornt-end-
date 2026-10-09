import 'dart:convert';
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
  testimonial(
    apiValue: 'testimonial',
    endpointPath: 'testimonials',
    title: 'Testimonials',
    icon: Icons.format_quote_rounded,
    emptyMessage: 'No testimonials recorded yet',
  ),
  requirement(
    apiValue: 'requirement',
    endpointPath: 'requirements',
    title: 'Requirements',
    icon: Icons.assignment_outlined,
    emptyMessage: 'No requirements recorded yet',
  ),
  impact(
    apiValue: 'impact',
    endpointPath: 'impacts',
    title: 'Impacts',
    icon: Icons.trending_up_rounded,
    emptyMessage: 'No impact activities recorded yet',
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
  /// `referral_given`, `deal_received`, `testimonial`, `requirement`) into a known category.
  static MemberActivityType fromRaw(String? rawType, {String? direction}) {
    final type = (rawType ?? '').toLowerCase().replaceAll(
      RegExp(r'[\s\-]'),
      '_',
    );
    final dir = (direction ?? '').toLowerCase();

    if (type.contains('p2p') || type.contains('meeting')) return p2pMeeting;
    if (type.contains('referral')) {
      if (type.contains('given') || dir.contains('given') || dir == 'giver' || dir == 'out') {
        return referralGiven;
      }
      if (type.contains('receiv') || dir.contains('receiv') || dir == 'receiver' || dir == 'in') {
        return referralReceived;
      }
      return businessReferral;
    }
    if (type.contains('deal') ||
        type.contains('business') ||
        type.contains('tyfcb')) {
      if (type.contains('given') || dir.contains('given') || dir == 'giver' || dir == 'out') {
        return dealGiven;
      }
      if (type.contains('receiv') || dir.contains('receiv') || dir == 'receiver' || dir == 'in') {
        return dealReceived;
      }
      return businessDeal;
    }
    if (type.contains('testimonial')) return testimonial;
    if (type.contains('require')) return requirement;
    if (type.contains('impact')) return impact;
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
    final sourceJson = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    final rawType =
        sourceJson['activity_type'] ??
        sourceJson['type'] ??
        sourceJson['category'] ??
        sourceJson['icon_type'] ??
        json['activity_type'] ??
        json['type'] ??
        fallbackType;

    final direction =
        sourceJson['member_role'] ??
        sourceJson['direction'] ??
        sourceJson['flow'] ??
        json['member_role'] ??
        json['direction'] ??
        json['flow'];

    final type = MemberActivityType.fromRaw(
      rawType?.toString(),
      direction: direction?.toString(),
    );

    final title = _readString(sourceJson, const [
          'title',
          'business_type',
          'name',
          'subject',
        ]) ??
        _readString(json, const [
          'title',
          'business_type',
          'name',
          'subject',
        ]) ??
        type.title;

    final description = _readCleanDescription(sourceJson, json);

    final counterpartName = _readName(sourceJson, const [
          'counterpart_name',
          'counterpart',
          'peer',
          'peer_name',
          'member',
          'with',
          'to_user',
          'from_user',
          'to',
          'from',
        ]) ??
        _readName(json, const [
          'counterpart_name',
          'counterpart',
          'peer',
          'peer_name',
          'member',
          'with',
          'to_user',
          'from_user',
          'to',
          'from',
        ]) ??
        '';

    final rawAmount = sourceJson['amount'] ??
        sourceJson['deal_amount_formatted'] ??
        (sourceJson['deal_amount'] != null
            ? '₹ ${sourceJson['deal_amount']}'
            : null) ??
        json['amount'] ??
        json['deal_amount_formatted'] ??
        (json['deal_amount'] != null ? '₹ ${json['deal_amount']}' : null) ??
        _readString(sourceJson, const ['value', 'coins', 'points']) ??
        _readString(json, const ['value', 'coins', 'points']) ??
        '';

    final status = _readString(sourceJson, const ['status']) ??
        _readString(json, const ['status']) ??
        '';

    final date = _readString(sourceJson, const [
          'deal_date',
          'date',
          'scheduled_at',
          'meeting_date',
          'created_at',
          'time',
        ]) ??
        _readString(json, const [
          'deal_date',
          'date',
          'scheduled_at',
          'meeting_date',
          'created_at',
          'time',
        ]) ??
        '';

    return MemberActivityModel(
      id: (sourceJson['id'] ?? sourceJson['deal_id'] ?? sourceJson['referral_id'] ?? json['id'])?.toString() ?? '',
      type: type,
      title: title,
      description: description,
      counterpartName: counterpartName,
      amount: rawAmount.toString(),
      status: status,
      date: date,
      metadata: _extractMetadata(sourceJson.isNotEmpty ? sourceJson : json),
    );
  }

  static Map<String, dynamic> _extractMetadata(Map<String, dynamic> json) {
    final meta = <String, dynamic>{};

    for (final key in [
      'phone',
      'email',
      'hot_value',
      'referral_type',
      'business_type',
      'member_role',
      'referral_id',
      'comment',
      'city',
      'profile_photo_url',
    ]) {
      if (json[key] != null && json[key].toString().isNotEmpty) {
        meta[key] = json[key];
      }
    }

    final counterpart = json['counterpart'] ?? json['to_user'] ?? json['from_user'];
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
      if (counterpart['phone'] != null &&
          counterpart['phone'].toString().isNotEmpty) {
        meta['phone'] = counterpart['phone'];
      }
      if (counterpart['email'] != null &&
          counterpart['email'].toString().isNotEmpty) {
        meta['email'] = counterpart['email'];
      }
      if (counterpart['profile_photo_url'] != null) {
        meta['profile_photo_url'] = counterpart['profile_photo_url'];
      }
    }

    return meta;
  }

  static String _readCleanDescription(
    Map<String, dynamic> sourceJson,
    Map<String, dynamic> json,
  ) {
    String? extractText(dynamic value) {
      if (value == null) return null;
      if (value is Map) {
        final action = value['action'] ??
            value['description'] ??
            value['title'] ??
            value['name'] ??
            value['message'] ??
            value['remark'] ??
            value['reason'] ??
            value['note'];
        if (action != null && action.toString().trim().isNotEmpty) {
          return action.toString().trim();
        }
      }
      var text = value.toString().trim();
      if (text.isEmpty) return null;

      // Decodes JSON string payload (e.g. `{"impact_id":..., "action":"..."}`)
      if ((text.startsWith('{') && text.endsWith('}')) ||
          (text.startsWith('[') && text.endsWith(']'))) {
        try {
          final decoded = jsonDecode(text);
          if (decoded is Map) {
            final action = decoded['action'] ??
                decoded['description'] ??
                decoded['title'] ??
                decoded['name'] ??
                decoded['message'] ??
                decoded['remark'] ??
                decoded['reason'] ??
                decoded['note'];
            if (action != null && action.toString().trim().isNotEmpty) {
              return action.toString().trim();
            }
          } else if (decoded is List && decoded.isNotEmpty) {
            return decoded.map((e) => e.toString()).join(', ');
          }
        } catch (_) {}
      }

      if (text.startsWith('{') || text.startsWith('{"')) {
        return null;
      }
      return text;
    }

    final candidateKeys = const [
      'description',
      'remark',
      'reference',
      'subtitle',
      'comment',
      'notes',
      'message',
      'reason',
      'details',
      'note',
      'action',
    ];

    for (final key in candidateKeys) {
      final text = extractText(sourceJson[key]) ?? extractText(json[key]);
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    return '';
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
        final name = value['display_name'] ??
            value['name'] ??
            value['full_name'] ??
            (value['first_name'] != null
                ? '${value['first_name']} ${value['last_name'] ?? ''}'.trim()
                : null);
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
