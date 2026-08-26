/// Model representing a peer testimonial endorsement.
class TestimonialModel {
  final String id;
  final String fromPeerId;
  final String toPeerId;
  final String fromName;
  final String toName;
  final String fromCompany;
  final String toCompany;
  final String fromInitials;
  final String toInitials;
  final int rating;
  final String content;
  final String date;

  const TestimonialModel({
    required this.id,
    this.fromPeerId = '',
    this.toPeerId = '',
    required this.fromName,
    required this.toName,
    required this.fromCompany,
    required this.toCompany,
    required this.fromInitials,
    required this.toInitials,
    required this.rating,
    required this.content,
    required this.date,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    String fromNameStr = 'Peer';
    String fromPeerIdStr = '';
    final rawFromName = json['author_name'] ?? json['from_name'] ?? json['author'];
    if (rawFromName is Map) {
      fromNameStr = rawFromName['name']?.toString() ??
          rawFromName['author_name']?.toString() ??
          'Peer';
      fromPeerIdStr = rawFromName['id']?.toString() ??
          rawFromName['peer_id']?.toString() ??
          '';
    } else if (rawFromName is String) {
      fromNameStr = rawFromName;
    }
    if (fromPeerIdStr.isEmpty) {
      fromPeerIdStr = json['author_id']?.toString() ??
          json['from_peer_id']?.toString() ??
          json['from_id']?.toString() ??
          '';
    }

    final fromParts = fromNameStr.trim().split(' ');
    final fromInitials = fromParts.length > 1
        ? '${fromParts[0].isNotEmpty ? fromParts[0][0] : ""}${fromParts[1].isNotEmpty ? fromParts[1][0] : ""}'
        : (fromNameStr.length >= 2 ? fromNameStr.substring(0, 2).toUpperCase() : fromNameStr.toUpperCase());

    String toNameStr = '';
    String toPeerIdStr = '';
    final rawToName = json['target_peer_name'] ??
        json['to_name'] ??
        json['target_peer'] ??
        json['recipient'];
    if (rawToName is Map) {
      toNameStr = rawToName['name']?.toString() ??
          rawToName['peer_name']?.toString() ??
          '';
      toPeerIdStr = rawToName['id']?.toString() ??
          rawToName['peer_id']?.toString() ??
          '';
    } else if (rawToName is String) {
      toNameStr = rawToName;
    }
    if (toPeerIdStr.isEmpty) {
      toPeerIdStr = json['target_peer_id']?.toString() ??
          json['to_peer_id']?.toString() ??
          json['to_id']?.toString() ??
          '';
    }

    final toParts = toNameStr.trim().split(' ');
    final toInitials = toParts.length > 1
        ? '${toParts[0].isNotEmpty ? toParts[0][0] : ""}${toParts[1].isNotEmpty ? toParts[1][0] : ""}'
        : (toNameStr.length >= 2 ? toNameStr.substring(0, 2).toUpperCase() : toNameStr.toUpperCase());

    String fromCompanyStr = '';
    final rawFromCompany = json['author_role'] ??
        json['from_company'] ??
        json['author_company'] ??
        json['company'];
    if (rawFromCompany is Map) {
      fromCompanyStr = rawFromCompany['name']?.toString() ??
          rawFromCompany['company']?.toString() ??
          rawFromCompany['role']?.toString() ??
          '';
    } else if (rawFromCompany is String) {
      fromCompanyStr = rawFromCompany;
    }

    String toCompanyStr = '';
    final rawToCompany = json['circle_name'] ??
        json['to_company'] ??
        json['target_company'] ??
        json['circle'];
    if (rawToCompany is Map) {
      toCompanyStr = rawToCompany['name']?.toString() ??
          rawToCompany['circle_name']?.toString() ??
          '';
    } else if (rawToCompany is String) {
      toCompanyStr = rawToCompany;
    }

    String dateStr = '';
    final rawDate = json['date'] ?? json['created_at_human'] ?? json['created_at'];
    if (rawDate is Map) {
      dateStr = rawDate['human']?.toString() ?? rawDate['formatted']?.toString() ?? '';
    } else if (rawDate is String) {
      dateStr = rawDate;
    }

    return TestimonialModel(
      id: json['id']?.toString() ?? '',
      fromPeerId: fromPeerIdStr,
      toPeerId: toPeerIdStr,
      fromName: fromNameStr,
      toName: toNameStr,
      fromCompany: fromCompanyStr,
      toCompany: toCompanyStr,
      fromInitials: fromInitials.isNotEmpty ? fromInitials : 'PR',
      toInitials: toInitials.isNotEmpty ? toInitials : 'PR',
      rating: json['rating'] as int? ?? 5,
      content: json['content'] as String? ?? json['message'] as String? ?? '',
      date: dateStr.isNotEmpty ? dateStr : 'Recent',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'from_peer_id': fromPeerId,
        'to_peer_id': toPeerId,
        'author_name': fromName,
        'target_peer_name': toName,
        'author_role': fromCompany,
        'circle_name': toCompany,
        'rating': rating,
        'content': content,
        'date': date,
      };
}
