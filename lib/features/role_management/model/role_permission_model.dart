/// Represents a dynamic role in the application.
class RoleModel {
  final String id;
  final String label;
  final bool isSystemRole;

  const RoleModel({
    required this.id,
    required this.label,
    this.isSystemRole = false,
  });

  RoleModel copyWith({
    String? label,
  }) {
    return RoleModel(
      id: id,
      label: label ?? this.label,
      isSystemRole: isSystemRole,
    );
  }
}

/// Represents a specific application permission or capability.
class AppCapability {
  final String id;
  final String name;
  final String category;
  final String description;

  const AppCapability({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
  });

  /// Default predefined list of system capabilities.
  static List<AppCapability> get defaultCapabilities => const [
        // Navigation & Access
        AppCapability(
          id: 'access_dashboard',
          name: 'Access Dashboard',
          category: 'Navigation & Access',
          description: 'Allows access to the primary metrics and impacter list dashboard.',
        ),
        AppCapability(
          id: 'access_teams',
          name: 'Access Circles & Teams',
          category: 'Navigation & Access',
          description: 'Allows viewing circles, directors, and chairs directories.',
        ),
        AppCapability(
          id: 'access_finance',
          name: 'Access Financial Analytics',
          category: 'Navigation & Access',
          description: 'Allows viewing fee collections, dues, and transaction histories.',
        ),
        AppCapability(
          id: 'regional_data',
          name: 'View Regional Scope Data',
          category: 'Navigation & Access',
          description: 'Access and filter data beyond own local circle (District/Country level).',
        ),

        // Core Operations
        AppCapability(
          id: 'view_peers',
          name: 'View Peer Profiles',
          category: 'Core Operations',
          description: 'Allows viewing and browsing peer profile details and attendance stats.',
        ),
        AppCapability(
          id: 'manage_peers',
          name: 'Add/Edit Peer Information',
          category: 'Core Operations',
          description: 'Allows coordinators to add new peers or edit biographical fields.',
        ),
        AppCapability(
          id: 'request_actions',
          name: 'Endorse Testimonials & Referrals',
          category: 'Core Operations',
          description: 'Allows creating and endorsing peer testimonials and registering new referrals.',
        ),
        AppCapability(
          id: 'view_reports',
          name: 'View Performance Reports',
          category: 'Core Operations',
          description: 'Allows accessing downloadable PDFs and spreadsheets of peer activities.',
        ),

        // Financial Control
        AppCapability(
          id: 'manage_finance',
          name: 'Modify Financial Settings',
          category: 'Financial Control',
          description: 'Allows modifying annual fees, approval of dues, and updating ledger settings.',
        ),
        AppCapability(
          id: 'coin_payouts',
          name: 'Issue Coin Payouts',
          category: 'Financial Control',
          description: 'Allows awarding platform coins directly to peers for special achievements.',
        ),

        // Administration
        AppCapability(
          id: 'manage_roles',
          name: 'Manage App Roles (Matrix)',
          category: 'Administration',
          description: 'Allows altering permission rules and toggling capabilities per role.',
        ),
        AppCapability(
          id: 'system_configs',
          name: 'System Global Settings',
          category: 'Administration',
          description: 'Allows modifying global server variables, maintenance modes, and metadata keys.',
        ),
      ];
}

/// Binds a dynamic role model with their enabled capability list.
class RolePermissionModel {
  final RoleModel role;
  final List<String> enabledCapabilityIds;

  const RolePermissionModel({
    required this.role,
    required this.enabledCapabilityIds,
  });

  RolePermissionModel copyWith({
    RoleModel? role,
    List<String>? enabledCapabilityIds,
  }) {
    return RolePermissionModel(
      role: role ?? this.role,
      enabledCapabilityIds: enabledCapabilityIds ?? this.enabledCapabilityIds,
    );
  }
}
