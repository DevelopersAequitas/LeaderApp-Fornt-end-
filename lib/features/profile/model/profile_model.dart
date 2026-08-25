/// Model representing the active leader's full profile details.
class UserProfileModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String roleLabel;
  final String regionalScope;
  final String memberSince;
  final int capabilitiesCount;
  final List<String> managedCircles;
  final List<String> enabledCapabilityNames;
  final String avatarUrl;
  final String bio;
  final String company;

  const UserProfileModel({
    this.id = '',
    required this.name,
    required this.phone,
    required this.email,
    required this.roleLabel,
    required this.regionalScope,
    required this.memberSince,
    required this.capabilitiesCount,
    required this.managedCircles,
    this.enabledCapabilityNames = const [],
    this.avatarUrl = '',
    this.bio = '',
    this.company = '',
  });
}
