import '../../peers/model/peer_model.dart';

/// Model representing a Business Deal / Deals Done item.
class BusinessDealModel {
  final String id;
  final dynamic amount;
  final String currency;
  final String dealType; // 'closed', 'in_progress', etc.
  final String notes;
  final String peerUserId;
  final String peerName;
  final String profileImage;
  final String city;
  final String businessName;
  final String categoryLevel4;

  const BusinessDealModel({
    this.id = '',
    required this.amount,
    this.currency = 'INR',
    this.dealType = 'closed',
    this.notes = '',
    this.peerUserId = '',
    required this.peerName,
    this.profileImage = '',
    this.city = '',
    this.businessName = '',
    this.categoryLevel4 = '',
  });

  String get amountFormatted {
    if (amount == null) return '₹0';
    final numVal = amount is num ? amount as num : num.tryParse(amount.toString().replaceAll(',', '').trim());
    if (numVal == null) return '$currency $amount';
    if (numVal >= 10000000) {
      return '₹${(numVal / 10000000).toStringAsFixed(1)} Cr';
    } else if (numVal >= 100000) {
      return '₹${(numVal / 100000).toStringAsFixed(1)}L';
    } else if (numVal >= 1000) {
      return '₹${(numVal / 1000).toStringAsFixed(0)}k';
    }
    return '₹$numVal';
  }

  factory BusinessDealModel.fromJson(Map<String, dynamic> json) {
    final peerMap = json['peer'] is Map<String, dynamic>
        ? json['peer'] as Map<String, dynamic>
        : (json['peer'] is Map ? Map<String, dynamic>.from(json['peer'] as Map) : null);

    final peerUserId = json['peer_user_id']?.toString() ??
        json['user_id']?.toString() ??
        json['with_peer_id']?.toString() ??
        peerMap?['peer_user_id']?.toString() ??
        peerMap?['id']?.toString() ??
        '';

    final peerName = (json['peer_name'] as String? ??
            json['name'] as String? ??
            peerMap?['peer_name'] as String? ??
            peerMap?['name'] as String? ??
            'Peer')
        .trim();

    final profileImg = json['profile_image']?.toString() ??
        json['profile_photo_url']?.toString() ??
        json['avatar_url']?.toString() ??
        peerMap?['profile_image']?.toString() ??
        '';

    final city = json['city']?.toString() ??
        json['location']?.toString() ??
        peerMap?['city']?.toString() ??
        '';

    final businessName = json['business_name']?.toString() ??
        json['company_name']?.toString() ??
        json['company']?.toString() ??
        peerMap?['business_name']?.toString() ??
        peerMap?['company_name']?.toString() ??
        '';

    final catLevel4 = json['category_level4']?.toString() ??
        json['level4_category']?.toString() ??
        json['sub_industry']?.toString() ??
        peerMap?['category_level4']?.toString() ??
        '';

    return BusinessDealModel(
      id: json['id']?.toString() ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      dealType: json['deal_type']?.toString() ?? 'closed',
      notes: json['notes']?.toString() ?? '',
      peerUserId: peerUserId,
      peerName: peerName,
      profileImage: profileImg,
      city: city,
      businessName: businessName,
      categoryLevel4: catLevel4,
    );
  }

  PeerModel toPeerModel() {
    final nameParts = peerName.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    final initials = nameParts.length > 1
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (peerName.length >= 2 ? peerName.substring(0, 2).toUpperCase() : (peerName.isNotEmpty ? peerName.toUpperCase() : 'PR'));

    return PeerModel(
      id: peerUserId.isNotEmpty ? peerUserId : id,
      initials: initials,
      name: peerName,
      avatarUrl: profileImage.isNotEmpty ? profileImage : null,
      company: businessName,
      circle: '',
      location: city,
      tags: categoryLevel4,
      impactCount: 0,
      dealsFormatted: amountFormatted,
      coins: 0,
      attendance: '95%',
      status: 'Active',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'currency': currency,
        'deal_type': dealType,
        'notes': notes,
        'peer_user_id': peerUserId,
        'peer_name': peerName,
        'profile_image': profileImage,
        'city': city,
        'business_name': businessName,
        'category_level4': categoryLevel4,
      };
}
