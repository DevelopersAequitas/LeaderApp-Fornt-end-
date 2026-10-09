import '../../core/network/api_response.dart';
import '../../core/storage/hive_cache_service.dart';
import '../../features/member_activities/model/member_activity_model.dart';
import '../../features/peer_profile/model/peer_profile_model.dart';
import '../../features/peers/model/celebration_model.dart';
import '../../features/peers/model/peer_model.dart';
import '../datasources/remote/peers_remote_datasource.dart';

abstract class PeersRepository {
  Future<ApiResponse<List<PeerModel>>> getPeers({
    String? circleId,
    String? status,
    String? search,
    int? page,
    int? perPage,
  });
  Future<ApiResponse<PeerModel>> getPeerDetails(String id);
  Future<ApiResponse<PeerProfileDetailModel>> getPeerProfileDetail(String id);
  Future<ApiResponse<CelebrationsResponse>> getCelebrations({String? circleId});
  Future<ApiResponse<Map<String, dynamic>>> sendWish(String peerId, {required String type, String? message});
  Future<ApiResponse<List<PeerMeetingModel>>> getPeerMeetings(String peerId);
  Future<ApiResponse<List<PeerActivityModel>>> getPeerActivities(String peerId, {int page = 1, int limit = 20});
  Future<ApiResponse<List<MemberActivityModel>>> getMemberActivities(
    String memberId, {
    String? type,
    String? endpointPath,
    int page = 1,
    int limit = 20,
  });
  Future<ApiResponse<Map<String, dynamic>>> logP2PMeeting({
    required String peerId,
    required String meetingDate,
    required String meetingPlace,
    String? remarks,
  });
  Future<ApiResponse<Map<String, dynamic>>> recordBusinessDeal({
    required String toPeerId,
    required double amount,
    String? businessType,
    String? comment,
    String? dealDate,
    String? referralId,
  });
  Future<ApiResponse<List<Map<String, dynamic>>>> getMemberBusinessDeals(
    String memberId, {
    String? activityType,
    int page = 1,
    int limit = 20,
  });
  Future<ApiResponse<Map<String, dynamic>>> submitReferral({
    required String toPeerId,
    required String prospectName,
    String? prospectPhone,
    String? prospectEmail,
    String? prospectCompany,
    String? estimatedDealValue,
    String? notes,
  });
  Future<ApiResponse<List<Map<String, dynamic>>>> getMemberReferrals(
    String memberId, {
    String? activityType,
    int page = 1,
    int limit = 20,
  });
  Future<ApiResponse<Map<String, dynamic>>> getPeersByCoins({int limit = 20});
  Future<ApiResponse<List<Map<String, dynamic>>>> getMemberCoins(
    String memberId, {
    int page = 1,
    int limit = 20,
  });
  Future<ApiResponse<Map<String, dynamic>>> submitTestimonial({
    required String toPeerId,
    required String content,
    int rating = 5,
    String? referralId,
  });
  Future<ApiResponse<List<PeerTestimonialModel>>> getMemberTestimonials(
    String memberId, {
    int page = 1,
    int limit = 20,
    String? search,
  });
  Future<ApiResponse<List<PeerModel>>> getIntroducedPeers(String memberId);
}

class PeersRepositoryImpl implements PeersRepository {
  final PeersRemoteDataSource _remoteDataSource;
  final HiveCacheService _cacheService;

  PeersRepositoryImpl({
    PeersRemoteDataSource? remoteDataSource,
    HiveCacheService? cacheService,
  })  : _remoteDataSource = remoteDataSource ?? PeersRemoteDataSource(),
        _cacheService = cacheService ?? HiveCacheService();

  @override
  Future<ApiResponse<List<PeerModel>>> getPeers({
    String? circleId,
    String? status,
    String? search,
    int? page,
    int? perPage,
  }) async {
    final cacheKey = 'peers_list_${circleId ?? "all"}_${status ?? "all"}';
    try {
      final response = await _remoteDataSource.getPeers(
        circleId: circleId,
        status: status,
        search: search,
        page: page,
        perPage: perPage,
      );
      if (response.success &&
          response.data != null &&
          (search == null || search.isEmpty) &&
          (page == null || page == 1)) {
        final listJson = response.data!.map((x) => x.toJson()).toList();
        await _cacheService.put(cacheKey, listJson);
      }
      return response;
    } catch (e) {
      if (search == null || search.isEmpty) {
        final cachedList = _cacheService.get(cacheKey);
        if (cachedList is List) {
          final cachedData = cachedList
              .map((item) => PeerModel.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
          return ApiResponse<List<PeerModel>>(
            success: true,
            data: cachedData,
            message: 'Loaded from offline cache',
          );
        }
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<PeerModel>> getPeerDetails(String id) async {
    final cacheKey = 'peer_detail_$id';
    try {
      final response = await _remoteDataSource.getPeerDetails(id);
      if (response.success && response.data != null) {
        await _cacheService.put(cacheKey, response.data!.toJson());
      }
      return response;
    } catch (e) {
      final cachedJson = _cacheService.get(cacheKey);
      if (cachedJson is Map<String, dynamic>) {
        final cachedData = PeerModel.fromJson(cachedJson);
        return ApiResponse<PeerModel>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<PeerProfileDetailModel>> getPeerProfileDetail(String id) async {
    final cacheKey = 'peer_profile_detail_$id';
    try {
      final response = await _remoteDataSource.getPeerProfileDetail(id);
      if (response.success && response.data != null) {
        await _cacheService.put(cacheKey, response.data!.toJson());
      }
      return response;
    } catch (e) {
      final cachedJson = _cacheService.get(cacheKey);
      if (cachedJson is Map<String, dynamic>) {
        final cachedData = PeerProfileDetailModel.fromJson(cachedJson);
        return ApiResponse<PeerProfileDetailModel>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<CelebrationsResponse>> getCelebrations({String? circleId}) async {
    final cacheKey = 'celebrations_${circleId ?? "all"}';
    try {
      final response = await _remoteDataSource.getCelebrations(circleId: circleId);
      if (response.success && response.data != null) {
        final birthdaysJson = response.data!.birthdays.map((x) => x.toJson()).toList();
        final anniversariesJson = response.data!.anniversaries.map((x) => x.toJson()).toList();
        await _cacheService.put(cacheKey, {
          'birthdays': birthdaysJson,
          'anniversaries': anniversariesJson,
        });
      }
      return response;
    } catch (e) {
      final cachedData = _cacheService.get(cacheKey);
      if (cachedData is Map<String, dynamic>) {
        final birthdays = (cachedData['birthdays'] as List? ?? [])
            .map((item) => CelebrationModel.fromJson(Map<String, dynamic>.from(item as Map), 'birthday'))
            .toList();
        final anniversaries = (cachedData['anniversaries'] as List? ?? [])
            .map((item) => CelebrationModel.fromJson(Map<String, dynamic>.from(item as Map), 'anniversary'))
            .toList();
        return ApiResponse<CelebrationsResponse>(
          success: true,
          data: CelebrationsResponse(birthdays: birthdays, anniversaries: anniversaries),
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> sendWish(
    String peerId, {
    required String type,
    String? message,
  }) async {
    return _remoteDataSource.sendWish(peerId, type: type, message: message);
  }

  @override
  Future<ApiResponse<List<PeerMeetingModel>>> getPeerMeetings(String peerId) async {
    final cacheKey = 'peer_meetings_$peerId';
    try {
      final response = await _remoteDataSource.getPeerMeetings(peerId);
      if (response.success && response.data != null) {
        final listJson = response.data!.map((x) => x.toJson()).toList();
        await _cacheService.put(cacheKey, listJson);
      }
      return response;
    } catch (e) {
      final cachedList = _cacheService.get(cacheKey);
      if (cachedList is List) {
        final cachedData = cachedList
            .map((item) => PeerMeetingModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        return ApiResponse<List<PeerMeetingModel>>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<List<PeerActivityModel>>> getPeerActivities(
    String peerId, {
    int page = 1,
    int limit = 20,
  }) async {
    final cacheKey = 'peer_activities_${peerId}_p$page';
    try {
      final response = await _remoteDataSource.getPeerActivities(peerId, page: page, limit: limit);
      if (response.success && response.data != null) {
        final listJson = response.data!.map((x) => x.toJson()).toList();
        await _cacheService.put(cacheKey, listJson);
      }
      return response;
    } catch (e) {
      final cachedList = _cacheService.get(cacheKey);
      if (cachedList is List) {
        final cachedData = cachedList
            .map((item) => PeerActivityModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        return ApiResponse<List<PeerActivityModel>>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<List<MemberActivityModel>>> getMemberActivities(
    String memberId, {
    String? type,
    String? endpointPath,
    int page = 1,
    int limit = 20,
  }) async {
    return _remoteDataSource.getMemberActivities(
      memberId,
      type: type,
      endpointPath: endpointPath,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> logP2PMeeting({
    required String peerId,
    required String meetingDate,
    required String meetingPlace,
    String? remarks,
  }) async {
    return _remoteDataSource.logP2PMeeting(
      peerId: peerId,
      meetingDate: meetingDate,
      meetingPlace: meetingPlace,
      remarks: remarks,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> recordBusinessDeal({
    required String toPeerId,
    required double amount,
    String? businessType,
    String? comment,
    String? dealDate,
    String? referralId,
  }) async {
    return _remoteDataSource.recordBusinessDeal(
      toPeerId: toPeerId,
      amount: amount,
      businessType: businessType,
      comment: comment,
      dealDate: dealDate,
      referralId: referralId,
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getMemberBusinessDeals(
    String memberId, {
    String? activityType,
    int page = 1,
    int limit = 20,
  }) async {
    return _remoteDataSource.getMemberBusinessDeals(
      memberId,
      activityType: activityType,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> submitReferral({
    required String toPeerId,
    required String prospectName,
    String? prospectPhone,
    String? prospectEmail,
    String? prospectCompany,
    String? estimatedDealValue,
    String? notes,
  }) async {
    return _remoteDataSource.submitReferral(
      toPeerId: toPeerId,
      prospectName: prospectName,
      prospectPhone: prospectPhone,
      prospectEmail: prospectEmail,
      prospectCompany: prospectCompany,
      estimatedDealValue: estimatedDealValue,
      notes: notes,
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getMemberReferrals(
    String memberId, {
    String? activityType,
    int page = 1,
    int limit = 20,
  }) async {
    return _remoteDataSource.getMemberReferrals(
      memberId,
      activityType: activityType,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getPeersByCoins({int limit = 20}) async {
    return _remoteDataSource.getPeersByCoins(limit: limit);
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getMemberCoins(
    String memberId, {
    int page = 1,
    int limit = 20,
  }) async {
    return _remoteDataSource.getMemberCoins(
      memberId,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> submitTestimonial({
    required String toPeerId,
    required String content,
    int rating = 5,
    String? referralId,
  }) async {
    return _remoteDataSource.submitTestimonial(
      toPeerId: toPeerId,
      content: content,
      rating: rating,
      referralId: referralId,
    );
  }

  @override
  Future<ApiResponse<List<PeerTestimonialModel>>> getMemberTestimonials(
    String memberId, {
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    return _remoteDataSource.getMemberTestimonials(
      memberId,
      page: page,
      limit: limit,
      search: search,
    );
  }

  @override
  Future<ApiResponse<List<PeerModel>>> getIntroducedPeers(String memberId) async {
    return _remoteDataSource.getIntroducedPeers(memberId);
  }
}
