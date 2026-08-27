import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../features/role_management/model/role_permission_model.dart';

class RoleMatrixResponse {
  final List<AppCapability> capabilities;
  final List<RolePermissionModel> roles;

  const RoleMatrixResponse({
    required this.capabilities,
    required this.roles,
  });

  factory RoleMatrixResponse.fromJson(Map<String, dynamic> json) {
    final caps = <AppCapability>[];
    if (json['capabilities'] is List) {
      for (final item in json['capabilities']) {
        if (item is Map<String, dynamic>) {
          caps.add(AppCapability.fromJson(item));
        }
      }
    }

    final roleList = <RolePermissionModel>[];
    if (json['roles'] is List) {
      for (final item in json['roles']) {
        if (item is Map<String, dynamic>) {
          roleList.add(RolePermissionModel.fromJson(item));
        }
      }
    }

    return RoleMatrixResponse(capabilities: caps, roles: roleList);
  }

  Map<String, dynamic> toJson() => {
        'capabilities': capabilities.map((c) => c.toJson()).toList(),
        'roles': roles.map((r) => r.toJson()).toList(),
      };
}

class RoleMatrixRemoteDataSource {
  final ApiClient _apiClient;

  RoleMatrixRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetches capability definitions and role permission matrix from API.
  Future<ApiResponse<RoleMatrixResponse>> getRoleMatrix() async {
    return _apiClient.get<RoleMatrixResponse>(
      ApiEndpoints.roleMatrix,
      fromJsonT: (json) => RoleMatrixResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Updates capability assignments for a role.
  Future<ApiResponse<Map<String, dynamic>>> updateRoleCapabilities({
    required String roleId,
    required List<String> enabledCapabilities,
  }) async {
    return _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.roleMatrix,
      body: {
        'role_id': roleId,
        'enabled_capabilities': enabledCapabilities,
      },
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Creates a dynamic custom role.
  Future<ApiResponse<RolePermissionModel>> createRole({
    required String label,
    required List<String> enabledCapabilities,
  }) async {
    return _apiClient.post<RolePermissionModel>(
      ApiEndpoints.roles,
      body: {
        'label': label,
        'enabled_capabilities': enabledCapabilities,
      },
      fromJsonT: (json) => RolePermissionModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Renames a custom role.
  Future<ApiResponse<Map<String, dynamic>>> updateRole(String id, {required String label}) async {
    return _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.roleById(id),
      body: {'label': label},
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Deletes a custom role.
  Future<ApiResponse<Map<String, dynamic>>> deleteRole(String id) async {
    return _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.roleById(id),
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }
}
