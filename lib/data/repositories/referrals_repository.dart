import '../../core/network/api_response.dart';
import '../../core/storage/hive_cache_service.dart';
import '../../features/peers_by_coins/model/coin_balance_model.dart';
import '../../features/referrals/model/referral_model.dart';
import '../../features/testimonials/model/testimonial_model.dart';
import '../datasources/remote/referrals_remote_datasource.dart';

abstract class ReferralsRepository {
  Future<ApiResponse<List<ReferralModel>>> getReferrals({String? circleId, String? status});
  Future<ApiResponse<List<TestimonialModel>>> getTestimonials({String? circleId});
  Future<ApiResponse<List<CoinBalanceModel>>> getPeersByCoins({String? circleId});
  Future<ApiResponse<Map<String, dynamic>>> createReferralLead({
    required String toPeerId,
    required String prospectName,
    String? prospectCompany,
    String? prospectPhone,
    String? prospectEmail,
    String? estimatedDealValue,
    String? notes,
  });
}

class ReferralsRepositoryImpl implements ReferralsRepository {
  final ReferralsRemoteDataSource _remoteDataSource;
  final HiveCacheService _cacheService;

  ReferralsRepositoryImpl({
    ReferralsRemoteDataSource? remoteDataSource,
    HiveCacheService? cacheService,
  })  : _remoteDataSource = remoteDataSource ?? ReferralsRemoteDataSource(),
        _cacheService = cacheService ?? HiveCacheService();

  @override
  Future<ApiResponse<List<ReferralModel>>> getReferrals({String? circleId, String? status}) async {
    final cacheKey = 'referrals_${circleId ?? "all"}_${status ?? "all"}';
    try {
      final response = await _remoteDataSource.getReferrals(circleId: circleId, status: status);
      if (response.success && response.data != null) {
        final listJson = response.data!.map((x) => x.toJson()).toList();
        await _cacheService.put(cacheKey, listJson);
      }
      return response;
    } catch (e) {
      final cachedList = _cacheService.get(cacheKey);
      if (cachedList is List) {
        final cachedData = cachedList
            .map((item) => ReferralModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        return ApiResponse<List<ReferralModel>>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<List<TestimonialModel>>> getTestimonials({String? circleId}) async {
    final cacheKey = 'testimonials_${circleId ?? "all"}';
    try {
      final response = await _remoteDataSource.getTestimonials(circleId: circleId);
      if (response.success && response.data != null) {
        final listJson = response.data!.map((x) => x.toJson()).toList();
        await _cacheService.put(cacheKey, listJson);
      }
      return response;
    } catch (e) {
      final cachedList = _cacheService.get(cacheKey);
      if (cachedList is List) {
        final cachedData = cachedList
            .map((item) => TestimonialModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        return ApiResponse<List<TestimonialModel>>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<List<CoinBalanceModel>>> getPeersByCoins({String? circleId}) async {
    final cacheKey = 'peers_by_coins_${circleId ?? "all"}';
    try {
      final response = await _remoteDataSource.getPeersByCoins(circleId: circleId);
      if (response.success && response.data != null) {
        final listJson = response.data!.map((x) => x.toJson()).toList();
        await _cacheService.put(cacheKey, listJson);
      }
      return response;
    } catch (e) {
      final cachedList = _cacheService.get(cacheKey);
      if (cachedList is List) {
        final cachedData = cachedList
            .map((item) => CoinBalanceModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        return ApiResponse<List<CoinBalanceModel>>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> createReferralLead({
    required String toPeerId,
    required String prospectName,
    String? prospectCompany,
    String? prospectPhone,
    String? prospectEmail,
    String? estimatedDealValue,
    String? notes,
  }) async {
    return _remoteDataSource.createReferralLead(
      toPeerId: toPeerId,
      prospectName: prospectName,
      prospectCompany: prospectCompany,
      prospectPhone: prospectPhone,
      prospectEmail: prospectEmail,
      estimatedDealValue: estimatedDealValue,
      notes: notes,
    );
  }
}
