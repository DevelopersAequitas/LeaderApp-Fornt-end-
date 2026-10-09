import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../features/member_activities/model/member_activity_model.dart';
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

  factory CelebrationsResponse.fromJson(Map<dynamic, dynamic> json) {
    final bdays = <CelebrationModel>[];
    if (json['birthdays'] is List) {
      for (final item in json['birthdays']) {
        if (item is Map) {
          bdays.add(CelebrationModel.fromJson(item, 'birthday'));
        }
      }
    }

    final annivs = <CelebrationModel>[];
    if (json['anniversaries'] is List) {
      for (final item in json['anniversaries']) {
        if (item is Map) {
          annivs.add(CelebrationModel.fromJson(item, 'anniversary'));
        }
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

  /// Fetches peers introduced by a specific member.
  Future<ApiResponse<List<PeerModel>>> getIntroducedPeers(String memberId) async {
    final endpoint = ApiEndpoints.memberSpecificActivity(memberId.trim(), 'introduced-peers');
    return _apiClient.get<List<PeerModel>>(
      endpoint,
      fromJsonT: (json) {
        List<PeerModel> parseItems(dynamic list) {
          if (list is List) {
            return list
                .map((item) {
                  if (item is Map<String, dynamic>) {
                    return PeerModel.fromJson(item);
                  } else if (item is Map) {
                    return PeerModel.fromJson(Map<String, dynamic>.from(item));
                  }
                  return null;
                })
                .whereType<PeerModel>()
                .toList();
          }
          return <PeerModel>[];
        }

        if (json is List) {
          return parseItems(json);
        }
        if (json is Map) {
          if (json['introduced_peers'] is List) {
            return parseItems(json['introduced_peers']);
          }
          if (json['data'] is List) {
            return parseItems(json['data']);
          }
          if (json['peers'] is List) {
            return parseItems(json['peers']);
          }
          if (json['data'] is Map) {
            final dataMap = json['data'] as Map;
            if (dataMap['introduced_peers'] is List) {
              return parseItems(dataMap['introduced_peers']);
            }
            if (dataMap['peers'] is List) {
              return parseItems(dataMap['peers']);
            }
            if (dataMap['data'] is List) {
              return parseItems(dataMap['data']);
            }
          }
        }
        return <PeerModel>[];
      },
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
      fromJsonT: (json) => CelebrationsResponse.fromJson(json is Map ? json : const {}),
    );
  }

  /// Sends birthday/anniversary wish to peer.
  Future<ApiResponse<Map<String, dynamic>>> sendWish(
    String peerId, {
    required String type,
    String? message,
  }) async {
    final cleanId = peerId.trim().replaceAll('cel_b_', '').replaceAll('cel_a_', '');
    if (!_isValidId(cleanId)) {
      return const ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Invalid peer identifier',
      );
    }
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.peerSendWish(cleanId),
      body: {
        'type': type,
        'message': message ?? 'Wishing you the very best!',
      },
      fromJsonT: (json) {
        if (json is Map<String, dynamic>) return json;
        if (json is Map) return Map<String, dynamic>.from(json);
        return <String, dynamic>{'success': true};
      },
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

  /// Fetches member activities filtered by type.
  Future<ApiResponse<List<MemberActivityModel>>> getMemberActivities(
    String memberId, {
    String? type,
    String? endpointPath,
    int page = 1,
    int limit = 20,
  }) async {
    final endpoint = endpointPath != null && endpointPath.isNotEmpty
        ? ApiEndpoints.memberSpecificActivity(memberId.trim(), endpointPath)
        : ApiEndpoints.memberActivities(memberId.trim());

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
      queryParams['activity_type'] = type;
    }

    return _apiClient.get<List<MemberActivityModel>>(
      endpoint,
      queryParameters: queryParams,
      fromJsonT: (json) => MemberActivityModel.parseList(json),
    );
  }

  /// 1.2 Record New Business Deal (POST /leader/business-deals)
  Future<ApiResponse<Map<String, dynamic>>> recordBusinessDeal({
    required String toPeerId,
    required double amount,
    String? businessType,
    String? comment,
    String? dealDate,
    String? referralId,
  }) async {
    final body = <String, dynamic>{
      'to_peer_id': toPeerId,
      'amount': amount,
    };
    if (businessType != null) body['business_type'] = businessType;
    if (comment != null) body['comment'] = comment;
    if (dealDate != null) body['deal_date'] = dealDate;
    if (referralId != null) body['referral_id'] = referralId;

    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.leaderBusinessDeals,
      body: body,
      fromJsonT: (json) => json is Map<String, dynamic> ? json : {'success': true},
    );
  }

  /// 1.3 Get Member Business Deals (GET /leader/members/{member_id}/business-deals)
  Future<ApiResponse<List<Map<String, dynamic>>>> getMemberBusinessDeals(
    String memberId, {
    String? activityType,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (activityType != null) params['activity_type'] = activityType;

    return _apiClient.get<List<Map<String, dynamic>>>(
      ApiEndpoints.memberBusinessDeals(memberId),
      queryParameters: params,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        }
        if (json is Map) {
          final list = json['data'] ?? json['items'] ?? json['deals'];
          if (list is List) {
            return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
          }
        }
        return [];
      },
    );
  }

  /// 2.2 Submit New Referral (POST /leader/referrals)
  Future<ApiResponse<Map<String, dynamic>>> submitReferral({
    required String toPeerId,
    required String prospectName,
    String? prospectPhone,
    String? prospectEmail,
    String? prospectCompany,
    String? estimatedDealValue,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'to_peer_id': toPeerId,
      'prospect_name': prospectName,
    };
    if (prospectPhone != null) body['prospect_phone'] = prospectPhone;
    if (prospectEmail != null) body['prospect_email'] = prospectEmail;
    if (prospectCompany != null) body['prospect_company'] = prospectCompany;
    if (estimatedDealValue != null) body['estimated_deal_value'] = estimatedDealValue;
    if (notes != null) body['notes'] = notes;

    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.leaderReferrals,
      body: body,
      fromJsonT: (json) => json is Map<String, dynamic> ? json : {'success': true},
    );
  }

  /// 2.3 Get Member Referrals (GET /leader/members/{member_id}/referrals)
  Future<ApiResponse<List<Map<String, dynamic>>>> getMemberReferrals(
    String memberId, {
    String? activityType,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (activityType != null) params['activity_type'] = activityType;

    return _apiClient.get<List<Map<String, dynamic>>>(
      ApiEndpoints.memberReferrals(memberId),
      queryParameters: params,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        }
        return [];
      },
    );
  }

  /// 2.4 Get Member Posts (GET /leader/members/{member_id}/posts)
  Future<ApiResponse<List<Map<String, dynamic>>>> getMemberPosts(
    String memberId, {
    int page = 1,
    int limit = 20,
  }) async {
    return _apiClient.get<List<Map<String, dynamic>>>(
      ApiEndpoints.memberPosts(memberId),
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        }
        if (json is Map) {
          final list = json['data'] ?? json['posts'] ?? json['items'];
          if (list is List) {
            return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
          }
        }
        return [];
      },
    );
  }

  /// 3.1 Get Platform Leaderboard by Coins (GET /leader/peers-by-coins)
  Future<ApiResponse<Map<String, dynamic>>> getPeersByCoins({int limit = 20}) async {
    return _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.leaderPeersByCoins,
      queryParameters: {'limit': limit.toString()},
      fromJsonT: (json) => json is Map<String, dynamic> ? json : {},
    );
  }

  /// 3.2 Get Member Coins Activity History (GET /leader/members/{member_id}/activities?type=coins)
  Future<ApiResponse<List<Map<String, dynamic>>>> getMemberCoins(
    String memberId, {
    int page = 1,
    int limit = 20,
  }) async {
    return _apiClient.get<List<Map<String, dynamic>>>(
      ApiEndpoints.memberCoins(memberId),
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        'type': 'coins',
        'activity_type': 'coins',
      },
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        }
        if (json is Map) {
          final list = json['data'] ?? json['activities'] ?? json['items'];
          if (list is List) {
            return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
          }
        }
        return [];
      },
    );
  }

  /// 5.2 Submit New Testimonial (POST /leader/testimonials)
  Future<ApiResponse<Map<String, dynamic>>> submitTestimonial({
    required String toPeerId,
    required String content,
    int rating = 5,
    String? referralId,
  }) async {
    final body = <String, dynamic>{
      'to_peer_id': toPeerId,
      'content': content,
      'rating': rating,
    };
    if (referralId != null) body['referral_id'] = referralId;

    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.leaderTestimonials,
      body: body,
      fromJsonT: (json) => json is Map<String, dynamic> ? json : {'success': true},
    );
  }

  /// 5.3 Get Member Testimonials (GET /leader/members/{member_id}/testimonials)
  Future<ApiResponse<List<PeerTestimonialModel>>> getMemberTestimonials(
    String memberId, {
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null) params['search'] = search;

    return _apiClient.get<List<PeerTestimonialModel>>(
      ApiEndpoints.memberTestimonials(memberId),
      queryParameters: params,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => PeerTestimonialModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <PeerTestimonialModel>[];
      },
    );
  }
}
