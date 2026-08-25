import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/models/leader_permissions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/helpers/session_manager.dart';

/// Result DTO after verifying OTP.
class AuthVerifyResult {
  final String authToken;
  final String? refreshToken;
  final UserSession user;
  final LeaderPermissions permissions;

  const AuthVerifyResult({
    required this.authToken,
    this.refreshToken,
    required this.user,
    required this.permissions,
  });

  factory AuthVerifyResult.fromJson(Map<String, dynamic> json) {
    return AuthVerifyResult(
      authToken: json['auth_token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString(),
      user: UserSession.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      permissions: LeaderPermissions.fromJson(json['permissions'] as Map<String, dynamic>?),
    );
  }
}

/// Remote Data Source for User Authentication and Profile.
class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Requests OTP to be sent to user's email or phone.
  Future<ApiResponse<Map<String, dynamic>>> sendOtp(String emailOrPhone) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.sendOtp,
      body: {'email_or_phone': emailOrPhone.trim()},
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Verifies OTP and receives authentication token + session profile + permissions.
  Future<ApiResponse<AuthVerifyResult>> verifyOtp(String emailOrPhone, String otp) async {
    return _apiClient.post<AuthVerifyResult>(
      ApiEndpoints.verifyOtp,
      body: {
        'email_or_phone': emailOrPhone.trim(),
        'otp': otp.trim(),
      },
      fromJsonT: (json) => AuthVerifyResult.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Updates user profile details (name, phone, bio, company_name).
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? companyName,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (bio != null) body['bio'] = bio;
    if (companyName != null) body['company_name'] = companyName;

    return _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.updateProfile,
      body: body,
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Uploads avatar image file.
  Future<ApiResponse<Map<String, dynamic>>> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });

    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.uploadAvatar,
      body: formData,
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }
}
