class RoleModel {
  final String id;
  final String? roleKey;
  final String label;
  final bool isSystemRole;

  const RoleModel({
    required this.id,
    this.roleKey,
    required this.label,
    this.isSystemRole = false,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id']?.toString() ?? json['role_key']?.toString() ?? '',
      roleKey: json['role_key'] as String?,
      label: json['label'] as String? ?? 'Role',
      isSystemRole: json['is_system_role'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (roleKey != null) 'role_key': roleKey,
        'label': label,
        'is_system_role': isSystemRole,
      };

  RoleModel copyWith({
    String? label,
    String? roleKey,
  }) {
    return RoleModel(
      id: id,
      roleKey: roleKey ?? this.roleKey,
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

  factory AppCapability.fromJson(Map<String, dynamic> json) {
    return AppCapability(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'description': description,
      };

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

  factory RolePermissionModel.fromJson(Map<String, dynamic> json) {
    final enabledCaps = <String>[];
    if (json['enabled_capabilities'] is List) {
      for (final cap in json['enabled_capabilities']) {
        enabledCaps.add(cap.toString());
      }
    }

    final RoleModel roleModel;
    if (json['role'] is Map<String, dynamic>) {
      roleModel = RoleModel.fromJson(json['role'] as Map<String, dynamic>);
    } else {
      roleModel = RoleModel.fromJson(json);
    }

    return RolePermissionModel(
      role: roleModel,
      enabledCapabilityIds: enabledCaps,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': role.id,
        'label': role.label,
        'is_system_role': role.isSystemRole,
        'enabled_capabilities': enabledCapabilityIds,
      };

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
