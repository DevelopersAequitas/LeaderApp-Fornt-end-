import '../../core/network/api_response.dart';
import '../../core/storage/hive_cache_service.dart';
import '../../features/role_management/model/role_permission_model.dart';
import '../datasources/remote/role_matrix_remote_datasource.dart';

abstract class RoleMatrixRepository {
  Future<ApiResponse<RoleMatrixResponse>> getRoleMatrix();
  Future<ApiResponse<Map<String, dynamic>>> updateRoleCapabilities({
    required String roleId,
    required List<String> enabledCapabilities,
  });
  Future<ApiResponse<RolePermissionModel>> createRole({
    required String label,
    required List<String> enabledCapabilities,
  });
  Future<ApiResponse<Map<String, dynamic>>> updateRole(String id, {required String label});
  Future<ApiResponse<Map<String, dynamic>>> deleteRole(String id);
}

class RoleMatrixRepositoryImpl implements RoleMatrixRepository {
  final RoleMatrixRemoteDataSource _remoteDataSource;
  final HiveCacheService _cacheService;

  RoleMatrixRepositoryImpl({
    RoleMatrixRemoteDataSource? remoteDataSource,
    HiveCacheService? cacheService,
  })  : _remoteDataSource = remoteDataSource ?? RoleMatrixRemoteDataSource(),
        _cacheService = cacheService ?? HiveCacheService();

  @override
  Future<ApiResponse<RoleMatrixResponse>> getRoleMatrix() async {
    const cacheKey = 'role_matrix_all';
    try {
      final response = await _remoteDataSource.getRoleMatrix();
      if (response.success && response.data != null) {
        await _cacheService.put(cacheKey, response.data!.toJson());
      }
      return response;
    } catch (e) {
      final cachedJson = _cacheService.get(cacheKey);
      if (cachedJson is Map<String, dynamic>) {
        final cachedData = RoleMatrixResponse.fromJson(cachedJson);
        return ApiResponse<RoleMatrixResponse>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateRoleCapabilities({
    required String roleId,
    required List<String> enabledCapabilities,
  }) async {
    return _remoteDataSource.updateRoleCapabilities(
      roleId: roleId,
      enabledCapabilities: enabledCapabilities,
    );
  }

  @override
  Future<ApiResponse<RolePermissionModel>> createRole({
    required String label,
    required List<String> enabledCapabilities,
  }) async {
    return _remoteDataSource.createRole(
      label: label,
      enabledCapabilities: enabledCapabilities,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateRole(String id, {required String label}) async {
    return _remoteDataSource.updateRole(id, label: label);
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> deleteRole(String id) async {
    return _remoteDataSource.deleteRole(id);
  }
}
