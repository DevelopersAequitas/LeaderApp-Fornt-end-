/// Model representing a single user role (system or dynamic custom role).
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
      id: json['id']?.toString() ?? '',
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
    String? id,
    String? roleKey,
    String? label,
    bool? isSystemRole,
  }) {
    return RoleModel(
      id: id ?? this.id,
      roleKey: roleKey ?? this.roleKey,
      label: label ?? this.label,
      isSystemRole: isSystemRole ?? this.isSystemRole,
    );
  }
}

/// Represents a specific application permission or capability returned by the backend matrix.
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
}

/// Binds a dynamic role model with its enabled capability list.
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
      final roleMap = json['role'] as Map<String, dynamic>;
      roleModel = RoleModel.fromJson({
        ...roleMap,
        if (!roleMap.containsKey('id') && json.containsKey('id')) 'id': json['id'],
        if (!roleMap.containsKey('label') && json.containsKey('label')) 'label': json['label'],
        if (!roleMap.containsKey('role_key') && json.containsKey('role_key')) 'role_key': json['role_key'],
        if (!roleMap.containsKey('is_system_role') && json.containsKey('is_system_role'))
          'is_system_role': json['is_system_role'],
      });
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
        if (role.roleKey != null) 'role_key': role.roleKey,
        'label': role.label,
        'is_system_role': role.isSystemRole,
        'role': role.toJson(),
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
