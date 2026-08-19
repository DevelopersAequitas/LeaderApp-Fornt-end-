/// Model representing a peer in the circle.
class PeerModel {
  final String initials;
  final String name;
  final String company;
  final String circle;
  final String location;
  final String tags;
  final int impactCount;
  final String dealsFormatted;
  final int coins;
  final String attendance;
  final String status; // "Active" or "At Risk"
  final String? industry;

  const PeerModel({
    required this.initials,
    required this.name,
    required this.company,
    required this.circle,
    required this.location,
    required this.tags,
    required this.impactCount,
    required this.dealsFormatted,
    required this.coins,
    required this.attendance,
    required this.status,
    this.industry,
  });
}
