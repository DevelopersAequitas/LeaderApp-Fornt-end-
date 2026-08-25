import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../features/peer_profile/model/peer_profile_model.dart';
import '../../../features/peers/model/celebration_model.dart';
import '../../../features/peers/model/peer_model.dart';

class CelebrationsResponse {
  final List<CelebrationModel> birthdays;
  final List<CelebrationModel> anniversaries;

  const CelebrationsResponse({
    required this.birthdays,
    required this.anniversaries,
  });

  factory CelebrationsResponse.fromJson(Map<String, dynamic> json) {
    final bdays = <CelebrationModel>[];
    if (json['birthdays'] is List) {
      for (final item in json['birthdays']) {
        bdays.add(CelebrationModel.fromJson(item as Map<String, dynamic>, 'birthday'));
      }
    }

    final annivs = <CelebrationModel>[];
    if (json['anniversaries'] is List) {
      for (final item in json['anniversaries']) {
        annivs.add(CelebrationModel.fromJson(item as Map<String, dynamic>, 'anniversary'));
      }
    }

    return CelebrationsResponse(birthdays: bdays, anniversaries: annivs);
  }
}

class PeersRemoteDataSource {
  final ApiClient _apiClient;

  PeersRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  static bool _isValidUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(str.trim());
  }

  /// Fetches filtered peers list.
  Future<ApiResponse<List<PeerModel>>> getPeers({
    String? circleId,
    String? status,
    String? sort,
    String? search,
  }) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;
    if (status != null && status != 'All') params['status'] = status;
    if (sort != null) params['sort'] = sort;
    if (search != null && search.isNotEmpty) params['search'] = search;

    return _apiClient.get<List<PeerModel>>(
      ApiEndpoints.peers,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => PeerModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <PeerModel>[];
      },
    );
  }

  /// Fetches single peer profile details.
  Future<ApiResponse<PeerModel>> getPeerDetails(String id) async {
    if (!_isValidUuid(id)) {
      return ApiResponse<PeerModel>(
        success: false,
        message: 'Invalid peer identifier',
      );
    }
    return _apiClient.get<PeerModel>(
      ApiEndpoints.peerDetails(id),
      fromJsonT: (json) => PeerModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetches celebrations for the active circle.
  Future<ApiResponse<CelebrationsResponse>> getCelebrations({String? circleId}) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;

    return _apiClient.get<CelebrationsResponse>(
      ApiEndpoints.peerCelebrations,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) => CelebrationsResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends birthday/anniversary wish to peer.
  Future<ApiResponse<Map<String, dynamic>>> sendWish(
    String peerId, {
    required String type,
    String? message,
  }) async {
    if (!_isValidUuid(peerId)) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Invalid peer identifier',
      );
    }
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.peerSendWish(peerId),
      body: {
        'type': type,
        'message': message ?? 'Wishing you the very best!',
      },
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Fetches peer meetings history.
  Future<ApiResponse<List<PeerMeetingModel>>> getPeerMeetings(String peerId) async {
    if (!_isValidUuid(peerId)) {
      return const ApiResponse<List<PeerMeetingModel>>(
        success: true,
        data: [],
        message: 'No meetings found',
      );
    }
    return _apiClient.get<List<PeerMeetingModel>>(
      ApiEndpoints.peerMeetings(peerId),
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => PeerMeetingModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <PeerMeetingModel>[];
      },
    );
  }

  /// Fetches peer activity audit trail.
  Future<ApiResponse<List<PeerActivityModel>>> getPeerActivities(
    String peerId, {
    int page = 1,
    int limit = 20,
  }) async {
    if (!_isValidUuid(peerId)) {
      return const ApiResponse<List<PeerActivityModel>>(
        success: true,
        data: [],
        message: 'No activities found',
      );
    }
    return _apiClient.get<List<PeerActivityModel>>(
      ApiEndpoints.peerActivities(peerId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => PeerActivityModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <PeerActivityModel>[];
      },
    );
  }

  /// Logs a 1-on-1 P2P Meeting.
  Future<ApiResponse<Map<String, dynamic>>> logP2PMeeting({
    required String peerId,
    required String meetingDate,
    required String meetingPlace,
    String? remarks,
  }) async {
    final body = <String, dynamic>{
      'peer_id': peerId,
      'meeting_date': meetingDate,
      'meeting_place': meetingPlace,
    };
    if (remarks != null && remarks.isNotEmpty) {
      body['remarks'] = remarks;
    }

    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.logP2pMeeting,
      body: body,
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }
}
