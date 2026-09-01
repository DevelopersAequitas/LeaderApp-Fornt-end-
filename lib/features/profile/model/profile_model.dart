/// Model representing the active leader's full profile details matching GET /api/v1/auth/profile.
class UserProfileModel {
  final String id;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String companyName;
  final String company;
  final String city;
  final String location;
  final String designation;
  final String businessCategory;
  final String industry;
  final String level4Category;
  final String profilePhotoUrl;
  final String avatarUrl;
  final int lifeImpact;
  final String role;
  final String customRoleLabel;
  final String roleLabel;
  final String regionalScope;
  final String memberSince;
  final int capabilitiesCount;
  final List<String> managedCircles;
  final List<String> enabledCapabilityNames;
  final String bio;

  const UserProfileModel({
    this.id = '',
    required this.name,
    this.firstName = '',
    this.lastName = '',
    required this.email,
    required this.phone,
    this.companyName = '',
    required this.company,
    this.city = '',
    required this.location,
    this.designation = '',
    this.businessCategory = '',
    this.industry = '',
    this.level4Category = '',
    this.profilePhotoUrl = '',
    this.avatarUrl = '',
    this.lifeImpact = 0,
    this.role = '',
    this.customRoleLabel = '',
    required this.roleLabel,
    required this.regionalScope,
    required this.memberSince,
    required this.capabilitiesCount,
    required this.managedCircles,
    this.enabledCapabilityNames = const [],
    this.bio = '',
  });

  factory UserProfileModel.fromJson(
    Map<String, dynamic> json, {
    List<String>? enabledCapabilities,
  }) {
    final managedList = <String>[];
    if (json['managed_circles'] is List) {
      for (final item in json['managed_circles']) {
        if (item is Map && item['name'] != null) {
          managedList.add(item['name'].toString());
        } else if (item is String) {
          managedList.add(item);
        }
      }
    }

    final companyStr = (json['company_name'] ?? json['company'] ?? '').toString();
    final cityStr = (json['city'] ?? json['location'] ?? '').toString();
    final industryStr = (json['business_category'] ?? json['industry'] ?? '').toString();
    final level4Str = (json['level_4_category'] ?? json['level4_category'] ?? '').toString();
    final photoUrl = (json['profile_photo_url'] ?? json['avatar_url'] ?? '').toString();
    final impactVal = (json['life_impact'] as int?) ?? (json['life_impacted_count'] as int?) ?? 0;
    final customRole = json['custom_role_label'] as String? ?? '';
    final roleVal = json['role'] as String? ?? '';
    final roleDisplay = customRole.isNotEmpty ? customRole : (roleVal.isNotEmpty ? roleVal : 'Leader');

    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      companyName: json['company_name'] as String? ?? companyStr,
      company: companyStr,
      city: cityStr,
      location: cityStr,
      designation: json['designation'] as String? ?? '',
      businessCategory: json['business_category'] as String? ?? industryStr,
      industry: industryStr,
      level4Category: level4Str,
      profilePhotoUrl: photoUrl,
      avatarUrl: photoUrl,
      lifeImpact: impactVal,
      role: roleVal,
      customRoleLabel: customRole,
      roleLabel: roleDisplay,
      regionalScope: json['regional_scope'] as String? ?? '',
      memberSince: json['member_since'] as String? ?? '',
      capabilitiesCount: (json['capabilities_count'] as int?) ?? (enabledCapabilities?.length ?? 0),
      managedCircles: managedList,
      enabledCapabilityNames: enabledCapabilities ?? const [],
      bio: json['bio'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'company_name': companyName,
        'company': company,
        'city': city,
        'location': location,
        'designation': designation,
        'business_category': businessCategory,
        'industry': industry,
        'level_4_category': level4Category,
        'level4_category': level4Category,
        'profile_photo_url': profilePhotoUrl,
        'avatar_url': avatarUrl,
        'life_impact': lifeImpact,
        'life_impacted_count': lifeImpact,
        'role': role,
        'custom_role_label': customRoleLabel,
        'regional_scope': regionalScope,
        'managed_circles': managedCircles,
        'member_since': memberSince,
        'capabilities_count': capabilitiesCount,
        'bio': bio,
      };
}
