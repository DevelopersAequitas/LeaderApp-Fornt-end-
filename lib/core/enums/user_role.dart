/// Defines the distinct user roles in the Leader App.
enum UserRole {
  secretary('Secretary'),
  viceChair('Vice Chair'),
  committeeLeader('Committee Leader'),
  chairBusinessGrowth('Chair - Business Growth'),
  chairMembership('Chair - Membership'),
  chairEvents('Chair - Events & Programs'),
  circleChair('Circle Chair'),
  circleFounder('Circle Founder'),
  circleDirector('Circle Director'),
  industryDirector('Industry Director'),
  districtExecDirector('District Exec Director'),
  countryDirector('Country Director'),
  globalFounder('Global Founder'),
  superAdmin('Super Admin');

  /// The user-facing name of the role.
  final String label;

  const UserRole(this.label);

  /// Canonical backend role key for serialization.
  String get backendKey => name;

  /// Returns true if this role is a committee chair or circle chair.
  bool get isChair =>
      this == UserRole.chairBusinessGrowth ||
      this == UserRole.chairMembership ||
      this == UserRole.chairEvents ||
      this == UserRole.circleChair;

  /// Returns true if this role has global executive authority.
  bool get isGlobalExecutive =>
      this == UserRole.superAdmin || this == UserRole.globalFounder;

  /// Returns true if this role is authorized to view and moderate pending requests
  /// (DED, CD, CF, ID, Super Admin, Global Founder, Country Director).
  bool get canModeratePendingRequests =>
      this == UserRole.districtExecDirector ||
      this == UserRole.circleDirector ||
      this == UserRole.circleFounder ||
      this == UserRole.industryDirector ||
      this == UserRole.globalFounder ||
      this == UserRole.superAdmin ||
      this == UserRole.countryDirector;

  /// Returns true ONLY for Super Admin and District Executive Director (DED),
  /// who are authorized to approve or reject Life Impact submissions.
  bool get canReviewLifeImpacts =>
      this == UserRole.superAdmin || this == UserRole.districtExecDirector;

  /// Helper to get a role from its backend key or canonical label (case-insensitive).
  /// Never uses loose substring matching for privileged roles.
  static UserRole? fromLabel(String? label) {
    if (label == null) return null;
    final clean = label
        .trim()
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll(' ', '');
    if (clean.isEmpty) return null;

    if (clean == 'globalfounder') {
      return UserRole.globalFounder;
    }
    if (clean == 'superadmin' || clean == 'globaladmin' || clean == 'admin') {
      return UserRole.superAdmin;
    }
    if (clean == 'countrydirector' || clean == 'eed') {
      return UserRole.countryDirector;
    }
    if (clean == 'ded' ||
        clean == 'districtexecdirector' ||
        clean == 'districtdirector') {
      return UserRole.districtExecDirector;
    }
    if (clean == 'id' || clean == 'ied' || clean == 'industrydirector') {
      return UserRole.industryDirector;
    }
    if (clean == 'cd' || clean == 'director' || clean == 'circledirector') {
      return UserRole.circleDirector;
    }
    if (clean == 'cf' || clean == 'founder' || clean == 'circlefounder') {
      return UserRole.circleFounder;
    }
    if (clean.contains('membershipgrowth') ||
        clean.contains('chairmembership') ||
        clean.contains('membershipcommittee')) {
      return UserRole.chairMembership;
    }
    if (clean.contains('businessgrowth') ||
        clean.contains('chairbusinessgrowth') ||
        clean.contains('businesscommittee')) {
      return UserRole.chairBusinessGrowth;
    }
    if (clean.contains('eventsimpacts') ||
        clean.contains('chairevents') ||
        clean.contains('eventsprograms')) {
      return UserRole.chairEvents;
    }
    if (clean == 'circlechair' || clean == 'chair') {
      return UserRole.circleChair;
    }
    if (clean == 'committeeleader' || clean == 'committeelead') {
      return UserRole.committeeLeader;
    }
    if (clean == 'vicechair') {
      return UserRole.viceChair;
    }
    if (clean == 'secretary' || clean == 'circlesecretary') {
      return UserRole.secretary;
    }

    for (final role in UserRole.values) {
      final normLabel = role.label
          .toLowerCase()
          .replaceAll('_', '')
          .replaceAll('-', '')
          .replaceAll(' ', '');
      final normName = role.name
          .toLowerCase()
          .replaceAll('_', '')
          .replaceAll('-', '')
          .replaceAll(' ', '');
      if (normLabel == clean || normName == clean) {
        return role;
      }
    }
    return null;
  }
}
