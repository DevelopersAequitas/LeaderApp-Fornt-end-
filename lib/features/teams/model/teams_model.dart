/// Model representing user permissions status and credentials for Teams.
class TeamsPermissionModel {
  final String role;
  final bool isRestricted;
  final List<String> requiredCapabilities;

  const TeamsPermissionModel({
    required this.role,
    required this.isRestricted,
    required this.requiredCapabilities,
  });
}

/// Model representing summary metrics across all managed circles.
class TeamsSummaryModel {
  final int totalCircles;
  final int avgHealth;
  final int totalPeers;
  final String totalRevenue;

  const TeamsSummaryModel({
    required this.totalCircles,
    required this.avgHealth,
    required this.totalPeers,
    required this.totalRevenue,
  });

  factory TeamsSummaryModel.fromJson(Map<String, dynamic> json) {
    return TeamsSummaryModel(
      totalCircles: json['total_circles'] as int? ?? 0,
      avgHealth: json['avg_health'] as int? ?? 0,
      totalPeers: json['total_peers'] as int? ?? 0,
      totalRevenue: json['total_revenue']?.toString() ?? '₹0.0',
    );
  }

  Map<String, dynamic> toJson() => {
        'total_circles': totalCircles,
        'avg_health': avgHealth,
        'total_peers': totalPeers,
        'total_revenue': totalRevenue,
      };
}

/// Model representing circle statistics and management details.
class CircleTeamModel {
  final String id;
  final String name;
  final String category;
  final String location;
  final int peersCount;
  final int healthPercentage;
  final String revenue;
  final List<String> tags;
  final String founderName;
  final String directorName;
  final String chairName;
  final String status;
  final String? launchDate;

  const CircleTeamModel({
    this.id = '',
    required this.name,
    required this.category,
    required this.location,
    required this.peersCount,
    required this.healthPercentage,
    required this.revenue,
    required this.tags,
    required this.founderName,
    required this.directorName,
    required this.chairName,
    required this.status,
    this.launchDate,
  });

  factory CircleTeamModel.fromJson(Map<String, dynamic> json) {
    final tagsList = <String>[];
    if (json['tags'] is List) {
      for (final t in json['tags']) {
        tagsList.add(t.toString());
      }
    } else {
      final cat = json['category']?.toString();
      final loc = json['location']?.toString();
      if (cat != null && cat.isNotEmpty) tagsList.add(cat);
      if (loc != null && loc.isNotEmpty) tagsList.add(loc);
    }

    return CircleTeamModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      location: json['location'] as String? ?? '',
      peersCount: json['peers_count'] as int? ?? 0,
      healthPercentage: json['health_percentage'] as int? ?? 0,
      revenue: json['revenue']?.toString() ?? '₹0.0',
      tags: tagsList,
      founderName: json['founders_count'] != null ? '${json['founders_count']} Founders' : (json['founder_name'] as String? ?? ''),
      directorName: json['director_name'] as String? ?? '',
      chairName: json['chair_name'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
      launchDate: json['launch_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'location': location,
        'peers_count': peersCount,
        'health_percentage': healthPercentage,
        'revenue': revenue,
        'tags': tags,
        'founder_name': founderName,
        'director_name': directorName,
        'chair_name': chairName,
        'status': status,
        'launch_date': launchDate,
      };
}
