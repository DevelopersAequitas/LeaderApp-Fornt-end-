/// Model representing a sub-industry specialization within a circle.
class SubIndustryItemModel {
  final String id;
  final String name;
  final int peerCount;
  final bool isOpen;

  const SubIndustryItemModel({
    required this.id,
    required this.name,
    required this.peerCount,
    required this.isOpen,
  });

  factory SubIndustryItemModel.fromJson(Map<String, dynamic> json) {
    return SubIndustryItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Specialization',
      peerCount: json['peer_count'] as int? ?? 0,
      isOpen: json['is_open'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'peer_count': peerCount,
        'is_open': isOpen,
      };
}

/// Aggregates active and open sub-industries for a circle.
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
      for (final item in json['active_sub_industries']) {
        active.add(SubIndustryItemModel.fromJson(item as Map<String, dynamic>));
      }
    }

    final open = <SubIndustryItemModel>[];
    if (json['open_sub_industries'] is List) {
      for (final item in json['open_sub_industries']) {
        open.add(SubIndustryItemModel.fromJson(item as Map<String, dynamic>));
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
        'active_sub_industries': activeSubIndustries.map((x) => x.toJson()).toList(),
        'open_sub_industries': openSubIndustries.map((x) => x.toJson()).toList(),
      };
}
