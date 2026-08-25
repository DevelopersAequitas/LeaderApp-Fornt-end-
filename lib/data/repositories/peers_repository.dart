import '../../core/network/api_response.dart';
import '../../core/storage/hive_cache_service.dart';
import '../../features/peer_profile/model/peer_profile_model.dart';
import '../../features/peers/model/celebration_model.dart';
import '../../features/peers/model/peer_model.dart';
import '../datasources/remote/peers_remote_datasource.dart';

abstract class PeersRepository {
  Future<ApiResponse<List<PeerModel>>> getPeers({
    String? circleId,
    String? status,
    String? sort,
    String? search,
  });
  Future<ApiResponse<PeerModel>> getPeerDetails(String id);
  Future<ApiResponse<CelebrationsResponse>> getCelebrations({String? circleId});
  Future<ApiResponse<Map<String, dynamic>>> sendWish(String peerId, {required String type, String? message});
  Future<ApiResponse<List<PeerMeetingModel>>> getPeerMeetings(String peerId);
  Future<ApiResponse<List<PeerActivityModel>>> getPeerActivities(String peerId, {int page = 1, int limit = 20});
  Future<ApiResponse<Map<String, dynamic>>> logP2PMeeting({
    required String peerId,
    required String meetingDate,
    required String meetingPlace,
    String? remarks,
  });
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
    String? sort,
    String? search,
  }) async {
    final cacheKey = 'peers_list_${circleId ?? "all"}_${status ?? "all"}';
    try {
      final response = await _remoteDataSource.getPeers(
        circleId: circleId,
        status: status,
        sort: sort,
        search: search,
      );
      if (response.success && response.data != null) {
        final listJson = response.data!.map((x) => x.toJson()).toList();
        await _cacheService.put(cacheKey, listJson);
      }
      return response;
    } catch (e) {
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
}
