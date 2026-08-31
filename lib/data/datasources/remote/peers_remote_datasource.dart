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

  static bool _isValidId(String? str) {
    if (str == null || str.trim().isEmpty) return false;
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(str.trim());
  }

  /// Fetches peers list with pagination (sorting is handled client-side).
  Future<ApiResponse<List<PeerModel>>> getPeers({
    String? circleId,
    String? status,
    String? search,
    int? page,
    int? perPage,
  }) async {
    final params = <String, String>{};
    if (_isValidId(circleId)) params['circle_id'] = circleId!.trim();
    if (status != null && status != 'All') params['status'] = status;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (page != null) params['page'] = page.toString();
    if (perPage != null) params['per_page'] = perPage.toString();

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
    if (!_isValidId(id)) {
      return const ApiResponse<PeerModel>(
        success: false,
        message: 'Invalid peer identifier',
      );
    }
    return _apiClient.get<PeerModel>(
      ApiEndpoints.peerDetails(id.trim()),
      fromJsonT: (json) => PeerModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetches full peer profile details model including metrics, milestones, bio, contact and meetings.
  Future<ApiResponse<PeerProfileDetailModel>> getPeerProfileDetail(String id) async {
    if (!_isValidId(id)) {
      return const ApiResponse<PeerProfileDetailModel>(
        success: false,
        message: 'Invalid peer identifier',
      );
    }
    return _apiClient.get<PeerProfileDetailModel>(
      ApiEndpoints.peerDetails(id.trim()),
      fromJsonT: (json) {
        if (json is Map<String, dynamic>) {
          return PeerProfileDetailModel.fromJson(json);
        } else if (json is Map) {
          return PeerProfileDetailModel.fromJson(Map<String, dynamic>.from(json));
        }
        return const PeerProfileDetailModel();
      },
    );
  }

  /// Fetches celebrations for the active circle.
  Future<ApiResponse<CelebrationsResponse>> getCelebrations({String? circleId}) async {
    final params = <String, String>{};
    if (_isValidId(circleId)) params['circle_id'] = circleId!.trim();

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
    if (!_isValidId(peerId)) {
      return const ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Invalid peer identifier',
      );
    }
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.peerSendWish(peerId.trim()),
      body: {
        'type': type,
        'message': message ?? 'Wishing you the very best!',
      },
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Fetches peer meetings history.
  Future<ApiResponse<List<PeerMeetingModel>>> getPeerMeetings(String peerId) async {
    if (!_isValidId(peerId)) {
      return const ApiResponse<List<PeerMeetingModel>>(
        success: true,
        data: [],
        message: 'No meetings found',
      );
    }
    return _apiClient.get<List<PeerMeetingModel>>(
      ApiEndpoints.peerMeetings(peerId.trim()),
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
    if (!_isValidId(peerId)) {
      return const ApiResponse<List<PeerActivityModel>>(
        success: true,
        data: [],
        message: 'No activities found',
      );
    }
    return _apiClient.get<List<PeerActivityModel>>(
      ApiEndpoints.peerActivities(peerId.trim()),
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
