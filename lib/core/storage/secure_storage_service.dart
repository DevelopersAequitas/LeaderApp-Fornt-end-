import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../helpers/session_manager.dart';
import '../models/leader_permissions.dart';

/// Service managing hardware-encrypted device storage for sensitive auth tokens and credentials.
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  final FlutterSecureStorage _storage;

  SecureStorageService._internal()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  static const String _keyAuthToken = 'auth_bearer_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUserSession = 'user_session_profile';
  static const String _keyPermissions = 'user_permissions_matrix';

  /// Saves the complete session securely.
  Future<void> saveAuthSession({
    required String token,
    String? refreshToken,
    required UserSession session,
    LeaderPermissions? permissions,
  }) async {
    await _storage.write(key: _keyAuthToken, value: token);
    if (refreshToken != null) {
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
    }
    
    final sessionMap = {
      'id': session.id,
      'name': session.name,
      'email': session.email,
      'phone': session.phone,
      'role': session.role.name,
      'regional_scope': session.regionalScope,
      'managed_circles': session.managedCircles,
      'member_since': session.memberSince,
      'capabilities_count': session.capabilitiesCount,
      'custom_role_label': session.customRoleLabel,
      'avatar_url': session.avatarUrl,
    };
    await _storage.write(key: _keyUserSession, value: jsonEncode(sessionMap));

    if (permissions != null) {
      await _storage.write(
        key: _keyPermissions,
        value: jsonEncode(permissions.toJson()),
      );
    }
  }

  /// Retrieves the saved authentication Bearer token.
  Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  /// Retrieves the saved refresh token.
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// Retrieves and reconstructs the persisted UserSession.
  Future<UserSession?> getUserSession() async {
    final raw = await _storage.read(key: _keyUserSession);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return UserSession.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Retrieves and reconstructs the persisted LeaderPermissions.
  Future<LeaderPermissions?> getPermissions() async {
    final raw = await _storage.read(key: _keyPermissions);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return LeaderPermissions.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Deletes all persisted session and auth data upon user logout.
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
