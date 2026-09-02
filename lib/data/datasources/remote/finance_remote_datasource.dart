import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../features/finance/model/finance_model.dart';

class FinanceRemoteDataSource {
  final ApiClient _apiClient;

  FinanceRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  static bool _isValidUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(str.trim());
  }

  /// Fetches financial metrics and fee collections.
  Future<ApiResponse<FinanceMetricsModel>> getFinanceMetrics({String? circleId}) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!.trim();

    return _apiClient.get<FinanceMetricsModel>(
      ApiEndpoints.financeMetrics,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) => FinanceMetricsModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetches recent transactions and dues ledger.
  Future<ApiResponse<List<FinanceTransactionModel>>> getTransactions({
    String? circleId,
    String? status,
  }) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!.trim();
    if (status != null && status != 'All') params['status'] = status;

    return _apiClient.get<List<FinanceTransactionModel>>(
      ApiEndpoints.financeTransactions,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => FinanceTransactionModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <FinanceTransactionModel>[];
      },
    );
  }

  /// Updates platform commission cut rates for leadership roles.
  Future<ApiResponse<Map<String, dynamic>>> updateCommissionRates(
    dynamic commissionRates,
  ) async {
    final List<Map<String, dynamic>> payload = [];
    if (commissionRates is List<UpdateCommissionRateDto>) {
      payload.addAll(commissionRates.map((r) => r.toJson()));
    } else if (commissionRates is List<Map<String, dynamic>>) {
      payload.addAll(commissionRates);
    } else if (commissionRates is List) {
      for (final e in commissionRates) {
        if (e is UpdateCommissionRateDto) {
          payload.add(e.toJson());
        } else if (e is Map<String, dynamic>) {
          payload.add(e);
        } else if (e is Map) {
          payload.add(Map<String, dynamic>.from(e));
        }
      }
    }

    return _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.updateCommissionRates,
      body: {'commission_rates': payload},
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Records an offline / manual fee payment for a peer.
  Future<ApiResponse<Map<String, dynamic>>> recordOfflinePayment({
    required String peerId,
    required String circleId,
    required num amount,
    required String paymentMode,
    required String referenceNumber,
    required String paymentDate,
    required String type,
  }) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.recordOfflineTransaction,
      body: {
        'peer_id': peerId,
        'circle_id': circleId,
        'amount': amount,
        'payment_mode': paymentMode,
        'reference_number': referenceNumber,
        'payment_date': paymentDate,
        'type': type,
      },
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }
}
