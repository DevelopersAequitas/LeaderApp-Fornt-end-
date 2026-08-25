import '../../core/helpers/session_manager.dart';
import '../../core/network/api_response.dart';
import '../datasources/remote/auth_remote_datasource.dart';

abstract class AuthRepository {
  Future<ApiResponse<Map<String, dynamic>>> sendOtp(String emailOrPhone);
  Future<ApiResponse<AuthVerifyResult>> verifyOtp(String emailOrPhone, String otp);
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? companyName,
  });
  Future<ApiResponse<Map<String, dynamic>>> uploadAvatar(String filePath);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource();

  @override
  Future<ApiResponse<Map<String, dynamic>>> sendOtp(String emailOrPhone) async {
    return _remoteDataSource.sendOtp(emailOrPhone);
  }

  @override
  Future<ApiResponse<AuthVerifyResult>> verifyOtp(String emailOrPhone, String otp) async {
    final response = await _remoteDataSource.verifyOtp(emailOrPhone, otp);
    if (response.success && response.data != null) {
      final authData = response.data!;
      await SessionManager().setAuthSession(
        token: authData.authToken,
        refreshToken: authData.refreshToken,
        session: authData.user,
        permissions: authData.permissions,
      );
    }
    return response;
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? companyName,
  }) async {
    final response = await _remoteDataSource.updateProfile(
      name: name,
      phone: phone,
      bio: bio,
      companyName: companyName,
    );
    if (response.success && response.data != null) {
      // Refresh local user session with updated name/phone/bio if present
      final current = SessionManager().currentSession;
      final updatedSession = UserSession(
        id: current.id,
        name: response.data!['name']?.toString() ?? current.name,
        email: current.email,
        phone: response.data!['phone']?.toString() ?? current.phone,
        role: current.role,
        regionalScope: current.regionalScope,
        managedCircles: current.managedCircles,
        memberSince: current.memberSince,
        capabilitiesCount: current.capabilitiesCount,
        customRoleLabel: current.customRoleLabel,
        avatarUrl: response.data!['avatar_url']?.toString() ?? current.avatarUrl,
      );
      await SessionManager().setAuthSession(
        token: SessionManager().authToken ?? '',
        refreshToken: SessionManager().refreshToken,
        session: updatedSession,
        permissions: SessionManager().permissions,
      );
    }
    return response;
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> uploadAvatar(String filePath) async {
    final response = await _remoteDataSource.uploadAvatar(filePath);
    if (response.success && response.data != null && response.data!['avatar_url'] != null) {
      final current = SessionManager().currentSession;
      final updatedSession = UserSession(
        id: current.id,
        name: current.name,
        email: current.email,
        phone: current.phone,
        role: current.role,
        regionalScope: current.regionalScope,
        managedCircles: current.managedCircles,
        memberSince: current.memberSince,
        capabilitiesCount: current.capabilitiesCount,
        customRoleLabel: current.customRoleLabel,
        avatarUrl: response.data!['avatar_url'].toString(),
      );
      await SessionManager().setAuthSession(
        token: SessionManager().authToken ?? '',
        refreshToken: SessionManager().refreshToken,
        session: updatedSession,
        permissions: SessionManager().permissions,
      );
    }
    return response;
  }
}
