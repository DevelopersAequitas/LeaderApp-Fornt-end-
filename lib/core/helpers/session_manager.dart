import '../enums/user_role.dart';
import '../models/leader_permissions.dart';
import '../storage/secure_storage_service.dart';
import '../storage/hive_cache_service.dart';

/// A session profile model describing a logged-in user.
class UserSession {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String regionalScope;
  final List<String> managedCircles;
  final String memberSince;
  final int capabilitiesCount;
  final String? customRoleLabel;
  final String? avatarUrl;

  const UserSession({
    this.id = '',
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.regionalScope,
    required this.managedCircles,
    required this.memberSince,
    required this.capabilitiesCount,
    this.customRoleLabel,
    this.avatarUrl,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role'] as String? ?? 'circleChair';
    final normalizedRaw = rawRole.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
    UserRole resolvedRole = UserRole.circleChair;
    for (final r in UserRole.values) {
      final normName = r.name.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
      final normLabel = r.label.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
      if (normName == normalizedRaw ||
          normLabel == normalizedRaw ||
          normalizedRaw.contains(normName)) {
        resolvedRole = r;
        break;
      }
    }

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

    return UserSession(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: resolvedRole,
      regionalScope: json['regional_scope'] as String? ?? 'Own Circle',
      managedCircles: managedList,
      memberSince: json['member_since'] as String? ?? 'Aug 2026',
      capabilitiesCount: (json['capabilities_count'] as int?) ?? 14,
      customRoleLabel: json['custom_role_label'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

/// Singleton manager for tracking the active user's session, tokens, and role-based permissions
/// with hardware-encrypted secure storage and offline document caching.
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  String? _authToken;
  String? _refreshToken;
  LeaderPermissions _permissions = const LeaderPermissions();

  /// Gets the current Bearer token.
  String? get authToken => _authToken;

  /// Gets the refresh token.
  String? get refreshToken => _refreshToken;

  /// Whether the user has an active authenticated session.
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  /// Gets the current dynamic permissions matrix.
  LeaderPermissions get permissions => _permissions;

  /// Loads the persisted session and tokens from encrypted secure storage on app startup.
  Future<bool> loadPersistedSession() async {
    try {
      final token = await SecureStorageService().getAuthToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      final session = await SecureStorageService().getUserSession();
      final permissions = await SecureStorageService().getPermissions();
      final refreshToken = await SecureStorageService().getRefreshToken();

      _authToken = token;
      _refreshToken = refreshToken;
      if (session != null) {
        _currentSession = session;
      }
      if (permissions != null) {
        _permissions = permissions;
      } else {
        _resolvePredefinedPermissions(_currentSession.role);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Sets the authentication tokens and permissions from API response and persists them securely.
  Future<void> setAuthSession({
    required String token,
    String? refreshToken,
    required UserSession session,
    LeaderPermissions? permissions,
  }) async {
    _authToken = token;
    _refreshToken = refreshToken;
    _currentSession = session;
    if (permissions != null) {
      _permissions = permissions;
    } else {
      _resolvePredefinedPermissions(session.role);
    }

    // Persist securely to device storage
    await SecureStorageService().saveAuthSession(
      token: token,
      refreshToken: refreshToken,
      session: session,
      permissions: _permissions,
    );
  }

  /// Updates active session and dynamic capabilities directly from GET /api/v1/auth/profile response.
  Future<void> updateFromAuthProfile(Map<String, dynamic> data) async {
    final userMap = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data;
    _currentSession = UserSession.fromJson(userMap);

    if (data['permissions'] is Map && data['permissions']['enabled_capabilities'] is List) {
      final caps = (data['permissions']['enabled_capabilities'] as List)
          .map((e) => e.toString())
          .toList();
      _permissions = LeaderPermissions.fromCapabilities(caps);
    } else if (data['enabled_capabilities'] is List) {
      final caps = (data['enabled_capabilities'] as List)
          .map((e) => e.toString())
          .toList();
      _permissions = LeaderPermissions.fromCapabilities(caps);
    } else {
      _resolvePredefinedPermissions(_currentSession.role);
    }

    if (_authToken != null && _authToken!.isNotEmpty) {
      await SecureStorageService().saveAuthSession(
        token: _authToken!,
        refreshToken: _refreshToken,
        session: _currentSession,
        permissions: _permissions,
      );
    }
  }

  /// The active user session. Defaults to Circle Chair (Arjun Patel).
  UserSession _currentSession = const UserSession(
    id: '',
    name: 'Leader',
    email: '',
    phone: '',
    role: UserRole.circleChair,
    regionalScope: 'District',
    managedCircles: [],
    memberSince: '',
    capabilitiesCount: 14,
  );

  /// Gets the current user session details.
  UserSession get currentSession => _currentSession;

  /// Gets the current active role.
  UserRole get currentRole => _currentSession.role;

  /// Clears the session and wipes all secure storage tokens upon sign out.
  Future<void> clearSession() async {
    _authToken = null;
    _refreshToken = null;
    _permissions = const LeaderPermissions();
    _currentSession = const UserSession(
      id: '',
      name: 'Leader',
      email: '',
      phone: '',
      role: UserRole.circleChair,
      regionalScope: 'District',
      managedCircles: [],
      memberSince: '',
      capabilitiesCount: 14,
    );

    // Delete tokens and clear offline document cache
    await SecureStorageService().clearAll();
    await HiveCacheService().clearAll();
  }

  /// Initializes the session based on the email/phone used to log in.
  void initializeSession(String emailOrPhone) {
    final cleanInput = emailOrPhone.trim().toLowerCase();
    _currentSession = UserSession(
      name: cleanInput.contains('@') ? cleanInput.split('@').first : cleanInput,
      email: cleanInput.contains('@') ? cleanInput : '',
      phone: !cleanInput.contains('@') ? cleanInput : '',
      role: UserRole.circleChair,
      regionalScope: 'District',
      managedCircles: const [],
      memberSince: '',
      capabilitiesCount: 10,
    );
    _resolvePredefinedPermissions(UserRole.circleChair);
  }

  /// Cache of dynamic role capabilities mapped by roleId / roleName.
  static final Map<String, List<String>> _roleCapabilitiesMatrix = {};

  /// Updates the cached capabilities for a role and applies them if matching active session.
  void updateRoleCapabilitiesMatrix(String roleKey, List<String> capabilities) {
    final cleanKey = roleKey.trim().toLowerCase();
    _roleCapabilitiesMatrix[cleanKey] = capabilities;

    // If active session matches this role key, immediately update permissions
    final currentRoleName = _currentSession.role.name.toLowerCase();
    final currentRoleLabel = _currentSession.role.label.toLowerCase();
    final customLabel = (_currentSession.customRoleLabel ?? '').toLowerCase();

    if (cleanKey == currentRoleName ||
        cleanKey == currentRoleLabel ||
        cleanKey == customLabel ||
        cleanKey == _currentSession.id.toLowerCase()) {
      _permissions = LeaderPermissions.fromCapabilities(capabilities);
      SecureStorageService().savePermissions(_permissions);
    }
  }

  void _resolvePredefinedPermissions(UserRole role) {
    final roleKey = role.name.toLowerCase();
    if (_roleCapabilitiesMatrix.containsKey(roleKey)) {
      _permissions = LeaderPermissions.fromCapabilities(
        _roleCapabilitiesMatrix[roleKey]!,
      );
      return;
    }

    switch (role) {
      case UserRole.chairBusinessGrowth:
      case UserRole.chairEvents:
      case UserRole.circleChair:
        _permissions = const LeaderPermissions(
          canAccessDashboard: true,
          canViewOverallRevenue: false,
          canReviewPendingPeers: true,
          canAccessPeersTab: true,
          canAddEditPeer: false,
          canSendWishes: true,
          canAccessTeamsTab: false,
          canAccessFinanceTab: false,
          canAccessReportsTab: true,
          canSubmitReports: true,
          canAccessRoleManagement: false,
        );
        break;
      case UserRole.chairMembership:
        _permissions = const LeaderPermissions(
          canAccessDashboard: true,
          canViewOverallRevenue: false,
          canReviewPendingPeers: true,
          canAccessPeersTab: true,
          canAddEditPeer: true,
          canSendWishes: true,
          canAccessTeamsTab: false,
          canAccessFinanceTab: false,
          canAccessReportsTab: true,
          canSubmitReports: true,
          canAccessRoleManagement: false,
        );
        break;
      case UserRole.circleFounder:
      case UserRole.circleDirector:
        _permissions = const LeaderPermissions(
          canAccessDashboard: true,
          canViewOverallRevenue: true,
          canReviewPendingPeers: true,
          canAccessPeersTab: true,
          canAddEditPeer: true,
          canSendWishes: true,
          canAccessTeamsTab: true,
          canManageCircles: true,
          canAccessFinanceTab: true,
          canAccessReportsTab: true,
          canSubmitReports: true,
          canExportPeerData: true,
          canAccessRoleManagement: false,
        );
        break;
      case UserRole.industryDirector:
        _permissions = const LeaderPermissions(
          canAccessDashboard: true,
          canViewOverallRevenue: true,
          canReviewPendingPeers: false,
          canAccessPeersTab: true,
          canAddEditPeer: false,
          canSendWishes: true,
          canAccessTeamsTab: true,
          canManageCircles: true,
          canAccessFinanceTab: true,
          canAccessReportsTab: true,
          canSubmitReports: false,
          canExportPeerData: true,
          canAccessRoleManagement: false,
          canViewRegionalScope: true,
        );
        break;
      case UserRole.districtExecDirector:
        _permissions = const LeaderPermissions(
          canAccessDashboard: true,
          canViewOverallRevenue: true,
          canReviewPendingPeers: true,
          canAccessPeersTab: true,
          canAddEditPeer: true,
          canSendWishes: true,
          canAccessTeamsTab: true,
          canManageCircles: true,
          canAssignCircleChair: true,
          canAccessFinanceTab: true,
          canModifyFinanceSettings: true,
          canAccessReportsTab: true,
          canSubmitReports: false,
          canExportPeerData: true,
          canExportFinancialData: true,
          canAccessRoleManagement: false,
          canViewRegionalScope: true,
        );
        break;
      case UserRole.countryDirector:
        _permissions = const LeaderPermissions(
          canAccessDashboard: true,
          canViewOverallRevenue: true,
          canReviewPendingPeers: false,
          canAccessPeersTab: true,
          canAddEditPeer: true,
          canSendWishes: true,
          canAccessTeamsTab: true,
          canManageCircles: true,
          canAssignCircleChair: true,
          canAccessFinanceTab: true,
          canModifyFinanceSettings: true,
          canIssueCoins: true,
          canAccessReportsTab: true,
          canSubmitReports: false,
          canExportPeerData: true,
          canExportFinancialData: true,
          canAccessRoleManagement: false,
          canViewRegionalScope: true,
        );
        break;
      case UserRole.superAdmin:
        _permissions = const LeaderPermissions(
          canAccessDashboard: true,
          canViewOverallRevenue: true,
          canReviewPendingPeers: true,
          canAccessPeersTab: true,
          canAddEditPeer: true,
          canSendWishes: true,
          canAccessTeamsTab: true,
          canManageCircles: true,
          canAssignCircleChair: true,
          canAccessFinanceTab: true,
          canModifyFinanceSettings: true,
          canIssueCoins: true,
          canAccessReportsTab: true,
          canSubmitReports: true,
          canExportPeerData: true,
          canExportFinancialData: true,
          canExportGlobalData: true,
          canAccessRoleManagement: true,
          canViewRegionalScope: true,
        );
        break;
    }
  }

  /// Dynamic custom roles created at runtime.
  static final List<String> _dynamicRoleLabels = [];
  List<String> get dynamicRoleLabels => _dynamicRoleLabels;

  void addDynamicRole(String label) {
    final trimLabel = label.trim();
    if (trimLabel.isEmpty) return;
    if (!_dynamicRoleLabels.contains(trimLabel)) {
      _dynamicRoleLabels.add(trimLabel);
    }
  }

  void removeDynamicRole(String label) {
    _dynamicRoleLabels.remove(label.trim());
  }

  void renameDynamicRole(String oldLabel, String newLabel) {
    final index = _dynamicRoleLabels.indexOf(oldLabel.trim());
    if (index != -1 && newLabel.trim().isNotEmpty) {
      _dynamicRoleLabels[index] = newLabel.trim();
    }
  }
}
