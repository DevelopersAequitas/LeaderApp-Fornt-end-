import '../../core/enums/user_role.dart';
import '../../core/helpers/session_manager.dart';
import '../../core/network/api_response.dart';
import '../../core/storage/hive_cache_service.dart';
import '../../features/finance/model/finance_model.dart';
import '../datasources/remote/finance_remote_datasource.dart';

abstract class FinanceRepository {
  Future<ApiResponse<FinanceMetricsModel>> getFinanceMetrics({String? circleId});
  Future<ApiResponse<List<FinanceTransactionModel>>> getTransactions({
    String? circleId,
    String? status,
  });
  Future<ApiResponse<Map<String, dynamic>>> updateCommissionRates(
    dynamic commissionRates,
  );
  Future<ApiResponse<Map<String, dynamic>>> recordOfflinePayment({
    required String peerId,
    required String circleId,
    required num amount,
    required String paymentMode,
    required String referenceNumber,
    required String paymentDate,
    required String type,
  });
}

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource _remoteDataSource;
  final HiveCacheService _cacheService;

  FinanceRepositoryImpl({
    FinanceRemoteDataSource? remoteDataSource,
    HiveCacheService? cacheService,
  })  : _remoteDataSource = remoteDataSource ?? FinanceRemoteDataSource(),
        _cacheService = cacheService ?? HiveCacheService();

  @override
  Future<ApiResponse<FinanceMetricsModel>> getFinanceMetrics({String? circleId}) async {
    final cacheKey = 'finance_metrics_${circleId ?? "all"}';
    try {
      final response = await _remoteDataSource.getFinanceMetrics(circleId: circleId);
      if (response.success && response.data != null) {
        final data = response.data!;
        await _cacheService.put(cacheKey, data.toJson());
        return ApiResponse<FinanceMetricsModel>(
          success: true,
          data: data,
          message: response.message,
        );
      }
      return response;
    } catch (e) {
      final cachedJson = _cacheService.get(cacheKey);
      if (cachedJson is Map<String, dynamic>) {
        final cachedData = FinanceMetricsModel.fromJson(cachedJson);
        return ApiResponse<FinanceMetricsModel>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<List<FinanceTransactionModel>>> getTransactions({
    String? circleId,
    String? status,
  }) async {
    final cacheKey = 'finance_transactions_${circleId ?? "all"}_${status ?? "all"}';
    try {
      final response = await _remoteDataSource.getTransactions(
        circleId: circleId,
        status: status,
      );
      if (response.success && response.data != null) {
        final rawList = response.data!;
        final listJson = rawList.map((x) => x.toJson()).toList();
        await _cacheService.put(cacheKey, listJson);
        return ApiResponse<List<FinanceTransactionModel>>(
          success: true,
          data: rawList,
          message: response.message,
        );
      }
      return response;
    } catch (e) {
      final cachedList = _cacheService.get(cacheKey);
      if (cachedList is List) {
        final cachedData = cachedList
            .map((item) => FinanceTransactionModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        return ApiResponse<List<FinanceTransactionModel>>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> updateCommissionRates(
    dynamic commissionRates,
  ) async {
    if (SessionManager().currentRole != UserRole.superAdmin) {
      return const ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Security Restriction: Only Super Admin can modify commission rates.',
      );
    }
    return _remoteDataSource.updateCommissionRates(commissionRates);
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> recordOfflinePayment({
    required String peerId,
    required String circleId,
    required num amount,
    required String paymentMode,
    required String referenceNumber,
    required String paymentDate,
    required String type,
  }) async {
    return _remoteDataSource.recordOfflinePayment(
      peerId: peerId,
      circleId: circleId,
      amount: amount,
      paymentMode: paymentMode,
      referenceNumber: referenceNumber,
      paymentDate: paymentDate,
      type: type,
    );
  }
}
