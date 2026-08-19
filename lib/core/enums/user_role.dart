/// Defines the distinct user roles in the Leader App.
enum UserRole {
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

  /// Helper to get a role from its label (case-insensitive).
  static UserRole? fromLabel(String label) {
    for (final role in UserRole.values) {
      if (role.label.toLowerCase() == label.toLowerCase()) {
        return role;
      }
    }
    return null;
  }
}
