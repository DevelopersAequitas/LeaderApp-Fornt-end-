/// Model representing user profile details.
class UserProfileModel {
  final String name;
  final String phone;
  final String email;
  final String regionalScope;
  final String memberSince;
  final int capabilitiesCount;
  final String managedCircleName;
  final int managedCirclePeers;
  final String managedCircleStatus;

  const UserProfileModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.regionalScope,
    required this.memberSince,
    required this.capabilitiesCount,
    required this.managedCircleName,
    required this.managedCirclePeers,
    required this.managedCircleStatus,
  });
}
