import '../../peers/model/peer_model.dart';

/// Model representing a peer testimonial.
class TestimonialModel {
  final String id;
  final String authorId;
  final String targetPeerId;
  final String authorName;
  final String authorRole;
  final String targetPeerName;
  final String circleName;
  final String authorInitials;
  final String targetPeerInitials;
  final String profileImage;
  final String city;
  final String categoryLevel4;
  final String content;
  final String date;
  final int rating;

  const TestimonialModel({
    required this.id,
    this.authorId = '',
    this.targetPeerId = '',
    required this.authorName,
    required this.authorRole,
    required this.targetPeerName,
    required this.circleName,
    required this.authorInitials,
    required this.targetPeerInitials,
    this.profileImage = '',
    this.city = '',
    this.categoryLevel4 = '',
    required this.content,
    required this.date,
    this.rating = 5,
  });

  // Backwards compatibility getters
  String get fromName => authorName;
  String get toName => targetPeerName;
  String get fromCompany => authorRole;
  String get toCompany => circleName;
  String get fromInitials => authorInitials;
  String get toInitials => targetPeerInitials;
  String get fromPeerId => authorId;
  String get toPeerId => targetPeerId;

  PeerModel toPeerModel() {
    final effectiveId = authorId.isNotEmpty ? authorId : targetPeerId.isNotEmpty ? targetPeerId : id;
    final effectiveName = authorName.isNotEmpty ? authorName : targetPeerName;
    final effectiveInitials = authorInitials.isNotEmpty ? authorInitials : targetPeerInitials;
    return PeerModel(
      id: effectiveId,
      initials: effectiveInitials,
      name: effectiveName,
      avatarUrl: profileImage.isNotEmpty ? profileImage : null,
      company: authorRole.isNotEmpty ? authorRole : circleName,
      circle: circleName,
      location: city,
      tags: categoryLevel4,
      impactCount: 0,
      dealsFormatted: '₹0',
      coins: 0,
      attendance: '95%',
      status: 'Active',
    );
  }

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    String authorStr = 'Peer';
    String authorIdStr = '';
    final rawAuthor = json['author_name'] ?? json['from_name'] ?? json['author'];
    if (rawAuthor is Map) {
      authorStr = rawAuthor['name']?.toString() ??
          rawAuthor['author_name']?.toString() ??
          'Peer';
      authorIdStr = rawAuthor['id']?.toString() ??
          rawAuthor['peer_id']?.toString() ??
          '';
    } else if (rawAuthor is String) {
      authorStr = rawAuthor;
    }
    if (authorIdStr.isEmpty) {
      authorIdStr = json['author_id']?.toString() ??
          json['from_peer_id']?.toString() ??
          json['from_id']?.toString() ??
          '';
    }

    final authorParts = authorStr.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    final aInitials = authorParts.length > 1
        ? '${authorParts[0][0]}${authorParts[1][0]}'.toUpperCase()
        : (authorStr.length >= 2 ? authorStr.substring(0, 2).toUpperCase() : authorStr.toUpperCase());

    String targetStr = '';
    String targetIdStr = '';
    final rawTarget = json['target_peer_name'] ??
        json['to_name'] ??
        json['target_peer'] ??
        json['recipient'];
    if (rawTarget is Map) {
      targetStr = rawTarget['name']?.toString() ??
          rawTarget['peer_name']?.toString() ??
          '';
      targetIdStr = rawTarget['id']?.toString() ??
          rawTarget['peer_id']?.toString() ??
          '';
    } else if (rawTarget is String) {
      targetStr = rawTarget;
    }
    if (targetIdStr.isEmpty) {
      targetIdStr = json['target_peer_id']?.toString() ??
          json['to_peer_id']?.toString() ??
          json['to_id']?.toString() ??
          '';
    }

    final targetParts = targetStr.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    final tInitials = targetParts.length > 1
        ? '${targetParts[0][0]}${targetParts[1][0]}'.toUpperCase()
        : (targetStr.length >= 2 ? targetStr.substring(0, 2).toUpperCase() : (targetStr.isNotEmpty ? targetStr.toUpperCase() : 'PR'));

    String roleStr = '';
    final rawRole = json['author_role'] ??
        json['from_company'] ??
        json['author_company'] ??
        json['company'];
    if (rawRole is Map) {
      roleStr = rawRole['name']?.toString() ??
          rawRole['role']?.toString() ??
          rawRole['company']?.toString() ??
          '';
    } else if (rawRole is String) {
      roleStr = rawRole;
    }

    String circleStr = '';
    final rawCircle = json['circle_name'] ??
        json['to_company'] ??
        json['target_company'] ??
        json['circle'];
    if (rawCircle is Map) {
      circleStr = rawCircle['name']?.toString() ??
          rawCircle['circle_name']?.toString() ??
          '';
    } else if (rawCircle is String) {
      circleStr = rawCircle;
    }

    String dateStr = '';
    final rawDate = json['date'] ?? json['created_at_human'] ?? json['created_at'];
    if (rawDate is Map) {
      dateStr = rawDate['human']?.toString() ?? rawDate['formatted']?.toString() ?? '';
    } else if (rawDate is String) {
      dateStr = rawDate;
    }

    final peerMap = json['peer'] is Map<String, dynamic>
        ? json['peer'] as Map<String, dynamic>
        : (json['peer'] is Map ? Map<String, dynamic>.from(json['peer'] as Map) : null);

    final profileImg = json['profile_image']?.toString() ??
        json['profile_photo_url']?.toString() ??
        json['avatar_url']?.toString() ??
        peerMap?['profile_image']?.toString() ??
        '';

    final cityStr = json['city']?.toString() ??
        json['location']?.toString() ??
        peerMap?['city']?.toString() ??
        '';

    final catLevel4 = json['category_level4']?.toString() ??
        json['level4_category']?.toString() ??
        json['sub_industry']?.toString() ??
        peerMap?['category_level4']?.toString() ??
        '';

    if (authorIdStr.isEmpty) {
      authorIdStr = json['peer_user_id']?.toString() ??
          json['user_id']?.toString() ??
          peerMap?['peer_user_id']?.toString() ??
          peerMap?['id']?.toString() ??
          '';
    }
    if (authorStr == 'Peer' && (json['peer_name'] != null || peerMap?['name'] != null)) {
      authorStr = json['peer_name']?.toString() ?? peerMap?['name']?.toString() ?? 'Peer';
    }

    final ratingVal = json['rating'] is num
        ? (json['rating'] as num).round()
        : int.tryParse(json['rating']?.toString() ?? '') ?? 5;

    return TestimonialModel(
      id: json['id']?.toString() ?? '',
      authorId: authorIdStr,
      targetPeerId: targetIdStr,
      authorName: authorStr,
      authorRole: roleStr.isNotEmpty ? roleStr : (json['business_name']?.toString() ?? peerMap?['business_name']?.toString() ?? ''),
      targetPeerName: targetStr,
      circleName: circleStr,
      authorInitials: aInitials.isNotEmpty ? aInitials : 'PR',
      targetPeerInitials: tInitials.isNotEmpty ? tInitials : 'PR',
      profileImage: profileImg,
      city: cityStr,
      categoryLevel4: catLevel4,
      content: json['content'] as String? ?? json['message'] as String? ?? '',
      date: dateStr.isNotEmpty ? dateStr : 'Recent',
      rating: ratingVal,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'author_id': authorId,
        'target_peer_id': targetPeerId,
        'author_name': authorName,
        'author_role': authorRole,
        'target_peer_name': targetPeerName,
        'circle_name': circleName,
        'profile_image': profileImage,
        'city': city,
        'category_level4': categoryLevel4,
        'content': content,
        'date': date,
        'rating': rating,
      };
}
