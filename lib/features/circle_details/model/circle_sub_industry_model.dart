import '../../peers/model/peer_model.dart';

/// Model representing a sub-industry specialization (Level 4 category) within a circle.
class SubIndustryItemModel {
  final String id;
  final String name;
  final String? sectorName;
  final String? subcategoryName;
  final int peerCount;
  final bool isOpen;
  final PeerModel? occupant;
  final List<PeerModel> peers;

  const SubIndustryItemModel({
    required this.id,
    required this.name,
    this.sectorName,
    this.subcategoryName,
    required this.peerCount,
    required this.isOpen,
    this.occupant,
    this.peers = const [],
  });

  /// Formatted sector/subcategory breadcrumb matching Peers Global Unity.
  String get breadcrumb {
    final parts = <String>[];
    if (sectorName != null && sectorName!.trim().isNotEmpty) {
      parts.add(sectorName!.trim());
    }
    if (subcategoryName != null &&
        subcategoryName!.trim().isNotEmpty &&
        subcategoryName!.trim() != sectorName?.trim()) {
      parts.add(subcategoryName!.trim());
    }
    return parts.join(' › ');
  }

  factory SubIndustryItemModel.fromJson(Map<String, dynamic> json) {
    String? sector = json['sector_name']?.toString();
    if ((sector == null || sector.isEmpty) && json['parent_level2'] is Map) {
      sector = (json['parent_level2'] as Map)['name']?.toString();
    }

    String? subcat = json['subcategory_name']?.toString();
    if ((subcat == null || subcat.isEmpty) && json['parent_level3'] is Map) {
      subcat = (json['parent_level3'] as Map)['name']?.toString();
    }

    final parsedPeers = <PeerModel>[];
    if (json['peers'] is List) {
      for (final raw in json['peers'] as List) {
        if (raw is Map) {
          parsedPeers.add(PeerModel.fromJson(Map<String, dynamic>.from(raw)));
        }
      }
    }

    PeerModel? parsedOccupant;
    if (json['occupant'] is Map) {
      parsedOccupant = PeerModel.fromJson(
        Map<String, dynamic>.from(json['occupant'] as Map),
      );
    } else if (json['occupied_by'] is Map) {
      final occ = Map<String, dynamic>.from(json['occupied_by'] as Map);
      occ['level4_category'] ??= json['name']?.toString();
      parsedOccupant = PeerModel.fromJson(occ);
    } else if (parsedPeers.isNotEmpty) {
      parsedOccupant = parsedPeers.first;
    }

    if (parsedPeers.isEmpty && parsedOccupant != null) {
      parsedPeers.add(parsedOccupant);
    }

    return SubIndustryItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Specialization',
      sectorName: sector,
      subcategoryName: subcat,
      peerCount: int.tryParse(json['peer_count']?.toString() ?? '') ??
          parsedPeers.length,
      isOpen: json['is_open'] as bool? ?? false,
      occupant: parsedOccupant,
      peers: parsedPeers,
    );
  }

  SubIndustryItemModel copyWith({
    String? id,
    String? name,
    String? sectorName,
    String? subcategoryName,
    int? peerCount,
    bool? isOpen,
    PeerModel? occupant,
    List<PeerModel>? peers,
  }) {
    return SubIndustryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sectorName: sectorName ?? this.sectorName,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      peerCount: peerCount ?? this.peerCount,
      isOpen: isOpen ?? this.isOpen,
      occupant: occupant ?? this.occupant,
      peers: peers ?? this.peers,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (sectorName != null) 'sector_name': sectorName,
        if (subcategoryName != null) 'subcategory_name': subcategoryName,
        'peer_count': peerCount,
        'is_open': isOpen,
      };
}

/// Aggregates active (closed/occupied) and open sub-industries for a circle.
class CircleSubIndustriesResponse {
  final String circleId;
  final List<SubIndustryItemModel> activeSubIndustries;
  final List<SubIndustryItemModel> openSubIndustries;

  const CircleSubIndustriesResponse({
    required this.circleId,
    required this.activeSubIndustries,
    required this.openSubIndustries,
  });

  factory CircleSubIndustriesResponse.fromJson(Map<String, dynamic> json) {
    final active = <SubIndustryItemModel>[];
    if (json['active_sub_industries'] is List) {
      for (final item in json['active_sub_industries'] as List) {
        if (item is Map) {
          active.add(
            SubIndustryItemModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final open = <SubIndustryItemModel>[];
    if (json['open_sub_industries'] is List) {
      for (final item in json['open_sub_industries'] as List) {
        if (item is Map) {
          open.add(
            SubIndustryItemModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return CircleSubIndustriesResponse(
      circleId: json['circle_id']?.toString() ?? '',
      activeSubIndustries: active,
      openSubIndustries: open,
    );
  }

  Map<String, dynamic> toJson() => {
        'circle_id': circleId,
        'active_sub_industries':
            activeSubIndustries.map((x) => x.toJson()).toList(),
        'open_sub_industries':
            openSubIndustries.map((x) => x.toJson()).toList(),
      };
}

/// Model representing a saved/synced contact for the 'From Contact' referral tab.
class ReferralContactModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String company;
  final String designation;
  final String city;

  const ReferralContactModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.company = '',
    this.designation = '',
    this.city = '',
  });

  factory ReferralContactModel.fromJson(Map<String, dynamic> json) {
    return ReferralContactModel(
      id: json['id']?.toString() ?? '',
      name: (json['name'] ?? json['contact_name'] ?? '').toString().trim(),
      phone: (json['phone'] ?? json['mobile'] ?? json['contact_phone'] ?? '')
          .toString()
          .trim(),
      email: (json['email'] ?? json['contact_email'] ?? '').toString().trim(),
      company: (json['company'] ??
              json['company_name'] ??
              json['business_name'] ??
              '')
          .toString()
          .trim(),
      designation: (json['designation'] ?? json['role'] ?? '').toString().trim(),
      city: (json['city'] ?? json['location'] ?? '').toString().trim(),
    );
  }
}
