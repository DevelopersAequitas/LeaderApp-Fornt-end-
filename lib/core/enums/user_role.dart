/// Defines the distinct user roles in the Leader App.
enum UserRole {
  chairBusinessGrowth('Chair - Business Growth'),
  chairMembership('Chair - Membership'),
  chairEvents('Chair - Events & Programs'),
  circleChair('Circle Chair'),
  circleFounder('Circle Founder'),
  circleDirector('Circle Director'),
  industryDirector('Industry Director'),
  districtExecDirector('District Exec Director'),
  countryDirector('Country Director'),
  superAdmin('Super Admin');

  /// The user-facing name of the role.
  final String label;

  const UserRole(this.label);

  /// Helper to get a role from its label or key (case-insensitive).
  static UserRole? fromLabel(String label) {
    final clean = label.trim().toLowerCase().replaceAll('_', '').replaceAll('-', '').replaceAll(' ', '');
    for (final role in UserRole.values) {
      final normLabel = role.label.toLowerCase().replaceAll('_', '').replaceAll('-', '').replaceAll(' ', '');
      final normName = role.name.toLowerCase().replaceAll('_', '').replaceAll('-', '').replaceAll(' ', '');
      if (normLabel == clean || normName == clean || clean.contains(normName) || clean.contains(normLabel)) {
        return role;
      }
    }
    return null;
  }
}
